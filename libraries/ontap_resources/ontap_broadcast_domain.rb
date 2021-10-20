require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapBroadcastDomain < Chef::Resource::OntapRestResource
      resource_name :ontap_broadcast_domain
      resource_type :rest

      unified_mode true

      provides :ontap_broadcast_domain, target_mode: true, platform: 'ontap'

      description 'Creates a new broadcast domain.'

      # 1-ary resource
      property :name, String,
               name_property: true,
               description: 'Name of the broadcast domain, scoped to its IPspace.'

      # Optional resources
      property :ipspace, String,
               # default: "default",
               description: 'IPspace name.'

      property :mtu, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               description: 'Maximum transmission unit, largest packet size on this network.'

      property :ports, [Array, String],
               coerce: proc { |x| Array(x) },
               description: 'Ports that belong to the broadcast domain.'

      # API URLs and mappings
      rest_api_collection '/api/network/ethernet/broadcast-domains'
      rest_api_document   '/api/network/ethernet/broadcast-domains?name={name}&fields=*', first_element_only: true

      rest_property_map({
                          ipspace: 'ipspace.name',
                          mtu: 'mtu'
                        })
    end
  end
end

class Chef
  class Provider
    class OntapBroadcastDomain < Chef::Provider::OntapRestResource
      provides :ontap_broadcast_domain, target_mode: true, platform: 'ontap'

      def action_configure
        super

        return if new_resource.ports.nil?

        new_resource.ports.each do |_port|
          raise 'NotImplementedYet'
        end
      end
    end
  end
end
