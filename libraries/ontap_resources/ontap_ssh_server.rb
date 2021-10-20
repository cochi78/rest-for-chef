require_relative '../abstract_resources/ontap_rest_resource'

class Chef
  class Resource
    class OntapSshServer < Chef::Resource::OntapRestResource
      resource_name :ontap_ssh_server
      resource_type :rest

      unified_mode true

      provides :ontap_ssh_server, target_mode: true, platform: 'ontap'

      description 'Updates the SSH server setting for a cluster.'

      # 0-ary resource

      # Required properties

      # Optional properties
      CIPHERS = %i[aes256_ctr aes192_ctr aes128_ctr aes256_cbc aes192_cbc aes128_cbc 3des_cbc aes128_gcm
                   aes256_gcm].freeze
      property :ciphers, [Array, Symbol, String],
               coerce: proc { |x| x.is_a?(Array) ? x.map(&:to_sym) : x.to_sym },
               callbacks: {
                 "values must be list of :#{CIPHERS.join(', :')}" => lambda { |a|
                   a.all? { |s| CIPHERS.include? s }
                 }
               },
               description: 'Ciphers for encrypting the data.'

      property :connections_per_second, [Integer, String],
               default: 10,
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               callbacks: {
                 'value must be between 10 and 70' => lambda { |i|
                   (10..70).include? i
                 }
               },
               description: 'Maximum connections allowed per second.'

      KEX_ALGORITHMS = %i[diffie_hellman_group_exchange_sha256 diffie_hellman_group_exchange_sha1
                          diffie_hellman_group14_sha1 ecdh_sha2_nistp256 ecdh_sha2_nistp384 ecdh_sha2_nistp521].freeze
      property :key_exchange_algorithms, [Array, Symbol, String],
               coerce: proc { |x| x.is_a?(Array) ? x.map(&:to_sym) : x.to_sym },
               callbacks: {
                 "values must be list of :#{KEX_ALGORITHMS.join(', :')}" => lambda { |a|
                   a.all? { |s| KEX_ALGORITHMS.include? s }
                 }
               },
               description: 'Key exchange algorithms.'

      MAC_ALGORITHMS = %i[hmac_sha1 hmac_sha1_96 hmac_sha2_256 hmac_sha2_512 hmac_sha1_etm hmac_sha1_96_etm
                          hmac_sha2_256_etm hmac_sha2_512_etm hmac_md5 hmac_md5_96 umac_64 umac_128 hmac_md5_etm hmac_md5_96_etm umac_64_etm umac_128_etm].freeze
      property :mac_algorithms, [Array, Symbol, String],
               coerce: proc { |x| x.is_a?(Array) ? x.map(&:to_sym) : x.to_sym },
               callbacks: {
                 "values must be list of :#{MAC_ALGORITHMS.join(', :')}" => lambda { |a|
                   a.all? { |s| MAC_ALGORITHMS.include? s }
                 }
               },
               description: 'Key exchange algorithms.'

      property :max_instances, [Integer, String],
               default: 64,
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               callbacks: {
                 'value must be between 1 and 128' => lambda { |i|
                   (1..128).include? i
                 }
               },
               description: 'Maximum possible simultaneous connections.'

      property :max_authentication_retry_count, [Integer, String],
               default: 6,
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               callbacks: {
                 'value must be between 2 and 6' => lambda { |i|
                   (2..6).include? i
                 }
               },
               description: 'Maximum authentication retries allowed before closing the connection.'

      property :per_source_limit, [Integer, String],
               default: 32,
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               callbacks: {
                 'value must be between 1 and 64' => lambda { |i|
                   (1..64).include? i
                 }
               },
               description: 'Maximum connections from the same client host.'

      property :symbol_property, [Symbol, String],
               description: 'Property using Symbols',
               equal_to: %i[],
               coerce: proc { |x| x.to_sym }

      property :int_property, [Integer, String],
               coerce: proc { |x| x.is_a?(Integer) ? x : x.to_i },
               description: 'Property using Integers.'

      property :boolean_property, [TrueClass, FalseClass],
               description: 'Enable something.'

      # API URLs and mappings
      rest_api_collection '/api/security/ssh'
      rest_api_document   '/api/security/ssh?name={name}&fields=*', first_element_only: true

      rest_property_map   %w[
        connections_per_second ciphers key_exchange_algorithms max_instances max_authentication_retry_count
        mac_algorithms per_source_limit
      ]
    end
  end
end

class Chef
  class Provider
    class OntapSshServer < Chef::Provider::OntapRestResource
      provides :ontap_ssh_server, target_mode: true, platform: 'ontap'
    end
  end
end
