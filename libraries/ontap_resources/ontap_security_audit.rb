require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapSecurityAudit < Chef::Resource::OntapRestResource
      resource_name :ontap_security_audit
      resource_type :rest

      unified_mode true

      provides :ontap_security_audit, target_mode: true, platform: 'ontap'

      description 'Updates administrative audit settings for GET requests.'

      examples <<~DOC
        ontap_security_audit 'Enable auditing' do
          ontapi true
          cli true
          http false
        end
      DOC

      # 0-ary resource

      # Optional properties
      property :ontapi, [TrueClass, FalseClass],
               description: 'Enable auditing of ONTAP API GET operations.'

      property :cli, [TrueClass, FalseClass],
               description: 'Enable auditing of CLI GET Operations.'

      property :http, [TrueClass, FalseClass],
               description: 'Enable auditing of HTTP GET Operations.'

      # API URLs and mappings
      rest_api_collection '/api/security/audit'
      rest_api_document   '/api/security/audit?name={name}&fields=*', first_element_only: true

      rest_property_map   %w[ontapi cli http]
    end
  end
end

class Chef
  class Provider
    class OntapSecurityAudit < Chef::Provider::OntapRestResource
      provides :ontap_security_audit, target_mode: true, platform: 'ontap'
    end
  end
end
