require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapCluster < Chef::Resource::OntapRestResource
      resource_name :ontap_cluster
      resource_type :rest

      unified_mode true

      provides :ontap_cluster, target_mode: true, platform: 'ontap'

      description 'Control cluster settings on ONTAP'

      # 0-ary property (always present)
      property :name, String,
               name_property: true,
               description: 'Cluster name.'

      # Optional properties
      property :location, String,
               description: 'Location of the devices.'

      property :contact, String,
               description: 'Name and email of the cluster contact.'

      property :dns_domains, [Array, String],
               coerce: proc { |x| Array(x) },
               description: <<~DOC
                 A list of DNS domains.
                 Domain names have the following requirements:

                 The name must contain only the following characters: A through Z, a through z, 0 through 9, ".", "-" or "_".
                 The first character of each label, delimited by ".", must be one of the following characters: A through Z or a through
                 z or 0 through 9.
                 The last character of each label, delimited by ".", must be one of the following characters: A through Z, a through z,
                 or 0 through 9.
                 The top level domain must contain only the following characters: A through Z, a through z.
                 The system reserves the following names:"all", "local", and "localhost".
               DOC

      property :name_servers, [Array, String],
               coerce: proc { |x| Array(x) },
               description: 'The list of IP addresses of the DNS servers. Addresses can be either IPv4 or IPv6 addresses. '

      property :timezone, String,
               default: 'Etc/UTC',
               description: <<~DOC
                 The ONTAP time zone name or identification in either IANA time zone format "Area/Location", or an ONTAP traditional
                 time zone.

                 The initial first node in cluster setting for time zone is "Etc/UTC".
                 “Etc/UTC” is the IANA timezone “Area/Location” specifier for Coordinated Universal Time (UTC), which is an offset of 0.

                 IANA time zone format

                 The IANA time zone, formatted as "Area/Location", is based on geographic areas that have had the same time zone offset
                 for many years.

                 “Location” represents a compound name using additional forward slashes.

                 An example of the “Area/Location” time zone is “America/New_York” and represents most of the United States Eastern Time
                 Zone. Examples of “Area/Location” with “Location” as a compound name are “America/Argentina/Buenos_Aires” and
                 "America/Indiana/Indianapolis".

                 ONTAP traditional time zone

                 Examples of the traditional time zones are “EST5EDT” for the United States Eastern Time Zone and “CET” for Central European Time Zone.
               DOC

      # API URLs and mappings
      rest_api_collection '/api/cluster'
      rest_api_document   '/api/cluster'

      rest_property_map({
                          name:         'name',
                          contact:      'contact',
                          dns_domains:  'dns_domains',
                          location:     'location',
                          name_servers: 'name_servers',
                          timezone:     'timezone.name'
                        })
    end
  end
end

class Chef
  class Provider
    class OntapCluster < Chef::Provider::OntapRestResource
      provides :ontap_cluster, target_mode: true, platform: 'ontap'

      def define_resource_requirements
        conditionally_require_on_setting :name_servers, %i[dns_domains]
      end
    end
  end
end
