require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapSvm < Chef::Resource::OntapRestResource
      resource_name :ontap_svm
      resource_type :rest

      unified_mode true

      provides :ontap_svm, target_mode: true, platform: 'ontap'

      description 'Create and manage SVMs (formerly vServers)'

      # 1-ary resource
      property :name, String,
               name_property: true,
               description: 'Name of the SVM to be created.'

      # Optional properties
      property :aggregates, [Array, String],
               coerce: proc { |x| Array(x) },
               description: 'List of allowed aggregates for SVM volumes. An administrator is allowed to create volumes on these aggregates.'

      property :comment, [String, nil],
               description: 'Comment.'

      property :language, [String, nil],
               description: 'Default volume language code.'

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

      property :dns_servers, [Array, String],
               coerce: proc { |x| Array(x) },
               description: 'The list of IP addresses of the DNS servers. Addresses can be either IPv4 or IPv6 addresses.'

      property :cifs, [TrueClass, FalseClass],
               description: 'If allowed, setting to true enables the CIFS service.'

      property :cifs_name, String,
               description: 'The NetBIOS name of the CIFS server.'

      property :ad_domain_fqdn, String,
               description: <<~DOC
                 The fully qualified domain name of the Windows Active Directory to which this CIFS server belongs.
                 A CIFS server appears as a member of Windows server object in the Active Directory.
               DOC

      property :ad_domain_user, String,
               description: 'The user account used to add this CIFS server to the Active Directory.'

      property :ad_domain_password, String,
               sensitive: true,
               description: 'The account password used to add this CIFS server to the Active Directory.'

      property :ad_domain_ou, String,
               default: 'CN=Computers',
               description: 'Specifies the organizational unit within the Active Directory domain to associate with the CIFS server.'

      property :fcp, [TrueClass, FalseClass],
               description: 'If allowed, setting to true enables the FCP service.'

      property :iscsi, [TrueClass, FalseClass],
               description: 'If allowed, setting to true enables the ISCSI service.'

      property :nfs, [TrueClass, FalseClass],
               description: 'If allowed, setting to true enables the NFS service.'

      property :nis, [TrueClass, FalseClass],
               description: 'Enable NIS Setting to true creates a configuration if not already created.'

      property :nis_servers, [Array, String],
               coerce: proc { |x| Array(x) },
               description: 'A list of hostnames or IP addresses of NIS servers used by the NIS domain configuration. '

      # API URLs and mappings
      rest_api_collection '/api/svm/svms'
      rest_api_document   '/api/svm/svms?name={name}&fields=*', first_element_only: true
      rest_property_map({
                          aggregates:         'aggregates',
                          comment:            'comment',
                          language:           'language',

                          cifs:               'cifs.enabled',
                          cifs_name:          'cifs.name',
                          ad_domain_fqdn:     'cifs.ad_domain.fqdn',
                          ad_domain_user:     'cifs.ad_domain.user',
                          ad_domain_password: 'cifs.ad_domain.password',
                          ad_domain_ou:       'cifs.ad_domain.ou',

                          dns_domains:        'dns.domains',
                          dns_servers:        'dns.name_servers',

                          fcp:                'fcp.enabled',

                          iscsi:              'iscsi.enabled',

                          nfs:                'nfs.enabled',

                          nis:                'nis.enabled',
                          nis_servers:        'nis.servers'
                        })

      rest_post_only_properties %i[ad_domain_user ad_domain_password ad_domain_fqdn ad_domain_ou]

      allowed_actions :configure, :delete, :start, :stop
    end
  end
end

class Chef
  class Provider
    class OntapSvm < Chef::Provider::OntapRestResource
      provides :ontap_svm, target_mode: true, platform: 'ontap'

      # TODO: not usable?
      action :start do
        if current_resource
          start_svm unless svm_running?
        else
          logger.debug format('ONTAP: SVM %s does not exist. Skipping.', new_resource.name)
        end
      end

      action :stop do
        if current_resource
          stop_svm unless svm_stopped?
        else
          logger.debug format('ONTAP: SVM %s does not exist. Skipping.', new_resource.name)
        end
      end

      # Evaluate complex requirements
      def define_resource_requirements
        conditionally_require_on_setting :cifs, %i[cifs cifs_name ad_domain_fqdn ad_domain_user ad_domain_password]
        conditionally_require_on_setting :nis,  %i[nis_servers nis_domain]

        conditionally_require_on_setting :dns_servers, %i[dns_domains]
        conditionally_require_on_setting :dns_domains, %i[dns_servers]
      end

      private

      def svm_running?
        svm_state == 'running'
      end

      def svm_stopped?
        svm_state == 'stopped'
      end

      def svm_state
        rest_get.fetch('state')
      end

      def start_svm
        rest_patch({ 'state' => 'running' })
      end

      def stop_svm
        rest_patch({ 'state' => 'stopped' })
      end
    end
  end
end
