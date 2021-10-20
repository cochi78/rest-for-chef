require_relative "../abstract_resources/ontap_rest_resource"

class Chef
  class Resource
    class OntapSnmpTraphost < Chef::Resource::OntapRestResource
      resource_name :ontap_snmp_traphost
      resource_type :rest

      unified_mode true

      provides :ontap_snmp_traphost, target_mode: true, platform: "ontap"

      description <<~DOC
        Creates SNMP traphosts. While adding an SNMPv3 traphost, an SNMPv3 user configured in ONTAP must be specified. ONTAP
        uses this user’s credentials to authenticate and/or encrypt traps sent to this SNMPv3 traphost. While adding an
        SNMPv1/SNMPv2c traphost, SNMPv1/SNMPv2c user or community need not be specified.
      DOC

      # 1-ary resource
      property :host, String,
        name_property: true

      # Required properties

      # Optional properties
      property :user, String,
        description: <<~DOC
          Optional SNMPv1/SNMPv2c or SNMPv3 user name. For an SNMPv3 traphost, this object refers to an SNMPv3 or User-based
          Security Model (USM) user. For an SNMPv1 or SNMPv2c traphost, this object refers to an SNMP community. For an
          SNMPv3 traphost, this object is mandatory and refers to an SNMPv3 or User-based Security Model (USM) user. For an
          SNMPv1 or SNMPv2c traphost, ONTAP automatically uses "public", if the same is configured, or any other configured
          community as user.
        DOC

      # API URLs and mappings
      rest_api_collection '/api/support/snmp/traphosts'
      rest_api_document   '/api/support/snmp/traphosts/{host}'

      rest_property_map   ({
        host: 'host',
        user: 'user.name'
      })
    end
  end
end

class Chef
  class Provider
    class OntapSnmpTraphost < Chef::Provider::OntapRestResource
      provides :ontap_snmp_traphost, target_mode: true, platform: "ontap"
    end
  end
end
