require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapVolume < Chef::Resource::OntapRestResource
      resource_name :ontap_volume
      resource_type :rest

      unified_mode true

      provides :ontap_volume, target_mode: true, platform: 'ontap'

      description 'Create and manage volumes.'

      # 2-ary
      property :name, String,
               name_property: true,
               description: <<~DOC
                 Volume name. The name of volume must start with an alphabetic character (a to z or A to Z) or an
                 underscore (_). The name must be 197 or fewer characters in length for FlexGroups, and 203 or
                 fewer characters in length for all other types of volumes. Volume names must be unique within
                 an SVM.
               DOC

      property :svm, String,
               required: true,
               description: 'The name of the SVM.'

      # Required properties
      property :aggregates, [Array, String],
               required: true,
               description: 'Aggregates hosting the volume.',
               coerce: proc { |x| Array(x) }

      # Optional properties
      property :autosize_mode, [Symbol, String],
               equal_to: %i[off grow grow_shrink],
               default: :off,
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 Autosize mode for the volume.
                 grow ‐ Volume automatically grows when the amount of used space is above the ‘grow_threshold’ value.
                 grow_shrink ‐ Volume grows or shrinks in response to the amount of space used.
                 off ‐ Autosizing of the volume is disabled.
               DOC

      property :autosize_minimum, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : from_readable_size(x) },
               description: <<~DOC
                 Minimum size in bytes up to which the volume shrinks automatically. This size cannot be greater than
                 or equal to the maximum size of volume.
               DOC

      property :autosize_maximum, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : from_readable_size(x) },
               description: <<~DOC
                 Maximum size in bytes up to which a volume grows automatically. This size cannot be less than the current
                 volume size, or less than or equal to the minimum size of volume.
               DOC

      property :grow_threshold, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               callbacks: {
                 'needs to be a number between 0..100' => lambda { |i|
                   [0..100].include? i
                 }
               },
               description: <<~DOC
                 Used space threshold size, in percentage, for the automatic growth of the volume. When the amount of used
                 space in the volume becomes greater than this threhold, the volume automatically grows unless it has
                 reached the maximum size. The volume grows when `space.used` is greater than this percent of `space.size`.
                 The `grow_threshold` size cannot be less than or equal to the `shrink_threshold` size
               DOC

      property :shrink_threshold, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               callbacks: {
                 'needs to be a number between 0..100' => lambda { |i|
                   [0..100].include? i
                 }
               },
               description: <<~DOC
                 Used space threshold size, in percentage, for the automatic shrinkage of the volume. When the amount of
                 used space in the volume drops below this threshold, the volume automatically shrinks unless it has
                 reached the minimum size. The volume shrinks when the `space.used` is less than the `shrink_threshold`
                 percent of `space.size`. The `shrink_threshold` size cannot be greater than or equal to the
                 `grow_threshold` size.
               DOC

      property :comment, String,
               description: 'A comment for the volume.'

      property :compression, [Symbol, String],
               equal_to: %i[inline background both none],
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 The system can be enabled/disabled compression.
                 :inline ‐ Data will be compressed first and written to the volume.
                 :background ‐ Data will be written to the volume and compressed later.
                 :both ‐ Inline compression compresses the data and write to the volume, background compression compresses only the blocks on which inline compression is not run.
                 :none ‐ None
               DOC

      property :compaction, [Symbol, String],
               equal_to: %i[inline none],
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 The system can be enabled/disabled compaction.
                 :inline ‐ Data will be compacted first and written to the volume.
                 :none ‐ None
               DOC

      property :cross_volume_dedupe, [Symbol, String],
               equal_to: %i[inline background both none],
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 The system can be enabled/disabled cross volume dedupe. it can be enabled only when dedupe is enabled.
                 :inline ‐ Data will be cross volume deduped first and written to the volume.
                 :background ‐ Data will be written to the volume and cross volume deduped later.
                 :both ‐ Inline cross volume dedupe dedupes the data and write to the volume, background cross volume dedupe dedupes only the blocks on which inline dedupe is not run.
                 :none ‐ None
               DOC

      property :dedupe, [Symbol, String],
               equal_to: %i[inline background both none],
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 The system can be enabled/disabled dedupe.
                 :inline ‐ Data will be deduped first and written to the volume.
                 :background ‐ Data will be written to the volume and deduped later.
                 :both ‐ Inline dedupe dedupes the data and write to the volume, background dedupe dedupes only the blocks on which inline dedupe is not run.
                 :none ‐ None
               DOC

      property :export_policy, String,
               default: 'default',
               description: 'Export Policy to use'

      property :gid, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               default: 0,
               description: <<~DOC
                 The UNIX group ID of the volume.
               DOC

      property :guarantee, [Symbol, String],
               description: 'The type of space guarantee of this volume in the aggregate.',
               equal_to: %i[volume none],
               coerce: proc { |x| x.to_sym }

      property :path, String,
               description: <<~DOC
                 The fully-qualified path in the owning SVM’s namespace at which the volume is mounted. The path is
                 case insensitive and must be unique within a SVM’s namespace. Path must begin with ‘/’ and must not
                 end with '/’. Only one volume can be mounted at any given junction path.
               DOC

      property :security_style, [Symbol, String],
               equal_to: %i[mixed ntfs unified unix],
               default: :unix,
               coerce: proc { |x| x.to_sym },
               description: <<~DOC
                 Security style associated with the volume. Valid in POST or PATCH.
                 mixed ‐ Mixed-style security
                 ntfs ‐ NTFS/WIndows-style security
                 unified ‐ Unified-style security, unified UNIX, NFS and CIFS permissions
                 unix ‐ Unix-style security.
               DOC

      property :size, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : from_ontap_readable_size(x) },
               description: <<~DOC
                 Physical size of the volume, in bytes. The minimum size for a FlexVol volume is 20MB and the minimum
                 size for a FlexGroup volume is 200MB per constituent. The recommended size for a FlexGroup volume is
                 a minimum of 100GB per constituent. For all volumes, the default size is equal to the minimum size.

                 Can use either Bytes or suffixes "M"/"G"/"T"
               DOC

      property :type, [Symbol, String],
               description: 'Type of the volume (:rw read-write volume, :dp data-protection volume).',
               equal_to: %i[rw dp],
               coerce: proc { |x| x.to_sym }

      property :uid, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               default: 0,
               description: <<~DOC
                 The UNIX user ID of the volume.
               DOC

      property :unix_permissions, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               default: 0o755,
               description: <<~DOC
                 UNIX permissions to be viewed as an octal number.
                 It consists of 4 digits derived by adding up bits 4 (read), 2 (write) and 1 (execute).
                 First digit selects the set user ID(4), set group ID (2) and sticky (1) attributes.
                 The second digit selects permission for the owner of the file; the third selects permissions
                 for other users in the same group; the fourth for other users not in the group.

                 For security style "mixed" or "unix", the default setting is 0755 in octal (493 in decimal)
                 and for security style "ntfs", the default setting is 0000. In cases where only owner,
                 group and other permissions are given (as in 755, representing the second, third and fourth
                 digit), first digit is assumed to be zero.
               DOC

      # API URLs and mappings
      rest_api_collection '/api/storage/volumes'
      rest_api_document   '/api/storage/volumes?name={name}&svm.name={svm}&fields=*', first_element_only: true

      rest_property_map({
                          svm:                 'svm.name',
                          comment:             'comment',
                          guarantee:           'guarantee.type',
                          size:                'size',
                          type:                'type',
                          compaction:          'efficiency.compaction',
                          compression:         'efficiency.compression',
                          cross_volume_dedupe: 'efficiency.cross_volume_dedupe',
                          dedupe:              'efficiency.dedupe',
                          export_policy:       'nas.export_policy.name',
                          gid:                 'nas.gid',
                          path:                'nas.path',
                          security_style:      'nas.security_style',
                          uid:                 'nas.uid',
                          unix_permissions:    'nas.unix_permissions',
                          autosize_mode:       'autosize.mode',
                          autosize_minimum:    'autosize.minimum',
                          autosize_maximum:    'autosize.maximum',
                          grow_threshold:      'autosize.grow_threshold',
                          shrink_threshold:    'autosize.shrink_threshold',

                          aggregates:          :custom_mapping
                        })

      allowed_actions :configure, :delete, :online, :offline
    end
  end
end

class Chef
  class Provider
    class OntapVolume < Chef::Provider::OntapRestResource
      provides :ontap_volume, target_mode: true, platform: 'ontap'

      action :offline, description: 'Set a volume as offline.' do
        if current_resource
          set_volume_offline unless volume_offline?
        else
          logger.debug format('ONTAP volume %s does not exist. Skipping.', new_resource.name)
        end
      end

      action :online, description: 'Set a volume as online.' do
        if current_resource
          set_volume_online unless volume_online?
        else
          logger.debug format('ONTAP volume %s does not exist. Skipping.', new_resource.name)
        end
      end

      protected

      # Custom mapping
      def aggregates_from_json(data)
        data.fetch('aggregates').map { |aggregate| aggregate['name'] }
      end

      def aggregates_to_json(data)
        { 'aggregates' => data&.map { |name| { 'name' => name } } }
      end

      private

      def volume_state
        rest_get.fetch('state')
      end

      def volume_offline?
        volume_state == 'offline'
      end

      def volume_online?
        volume_state == 'online'
      end

      def set_volume_offline
        rest_patch({ 'state' => 'offline' })
      end

      def set_volume_online
        rest_patch({ 'state' => 'online' })
      end
    end
  end
end
