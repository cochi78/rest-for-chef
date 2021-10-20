require_relative '../abstract_resources/ontap_rest_resource'

# TODO: /protocols/san/igroups/{igroup.uuid}/initiators

class Chef
  class Resource
    class OntapIgroup < Chef::Resource::OntapRestResource
      resource_name :ontap_igroup
      resource_type :rest

      unified_mode true

      provides :ontap_igroup, target_mode: true, platform: 'ontap'

      description <<~DOC
        An initiator group (igroup) is a collection of Fibre Channel (FC) world wide port names (WWPNs), and/or
         iSCSI Qualified Names (IQNs), and/or iSCSI EUIs (Extended Unique Identifiers) that identify host
         initiators.

         Initiator groups are used to control which hosts can access specific LUNs. To grant access to a LUN from
         one or more hosts, create an initiator group containing the host initiator names, then create a LUN map
         that associates the initiator group with the LUN.

         An initiator group may contain either initiators or other initiator groups, but not both simultaneously.
         When a parent initiator group is mapped, it inherits all of the initiators of any initiator groups nested
         below it. If any nested initiator group is modified to contain different initiators, the parent initiator
         groups inherit the change. A parent can have many nested initiator groups and an initiator group can be
         nested under multiple parents. Initiators can only be added or removed from the initiator group that
         directly contains them. The maximum supported depth of nesting is three layers.

         Best practice when using nested initiator groups is to match host hierarchies. A single initiator group
         should correspond to a single host. If a LUN needs to be mapped to multiple hosts, the initiator groups
         representing those hosts should be aggregated into a parent initiator group and the LUN should be mapped
         to that initiator group. For multi-ported hosts, initiators have a comment property where the port
         corresponding to the initiator can be documented.

         An initiator can appear in multiple initiator groups. An initiator group can be mapped to multiple LUNs.
         A specific initiator can be mapped to a specific LUN only once. With the introduction of nestable initiator
         groups, best practice is to use the hierarchy such that an initiator is only a direct member of a single
         initiator group, and that initiator group can then be referenced by other initiator groups.

         All initiators or nested initiator groups in an initiator group must be from the same operating system.
         The initiator group’s operating system is specified when the initiator group is created.

         When an initiator group is created, the protocol property is used to restrict member initiators to Fibre
         Channel (fcp), iSCSI (iscsi), or both (mixed). Initiator groups within a nested hierarchy may not have
         conflicting protocols.

         Zero or more initiators or nested initiator groups can be supplied when the initiator group is created.
         After creation, initiators can be added or removed from the initiator group. Initiator groups containing
         other initiator groups report the aggregated list of initiators from all nested initiator groups, but
         modifications of the initiator list must be performed on the initiator group that directly contains
         the initiators.
      DOC

      # 2-ary resource
      property :name, String,
               name_property: true,
               description: 'Name of the initiator group.'

      property :svm, String,
               required: true,
               description: 'Existing SVM for which to create the NFS configuration.'

      # Required properties
      property :os_type, [Symbol, String],
               required: true,
               equal_to: %i[aix hpux hyper_v linux netware openvms solaris vmware windows xen],
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 The host operating system of the initiator group. All initiators in the group should be hosts of
                 the same operating system.
               DOC

      # Optional properties
      property :delete_on_unmap, [TrueClass, FalseClass],
               description: <<~DOC
                 An option that causes the initiator group to be deleted when the last LUN map associated with
                 it is deleted. This property defaults to false when the initiator group is created.
               DOC

      property :protocol, [Symbol, String],
               equal_to: %i[fcp iscsi mixed],
               default: :mixed,
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 The protocols supported by the initiator group. This restricts the type of initiators that can
                 be added to the initiator group. Optional in POST; if not supplied, this defaults to mixed.

                 The protocol of an initiator group cannot be changed after creation of the group.
               DOC

      # API URLs and mappings
      rest_api_collection '/api/protocols/san/igroups'
      rest_api_document   '/api/protocols/san/igroups?name={name}&svm.name={svm}&fields=*', first_element_only: true

      rest_property_map   %w[delete_on_unmap os_type protocol]
    end
  end
end

class Chef
  class Provider
    class OntapIgroup < Chef::Provider::OntapRestResource
      provides :ontap_igroup, target_mode: true, platform: 'ontap'
    end
  end
end
