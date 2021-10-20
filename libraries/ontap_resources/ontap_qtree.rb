require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapQtree < Chef::Resource::OntapRestResource
      resource_name :ontap_qtree
      resource_type :rest

      unified_mode true

      provides :ontap_qtree, target_mode: true, platform: 'ontap'

      description 'Creates a qtree in a FlexVol volume or a FlexGroup volume. '

      # 3-ary resource
      property :name, String,
               name_property: true,
               description: 'Name for the qtree.'

      property :svm, String,
               required: true,
               description: 'Existing SVM for which to create the qtree.'

      property :volume, String,
               required: true,
               description: 'Existing volume in which to create the qtree.'

      # Optional properties
      property :export_policy, String,
               default: 'default',
               description: 'Export Policy to use'

      property :security_style, [Symbol, String],
               equal_to: %i[unix ntfs mixed],
               coerce: proc { |x| x.to_sym },
               description: 'Security style.'

      property :unix_permissions, Integer,
               description: 'The UNIX permissions for the qtree.'

      # API URLs and mappings
      rest_api_collection '/api/storage/qtrees'
      rest_api_document   '/api/storage/qtrees/?svm.name={svm}&volume.name={volume}&name={name}',
                          first_element_only: true

      rest_property_map({
                          security_style: 'security_style',
                          unix_permissions: 'unix_permissions',

                          export_policy: 'export_policy.name',
                          volume: 'volume.name'
                        })
    end
  end
end

class Chef
  class Provider
    class OntapQtree < Chef::Provider::OntapRestResource
      provides :ontap_qtree, target_mode: true, platform: 'ontap'
    end
  end
end
