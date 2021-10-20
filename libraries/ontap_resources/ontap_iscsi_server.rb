require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapIscsiServer < Chef::Resource::OntapRestResource
      resource_name :ontap_iscsi_server
      resource_type :rest

      unified_mode true

      provides :ontap_iscsi_server, target_mode: true, platform: 'ontap'

      description 'Creates an iSCSI service.'

      # 1-ary resource
      property :svm, String,
               name_property: true,
               description: 'The name of the SVM.'

      # Optional properties
      property :target_alias, String,
               description: <<~DOC
                 The iSCSI target alias of the iSCSI service.

                 The target alias can contain one (1) to 128 characters and feature any printable character except
                 space (" "). A PATCH request with an empty alias (“”) clears the alias.
               DOC

      # API URLs and mappings
      rest_api_collection '/api/protocols/san/iscsi/services'
      rest_api_document   '/api/protocols/san/iscsi/services?svm.name={svm}&fields=*', first_element_only: true

      rest_property_map({
                          target_alias: 'target.alias'
                        })

      allowed_actions :configure, :delete, :enable, :disable
    end
  end
end

class Chef
  class Provider
    class OntapIscsiServer < Chef::Provider::OntapRestResource
      provides :ontap_iscsi_server, target_mode: true, platform: 'ontap'

      action :enable, description: 'Enable a ISCSI Service.' do
        if current_resource
          enable_service unless service_enabled?
        else
          logger.debug format('ONTAP ISCSI Service on SVM %s does not exist. Skipping.', new_resource.name)
        end
      end

      action :disable, description: 'Disable ISCSI Service.' do
        if current_resource
          disable_service unless service_disabled?
        else
          logger.debug format('ONTAP ISCSI Service on SVM %s does not exist. Skipping.', new_resource.name)
        end
      end

      private

      def service_state
        rest_get.fetch('enabled')
      end

      def service_enabled?
        service_state
      end

      def service_disabled?
        !service_state
      end

      def enable_service
        rest_patch({ 'enabled' => true })
      end

      def disable_service
        rest_patch({ 'enabled' => false })
      end
    end
  end
end
