require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapAggregate < Chef::Resource::OntapRestResource
      resource_name :ontap_aggregate
      resource_type :rest

      unified_mode true

      provides :ontap_aggregate, target_mode: true, platform: 'ontap'

      description 'Create and manage aggregates.'

      # 1-ary resource
      property :name, String,
               name_property: true,
               description: 'Name of the aggregate.'

      # Required properties
      property :node_name, String,
               required: true,
               description: 'Node which owns the aggregate.'

      property :disk_count, Integer,
               required: true,
               description: 'Number of disks to use.'

      # Optional properties
      property :checksum_style, [Symbol, String],
               description: 'Checksum class to apply.',
               equal_to: %i[block advanced_zoned mixed],
               coerce: proc { |x| x.to_sym }

      property :disk_class, [Symbol, String],
               description: 'Class of disks.',
               equal_to: %i[capacity performance archive solid_state array virtual data_center capacity_flash],
               coerce: proc { |x| x.to_sym }

      property :raid_size, Integer,
               description: 'Maximum RAID group size.'

      property :raid_type, [Symbol, String],
               description: 'RAID type for aggregate.',
               equal_to: %i[raid0 raid4 raid_dp raid_tec],
               coerce: proc { |x| x.to_sym }

      property :software_encryption, [TrueClass, FalseClass],
               description: 'Enable software encryption.'

      # API URLs and mappings
      rest_api_collection '/api/storage/aggregates'
      rest_api_document   '/api/storage/aggregates?name={name}&fields=*', first_element_only: true

      rest_property_map({
                          node_name: 'node.name',
                          checksum_style: 'block_storage.primary.checksum_style',
                          disk_class: 'block_storage.primary.disk_class',
                          disk_count: 'block_storage.primary.disk_count',
                          raid_size: 'block_storage.primary.raid_size',
                          raid_type: 'block_storage.primary.raid_type',
                          software_encryption: 'data_encryption.software_encryption_enabled'
                        })
    end
  end
end

class Chef
  class Provider
    class OntapAggregate < Chef::Provider::OntapRestResource
      provides :ontap_aggregate, target_mode: true, platform: 'ontap'

      def define_resource_requirements
        # requirements.assert(:configure) do |a|
        #   a.assertion do
        #     new_resource.raid_type == :raid4 && new_resource.disk_count >= 3
        #   end
        #   a.failure_message("RAID4 requires at least 3 disks (specified: #{new_resource.disk_count})")
        # end
        #
        # requirements.assert(:configure) do |a|
        #   a.assertion do
        #     new_resource.raid_type == :raid_dp && new_resource.disk_count >= 5
        #   end
        #   a.failure_message("RAID DP requires at least 5 disks (specified: #{new_resource.disk_count})")
        # end
        #
        # requirements.assert(:configure) do |a|
        #   a.assertion do
        #     new_resource.raid_type == :raid_tec && new_resource.disk_count >= 7
        #   end
        #   a.failure_message("RAID TEC requires at least 7 disks (specified: #{new_resource.disk_count})")
        # end
      end
    end
  end
end
