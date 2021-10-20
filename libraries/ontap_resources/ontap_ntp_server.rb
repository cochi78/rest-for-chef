require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapNtpServer < Chef::Resource::OntapRestResource
      resource_name :ontap_ntp_server
      resource_type :rest

      unified_mode true

      provides :ontap_ntp_server, target_mode: true, platform: 'ontap' # , platform_version_min: '9.7'

      description 'Validates the provided external NTP time server for usage and configures ONTAP so that all nodes in the cluster use it.'

      # 1-ary resource
      property :server, String,
               name_property: true,
               description: 'NTP server host name, IPv4, or IPv6 address.'

      # Optional resources
      property :version, [Symbol, String],
               default: :auto,
               equal_to: %i[3 4 auto],
               coerce: proc { |x| x.to_sym },
               description: 'NTP protocol version for server. Valid versions are :3, :4, or :auto.'

      # API URLs and mappings
      rest_api_collection '/api/cluster/ntp/servers'
      rest_api_document   '/api/cluster/ntp/servers/{server}?fields=*'

      rest_property_map   %w[server version]
    end
  end
end

class Chef
  class Provider
    class OntapNtpServer < Chef::Provider::OntapRestResource
      provides :ontap_ntp_server, target_mode: true, platform: 'ontap'
    end
  end
end
