require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapNis < Chef::Resource::OntapRestResource
      resource_name :ontap_nis
      resource_type :rest

      unified_mode true

      provides :ontap_nis, target_mode: true, platform: 'ontap'

      description <<~DOC
        The cluster can have one NIS server configuration. Specify the NIS domain and NIS servers as input.
        Domain name and servers fields cannot be empty.

        Both FQDNs and IP addresses are supported for the server property. IPv6 must be enabled if IPv6
        family addresses are specified in the server property. A maximum of ten NIS servers are supported.
      DOC

      # 0-ary resource

      # Required properties
      property :domain, String,
               required: true,
               callbacks: {
                 'length must be between 1 and 64' => lambda { |s|
                   (1..64).include? s.count
                 }
               },
               description: 'The NIS domain to which this configuration belongs.'

      property :servers, [Array, String],
               required: true,
               coerce: proc { |x| Array(x) },
               description: 'A list of hostnames or IP addresses of NIS servers used by the NIS domain configuration.'

      # API URLs and mappings
      rest_api_collection '/api/security/authentication/cluster/nis'
      rest_api_document   '/api/security/authentication/cluster/nis?fields=*'

      rest_property_map   %w[domain servers]
    end
  end
end

class Chef
  class Provider
    class OntapNis < Chef::Provider::OntapRestResource
      provides :ontap_nis, target_mode: true, platform: 'ontap'
    end
  end
end
