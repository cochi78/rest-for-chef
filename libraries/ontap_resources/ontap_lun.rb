require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapLun < Chef::Resource::OntapRestResource
      resource_name :ontap_lun
      resource_type :rest

      unified_mode true

      provides :ontap_lun, target_mode: true, platform: 'ontap'

      description <<~DOC
        A LUN is the logical representation of storage in a storage area network (SAN).

        In ONTAP, a LUN is located within a volume. Optionally, it can be located within a qtree in a volume.

        A LUN can be created to a specified size using thin or thick provisioning. A LUN can then be renamed,
        resized, cloned, and moved to a different volume. LUNs support the assignment of a quality of service
        (QoS) policy for performance management or a QoS policy can be assigned to the volume containing the
        LUN.

        A LUN must be mapped to an initiator group to grant access to the initiator group’s initiators
        (client hosts). Initiators can then access the LUN and perform I/O over a Fibre Channel (FC)
        fabric using the Fibre Channel Protocol or a TCP/IP network using iSCSI.
      DOC

      # 2-ary resource
      property :name, String,
               name_property: true,
               description: 'Name of the LUN.'

      property :svm, String,
               required: true,
               description: 'The name of the SVM.'

      # Required properties
      property :os_type, [Symbol, String],
               required: true,
               equal_to: %i[aix hpux hyper_v linux netware openvms solaris solaris_efi vmware windows windows_2008 windows_gpt xen],
               coerce: proc { |x| x.to_sym },
               description: 'The operating system type of the LUN.'

      property :size, [Integer, String],
               required: true,
               coerce: proc { |x| x.is_a?(Integer) ? x : from_ontap_readable_size(x) },
               description: <<~DOC
                 The total provisioned size of the LUN. The LUN size can be increased but not be made smaller.
                 Warning: only values divisible by 1024 will be applied.
               DOC

      # Optional properties
      property :comment, String,
               description: 'A configurable comment available for use by the administrator.'

      # API URLs and mappings
      rest_api_collection '/api/storage/luns'
      rest_api_document   '/api/storage/luns?name={name}&svm.name={svm}&fields=*', first_element_only: true

      rest_property_map({
                          comment: 'comment',
                          os_type: 'os_type',
                          size: 'space.size'
                        })

      rest_post_only_properties %i[os_type]

      allowed_actions :configure, :delete, :enable, :disable
    end
  end
end

class Chef
  class Provider
    class OntapLun < Chef::Provider::OntapRestResource
      provides :ontap_lun, target_mode: true, platform: 'ontap'

      action :enable, description: 'Enable a LUN.' do
        if current_resource
          enable_lun unless lun_enabled?
        else
          logger.debug format('ONTAP LUN %<lun_name>s on SVM %<svm_name>s does not exist. Skipping.',
                              lun_name: new_resource.name,
                              svm_name: new_resource.svm)
        end
      end

      action :disable, description: 'Disable a LUN.' do
        if current_resource
          disable_lun unless lun_disabled?
        else
          logger.debug format('ONTAP LUN %<lun_name>s on SVM %<svm_name>s does not exist. Skipping.',
                              lun_name: new_resource.name,
                              svm_name: new_resource.svm)
        end
      end

      private

      def lun_state
        rest_get.fetch('enabled')
      end

      def lun_enabled?
        lun_state
      end

      def lun_disabled?
        !lun_state
      end

      def enable_lun
        rest_patch({ 'enabled' => true })
      end

      def disable_lun
        rest_patch({ 'enabled' => false })
      end
    end
  end
end
