require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapCifsServer < Chef::Resource::OntapRestResource
      resource_name :ontap_cifs_server
      resource_type :rest

      unified_mode true

      provides :ontap_cifs_server, target_mode: true, platform: 'ontap'

      description 'Create and manage CIFS services'

      # 1-ary property
      property :svm, String,
               name_property: true,
               description: 'Existing SVM for which to create the NFS configuration.'

      # Required properties
      property :servername, String,
               required: true,
               callbacks: {
                 'is longer than 15 characters' => lambda { |v|
                   v.length <= 15
                 },
                 'contains invalid characters' => lambda { |v|
                   v.delete('@#*()=+[]|;:",<>/?') == v
                 }
               },
               description: 'Name of the CIFS Server.'

      property :ad_domain_fqdn, String,
               required: true,
               description: 'Fully qualified domain name of the Windows Active Directory to which this CIFS server belongs.'

      property :ad_domain_user, String,
               required: true,
               description: 'User account with the access to add the CIFS server to the Active Directory.'

      property :ad_domain_password, String,
               required: true,
               sensitive: true,
               description: 'Account password used to add this CIFS server to the Active Directory.'

      # Optional properties
      property :ad_domain_ou, String,
               default: 'CN=Computers',
               description: <<~DOC
                 Specifies the organizational unit within the Active Directory domain to associate with the
                 CIFS server.
               DOC

      property :comment, String,
               callbacks: {
                 'is longer than 48 characters' => lambda { |v|
                   v.length <= 48
                 }
               },
               description: 'Comment.'

      property :default_unix_user, String,
               default: 'pcuser',
               description: <<~DOC
                 Specifies the UNIX user to which any authenticated CIFS user is mapped to, if the normal user
                 mapping rules fails.
               DOC

      # TODO: Should be action
      property :enabled, [TrueClass, FalseClass],
               default: true,
               description: 'Specifies if the CIFS service is administratively enabled.'

      property :kdc_encryption, [TrueClass, FalseClass],
               default: false,
               description: <<~DOC
                 Specifies whether AES-128 and AES-256 encryption is enabled for all Kerberos-based communication
                 with the Active Directory KDC. To take advantage of the strongest security with Kerberos-based
                 communication, AES-256 and AES-128 encryption can be enabled on the CIFS server.

                 Kerberos-related communication for CIFS is used during CIFS server creation on the SVM, as well
                 as during the SMB session setup phase.

                 The CIFS server supports the following encryption types for Kerberos communication:
                 * RC4-HMAC
                 * DES
                 * AES

                 When the CIFS server is created, the domain controller creates a computer machine account in
                 Active Directory. After a newly created machine account authenticates, the KDC and the CIFS server
                 negotiates encryption types. At this time, the KDC becomes aware of the encryption capabilities of
                 the particular machine account and uses those capabilities in subsequent communication with the
                 CIFS server.

                 In addition to negotiating encryption types during CIFS server creation, the encryption types are
                 renegotiated when a machine account password is reset.
               DOC

      property :netbios, [TrueClass, FalseClass],
               default: true,
               description: <<~DOC
                 Specifies whether NetBios name service (NBNS) is enabled for the CIFS. If this service is enabled,
                 the CIFS server will start sending the broadcast for name registration.
               DOC

      property :netbios_aliases, [Array, String],
               coerce: proc { |x| Array(x) },
               description: <<~DOC
                 List of NetBIOS aliases, which are alternate names for the CIFS server and can be used by SMB
                 clients to connect to the CIFS server.
               DOC

      property :restrict_anonymous, [Symbol, String],
               equal_to: %i[no_restriction no_enumeration no_access],
               default: :no_enumeration,
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 Specifies what level of access an anonymous user is granted. An anonymous user (also known as a “null user”) can list or enumerate certain types of system information from Windows hosts on the network, including user names and details, account policies, and share names. Access for the anonymous user can be controlled by specifying one of three access restriction settings.
                 The available values are:

                 :no_restriction - No access restriction for an anonymous user.
                 :no_enumeration - Enumeration is restricted for an anonymous user.
                 :no_access - All access is restricted for an anonymous user.
               DOC

      property :smb_encryption, [TrueClass, FalseClass],
               default: false,
               description: 'Specifies whether encryption is required for incoming CIFS traffic.'

      property :smb_signing, [TrueClass, FalseClass],
               default: false,
               description: <<~DOC
                 Specifies whether signing is required for incoming CIFS traffic. SMB signing helps to ensure that
                 network traffic between the CIFS server and the client is not compromised.
               DOC

      property :wins_servers, [Array, String],
               coerce: proc { |x| Array(x) },
               description: <<~DOC
                 List of Windows Internet Name Server (WINS) addresses which manages and maps the NetBIOS name of
                 the CIFS server to their network IP addresses. The IP addresses must be IPv4 addresses.
               DOC

      # API URLs and mappings
      rest_api_collection '/api/protocols/cifs/services'
      rest_api_document   '/api/protocols/cifs/services?svm={svm}', first_element_only: true

      rest_property_map({
                          comment: 'comment',
                          default_unix_user: 'default_unix_user',
                          enabled: 'enabled',
                          servername: 'name',

                          ad_domain_fqdn: 'ad_domain.fqdn',
                          ad_domain_user: 'ad_domain.user',
                          ad_domain_ou: 'ad_domain.organizational_unit',
                          ad_domain_password: 'ad_domain.password',

                          netbios_aliases: 'netbios.aliases',
                          netbios: 'netbios.enabled',
                          wins_servers: 'netbios.wins_servers',

                          kdc_encryption: 'security.kdc_encryption',
                          restrict_anonymous: 'security.restrict_anonymous',
                          smb_encryption: 'security.smb_encryption',
                          smb_signing: 'security.smb_signing'
                        })
    end
  end
end

class Chef
  class Provider
    class OntapCifsServer < Chef::Provider::OntapRestResource
      provides :ontap_cifs_server, target_mode: true, platform: 'ontap'
    end
  end
end
