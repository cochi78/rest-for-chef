require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapSecurityAuditDestination < Chef::Resource::OntapRestResource
      resource_name :ontap_security_audit_destination
      resource_type :rest

      unified_mode true

      provides :ontap_security_audit_destination, target_mode: true, platform: 'ontap'

      description 'Configures remote syslog/splunk server information.'

      # 2-ary resource
      property :address, String,
               name_property: true,
               description: <<~DOC
                 Destination syslog|splunk host to forward audit records to. This can be an IP address (IPv4|IPv6)
                 or a hostname.
               DOC

      property :port, [Integer, String],
               default: 514,
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               description: 'Destination Port.'

      # Required properties

      # Optional properties
      property :facility, [Symbol, String],
               equal_to: %i[kern user local0 local1 local2 local3 local4 local5 local6 local7],
               coerce: proc { |x| x.to_sym },
               description: 'This is the standard Syslog Facility value that is used when sending audit records to a remote server.'

      property :protocol, [Symbol, String],
               equal_to: %i[udp_unencrypted tcp_unencrypted tcp_encrypted],
               coerce: proc { |x| x.to_sym },
               description: 'Log forwarding protocol.'

      property :verify_server, [TrueClass, FalseClass],
               description: <<~DOC
                 This is only applicable when the protocol is tcp_encrypted. This controls whether the remote
                 server’s certificate is validated. Setting “verify_server” to “true” will enforce validation
                 of remote server’s certificate. Setting “verify_server” to “false” will not enforce validation
                 of remote server’s certificate.
               DOC

      # API URLs and mappings
      rest_api_collection '/api/security/audit/destinations'
      rest_api_document   '/api/security/audit/destinations/{address}/{port}'

      rest_property_map   %w[address facility port protocol verify_server]
    end
  end
end

class Chef
  class Provider
    class OntapSecurityAuditDestination < Chef::Provider::OntapRestResource
      provides :ontap_security_audit_destination, target_mode: true, platform: 'ontap'
    end
  end
end
