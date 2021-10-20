module RestSupport
  module HashHelpers
    # Remove all empty keys (recusively) from Hash.
    # @see https://stackoverflow.com/questions/56457020/#answer-56458673
    def deep_compact!(hsh)
      raise TypeError unless hsh.is_a? Hash

      hsh.each do |_, v|
        deep_compact!(v) if v.is_a? Hash
      end.reject! { |_, v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
    end

    # Deep merge two hashes
    # @see https://stackoverflow.com/questions/41109599#answer-41109737
    def deep_merge!(hsh1, hsh2)
      raise TypeError unless hsh1.is_a?(Hash) && hsh2.is_a?(Hash)

      hsh1.merge!(hsh2) { |_, v1, v2| deep_merge!(v1, v2) }
    end

    # Create nested hashes from JMESPath syntax.
    def bury(path, value)
      raise TypeError unless path.is_a?(String)

      arr = path.split('.')
      ret = {}

      if arr.count == 1
        ret[arr.first] = value

        ret
      else
        partial_path = arr[0..-2].join('.')

        bury(partial_path, bury(arr.last, value))
      end
    end
  end
end
