require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapSnmp < Chef::Resource::OntapRestResource
      resource_name :ontap_snmp
      resource_type :rest

      unified_mode true

      provides :ontap_snmp, target_mode: true, platform: 'ontap'

      description 'Updates the cluster wide SNMP configuration, such as enabling or disabling SNMP and enabling or disabling authentication traps.'

      # 0-ary resource

      # Required properties

      # Optional properties
      property :auth_traps_enabled, [TrueClass, FalseClass],
               description: 'Specifies whether to enable or disable SNMP authentication traps.'

      # API URLs and mappings
      rest_api_collection '/api/support/snmp'
      rest_api_document   '/api/support/snmp'

      rest_property_map   %w[auth_traps_enabled]

      allowed_actions :configure, :delete, :enable, :disable
    end
  end
end

class Chef
  class Provider
    class OntapSnmp < Chef::Provider::OntapRestResource
      provides :ontap_snmp, target_mode: true, platform: 'ontap'

      action :enable, description: 'Enable SNMP.' do
        enable_service unless service_enabled?
      end

      action :disable, description: 'Disable SNMP.' do
        disable_service unless service_disabled?
      end

      private

      def service_state
        rest_get.fetch('enabled')
      end

      def service_enabled?
        service_state
      end

      def service_disabled?
        !service_state
      end

      def enable_service
        rest_patch({ 'enabled' => true })
      end

      def disable_service
        rest_patch({ 'enabled' => false })
      end
    end
  end
end
