require 'addressable/template' unless defined?(Addressable::Template)
require 'cgi' unless defined?(CGI.parse)
require 'jmespath' unless defined?(JMESPath)
require 'uri' unless defined?(URI)

require_relative '../rest_errors'
require_relative '../mixins/hash_helpers'
require_relative '../mixins/dsl_rest_resource'

class Chef
  class Resource
    class RestResource < Chef::Resource
      unified_mode true

      # This is an abstract resource meant to be subclassed; thus no 'provides'

      skip_docs true
      preview_resource true

      description 'Generic superclass for all REST API resources'

      default_action :configure
      allowed_actions :configure, :delete

      include Chef::DSL::RestResource
    end
  end
end

class Chef
  class Provider
    class RestResource < Chef::Provider
      include RestSupport::HashHelpers

      attr_writer :current_resource

      def load_current_resource
        @current_resource = new_resource.class.new(new_resource.name)

        required_properties.each do |name|
          requested = new_resource.send(name)
          current_resource.send(name, requested)
        end

        return @current_resource if rest_get_all.empty?

        resource_data = rest_get
        return @current_resource if resource_data.nil? || resource_data.empty?

        @resource_exists = true

        # Map JSON contents to defined properties
        current_resource.class.rest_property_map.each do |property, match_instruction|
          property_value = json_to_property(match_instruction, property, resource_data)

          current_resource.send(property, property_value) unless property_value.nil?
        end

        current_resource
      end

      def action_configure
        converge_if_changed do
          data = {}

          new_resource.class.rest_property_map.each do |property, match_instruction|
            # Skip "creation-only" properties on modifications
            next if resource_exists? && new_resource.class.rest_post_only_properties.include?(property)

            deep_merge! data, property_to_json(property, match_instruction)
          end

          deep_compact!(data)

          @resource_exists ? rest_patch(data) : rest_post(data)
        end
      end

      def action_delete
        if resource_exists?
          rest_delete
        else
          logger.debug format('REST resource %<name>s of type %<type>s does not exist. Skipping.',
                              type: new_resource.name, name: id_property)
        end
      end

      protected

      def resource_exists?
        @resource_exists
      end

      def required_properties
        current_resource.class.properties.select { |_, v| v.required? }.except(:name).keys
      end

      # Return changed value or nil for delta current->new
      def changed_value(property)
        new_value = new_resource.send(property)
        return new_value if current_resource.nil?

        current_value = current_resource.send(property)

        return current_value if required_properties.include? property

        new_value == current_value ? nil : new_value
      end

      def id_property
        current_resource.class.identity_attr
      end

      # Map properties to their current values
      def property_map
        map = {}

        current_resource.class.state_properties.each do |property|
          name = property.options[:name]

          map[name] = current_resource.send(name)
        end

        map[id_property] = current_resource.send(id_property)

        map
      end

      # Map part of a JSON (Hash) to resource property via JMESPath or user-supplied function
      def json_to_property(match_instruction, property, resource_data)
        case match_instruction
        when String
          JMESPath.search(match_instruction, resource_data)
        when Symbol
          function = "#{property}_from_json".to_sym
          raise "#{new_resource.name} missing #{function} method" unless self.class.protected_method_defined?(function)

          send(function, resource_data) || {}
        else
          raise TypeError, "Did not expect match type #{match_instruction.class}"
        end
      end

      # Map resource contents into a JSON (Hash) via JMESPath-like syntax or user-supplied function
      def property_to_json(property, match_instruction)
        case match_instruction
        when String
          bury(match_instruction, changed_value(property))
        when Symbol
          function = "#{property}_to_json".to_sym
          raise "#{new_resource.name} missing #{function} method" unless self.class.protected_method_defined?(function)

          value = new_resource.send(property)
          changed_value(property).nil? ? {} : send(function, value)
        else
          raise TypeError, "Did not expect match type #{match_instruction.class}"
        end
      end

      def rest_url_collection
        current_resource.class.rest_api_collection
      end

      # Resource document URL after RFC 6570 template evaluation via properties substitution
      def rest_url_document
        template = ::Addressable::Template.new(current_resource.class.rest_api_document)
        template.expand(property_map).to_s
      end

      # Convenience method for conditional requires
      def conditionally_require_on_setting(property, dependent_properties)
        dependent_properties = Array(dependent_properties)

        requirements.assert(:configure) do |a|
          a.assertion do
            # Needs to be set and truthy to require dependent properties
            if new_resource.send(property)
              dependent_properties.all? { |dep_prop| new_resource.property_is_set?(dep_prop) }
            else
              true
            end
          end

          message = format('Setting property :%<property>s requires properties :%<properties>s to be set as well on resource %<resource_name>s',
                           property: property,
                           properties: dependent_properties.join(', :'),
                           resource_name: current_resource.to_s)

          a.failure_message message
        end
      end

      # Generic REST helpers

      def rest_get_all
        response = api_connection.get(rest_url_collection)

        rest_postprocess(response)
      rescue RestClient::Exception => e
        rest_errorhandler(e)
      end

      def rest_get
        response = api_connection.get(rest_url_document)

        response = rest_postprocess(response)

        first_only = current_resource.class.rest_api_document_first_element_only
        first_only && response.is_a?(Array) ? response.first : response
      rescue RestClient::Exception => e
        rest_errorhandler(e)
      end

      def rest_post(data)
        data.merge! rest_identity_values

        response = api_connection.post(rest_url_collection, data: data)

        rest_postprocess(response)
      rescue RestClient::Exception => e
        rest_errorhandler(e)
      end

      def rest_put(data)
        data.merge! rest_identity_values

        response = api_connection.put(rest_url_collection, data: data)

        rest_postprocess(response)
      rescue RestClient::Exception => e
        rest_errorhandler(e)
      end

      def rest_patch(data)
        response = api_connection.patch(rest_url_document, data: data)

        rest_postprocess(response)
      rescue RestClient::Exception => e
        rest_errorhandler(e)
      end

      def rest_delete
        response = api_connection.delete(rest_url_document)

        rest_postprocess(response)
      rescue RestClient::Exception => e
        rest_errorhandler(e)
      end

      # REST parameter mapping

      # Return number of parameters needed to identify a resource (pre- and post-creation)
      def rest_arity
        rest_identity_map.keys.count
      end

      # Return mapping of template placeholders to property value of identity parameters
      def rest_identity_values
        data = {}

        rest_identity_map.each do |rfc_template, property|
          property_value = new_resource.send(property)
          data.merge! bury(rfc_template, property_value)
        end

        data
      end

      def rest_identity_map
        rest_identity_explicit || rest_identity_implicit
      end

      # Accept direct mapping like { "svm.name" => :name } for specifying the x-ary identity of a resource
      def rest_identity_explicit
        current_resource.class.rest_identity_map
      end

      # Parse document URL for RFC 6570 templates and map them to resource properties.
      #
      # Examples:
      #   Query based: "/api/protocols/san/igroups?name={name}&svm.name={svm}": { "name" => :name, "svm.name" => :svm }
      #   Path based:  "/api/v1/{address}": { "address" => :address }
      #
      def rest_identity_implicit
        template_url = current_resource.class.rest_api_document

        rfc_template = ::Addressable::Template.new(template_url)
        rfc_template_vars = rfc_template.variables

        # Shortcut for 0-ary resources
	      return {} if rfc_template_vars.empty?

        if query_based_selection?
          uri_query = URI.parse(template_url).query

          if CGI.parse(uri_query).values.any?(&:empty?)
            raise 'Need explicit identity mapping, as URL does not contain query parameters for all templates'
          end

          path_variables = CGI.parse(uri_query).keys
        elsif path_based_selection?
          path_variables = rfc_template_vars
        else
          # There is also
          raise 'Unknown type of resource selection. Document URL does not seem to be path- or query-based?'
        end

        identity_map = {}
        path_variables.each_with_index do |v, i|
          next if rfc_template_vars[i].nil? # Not mapped to property, assume metaparameter

          identity_map[v] = rfc_template_vars[i].to_sym
        end

        identity_map
      end

      def query_based_selection?
        template_url = current_resource.class.rest_api_document

        # Will throw exception on presence of RFC 6570 templates
        URI.parse(template_url)
        true
      rescue URI::InvalidURIError => _e
        false
      end

      def path_based_selection?
        !query_based_selection?
      end

      def api_connection
        Chef.run_context.transport.connection
      end

      # Override this for postprocessing device-specifics (paging, data conversion)
      def rest_postprocess(response)
        response
      end

      # Override this for error handling of device-specifics (readable error messages)
      def rest_errorhandler(error_obj)
        error_obj
      end
    end
  end
end
