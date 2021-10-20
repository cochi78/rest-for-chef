require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapLunMap < Chef::Resource::OntapRestResource
      resource_name :ontap_lun_map
      resource_type :rest

      unified_mode true

      provides :ontap_lun_map, target_mode: true, platform: 'ontap'

      description <<~DOC
        LUN map is an association between a LUN and an initiator group. When a LUN is mapped to an
        initiator group, the initiator group’s initiators are granted access to the LUN. The
        relationship between a LUN and an initiator group is many LUNs to many initiator groups.
      DOC

      # 3-ary resource
      property :svm, String,
               required: true,
               description: 'Name of the SVM.'

      property :igroup, String,
               required: true,
               description: 'The name of the initiator group.'

      property :lun, String,
               required: true,
               description: <<~DOC
                 The fully qualified path name of the LUN composed of a “/vol” prefix, the volume name,
                 the (optional) qtree name, and file name of the LUN.
               DOC

      # Optional properties
      property :logical_unit_number, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               callbacks: {
                 'must be between 0 and 4095' => lambda { |i|
                   (0..4095).include? i
                 }
               },
               description: 'Property using Integers.'

      # API URLs and mappings
      rest_api_collection '/api/protocols/san/lun-maps'
      rest_api_document   '/api/protocols/san/lun-maps?svm.name={svm}&igroup.name={igroup}&lun.name={lun}&fields=*',
                          first_element_only: true

      rest_property_map({
                          logical_unit_number: 'logical_unit_number'
                        })
    end
  end
end

class Chef
  class Provider
    class OntapLunMap < Chef::Provider::OntapRestResource
      provides :ontap_lun_map, target_mode: true, platform: 'ontap'
    end
  end
end
