require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapAutosupport < Chef::Resource::OntapRestResource
      resource_name :ontap_autosupport
      resource_type :rest

      unified_mode true

      provides :ontap_autosupport, target_mode: true, platform: 'ontap'

      description 'Updates the AutoSupport configuration for the entire cluster.'

      # 0-ary resource (always present)

      # Optional properties
      property :contact_support, [TrueClass, FalseClass],
               description: 'Specifies whether to send the AutoSupport messages to vendor support.'

      property :enabled, [TrueClass, FalseClass],
               description: 'Specifies whether AutoSupport should be enabled.'

      property :from, String,
               description: "The e-mail address from which the AutoSupport messages are sent. To generate node-specific ‘from’ addresses, enable '-node-specific-from’ parameter via ONTAP CLI."

      property :is_minimal, [TrueClass, FalseClass],
               description: 'Specifies whether the system information is collected in compliant form, to remove private data or in complete form, to enhance diagnostics.'

      property :mail_hosts, [Array, String],
               description: 'The names of the mail servers used to deliver AutoSupport messages via SMTP.',
               coerce: proc { |x| Array(x) }

      property :partner_addresses, [Array, String],
               description: 'The list of partner addresses.',
               coerce: proc { |x| Array(x) }

      property :proxy_url, String,
               description: 'Proxy server for AutoSupport message delivery via HTTP/S. Optionally specify a username/password for authentication with the proxy server.'

      property :to, [Array, String],
               description: 'The e-mail addresses to which the AutoSupport messages are sent.',
               coerce: proc { |x| Array(x) }

      property :transport, [Symbol, String],
               description: 'The name of the transport protocol used to deliver AutoSupport messages.',
               equal_to: %i[smtp http https],
               default: :https,
               coerce: proc { |x| x.to_sym }

      # API URLs and mappings
      rest_api_collection '/api/support/autosupport'
      rest_api_document   '/api/support/autosupport?fields=*'

      rest_property_map   %w[contact_support enabled from is_minimal mail_hosts partner_addresses proxy_url to
                             transport]
    end
  end
end

class Chef
  class Provider
    class OntapAutosupport < Chef::Provider::OntapRestResource
      provides :ontap_autosupport, target_mode: true, platform: 'ontap'
    end
  end
end
