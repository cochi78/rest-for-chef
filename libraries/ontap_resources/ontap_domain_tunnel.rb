require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapDomainTunnel < Chef::Resource::OntapRestResource
      resource_name :ontap_domain_tunnel
      resource_type :rest

      unified_mode true

      provides :ontap_domain_tunnel, target_mode: true, platform: 'ontap'

      description 'Configures a data SVM as a proxy for Active Directory based authentication for cluster user accounts.'

      # 1-ary resource
      property :svm, String,
               name_property: true,
               description: 'The name of the SVM. '

      # No properties

      # API URLs and mappings
      rest_api_collection '/api/security/authentication/cluster/ad-proxy'
      rest_api_document   '/api/security/authentication/cluster/ad-proxy?svm.name={name}&fields=*',
                          first_element_only: true

      rest_property_map({
                          svm: 'svm.name'
                        })
    end
  end
end

class Chef
  class Provider
    class OntapDomainTunnel < Chef::Provider::OntapRestResource
      provides :ontap_domain_tunnel, target_mode: true, platform: 'ontap'
    end
  end
end
