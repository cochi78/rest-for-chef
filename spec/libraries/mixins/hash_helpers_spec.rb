require_relative '../../spec_helper'

require_relative '../../../libraries/mixins/hash_helpers'

describe RestSupport::HashHelpers do
  include RestSupport::HashHelpers

  describe '.bury' do
    it 'raises TypeError if argument is not a String' do
      expect { bury(1, 123) }.to raise_error(TypeError)
    end

    it 'creates top level elements' do
      expect(bury('a', 123)).to eq({ 'a' => 123 })
    end

    it 'creates top level elements for numeric strings' do
      expect(bury('1', 123)).to eq({ '1' => 123 })
    end

    it 'creates deeply nested elements' do
      expect(bury('a.b.c.d.e', 123)).to eq({ 'a' => { 'b' => { 'c' => { 'd' => { 'e' => 123 } } } } })
    end
  end

  describe '.deep_compact!' do
    it 'raises TypeError if argument is no Hash' do
      expect { deep_compact!(nil) }.to raise_error(TypeError)
      expect { deep_compact!([]) }.to raise_error(TypeError)
    end

    it 'does not change the hash, if all values are set' do
      hsh = { a: 0, b: %i[a b c], c: { d: 'e', e: 'f' } }

      deep_compact!(hsh)

      expect(hsh).to eq({
                          a: 0,
                          b: %i[a b c],
                          c: {
                            d: 'e',
                            e: 'f'
                          }
                        })
    end

    it 'does remove empty arrays on top level' do
      hsh = { a: 0, b: %i[], c: { d: 'e', e: 'f' } }

      deep_compact!(hsh)

      expect(hsh).to eq({
                          a: 0,
                          c: {
                            d: 'e',
                            e: 'f'
                          }
                        })
    end

    it 'does remove empty hashes on top level' do
      hsh = { a: 0, b: %i[a b c], c: {} }

      deep_compact!(hsh)

      expect(hsh).to eq({
                          a: 0,
                          b: %i[a b c]
                        })
    end

    it 'does remove empty strings on top level' do
      hsh = { a: 0, b: %i[a b c], c: { d: 'e', e: 'f' }, f: '' }

      deep_compact!(hsh)

      expect(hsh).to eq({
                          a: 0,
                          b: %i[a b c],
                          c: {
                            d: 'e',
                            e: 'f'
                          }
                        })
    end

    it 'does remove nil values on top level' do
      hsh = { a: nil, b: %i[a b c], c: { d: 'e', e: 'f' } }

      deep_compact!(hsh)

      expect(hsh).to eq({
                          b: %i[a b c],
                          c: {
                            d: 'e',
                            e: 'f'
                          }
                        })
    end

    it 'does removes empty values on first level' do
      hsh = { a: 0, b: %i[a b c], c: { d: 'e', e: '', f: [], g: {} } }

      deep_compact!(hsh)

      expect(hsh).to eq({
                          a: 0,
                          b: %i[a b c],
                          c: {
                            d: 'e'
                          }
                        })
    end

    it 'does recursively remove empty values' do
      hsh = { a: 0, b: %i[a b c], c: { e: '', f: [], g: {} } }

      deep_compact!(hsh)

      expect(hsh).to eq({
                          a: 0,
                          b: %i[a b c]
                        })
    end
  end

  describe '.deep_merge!' do
    it 'raises TypeError if arguments are not Hash' do
      expect { deep_merge!([], {}) }.to raise_error(TypeError)
      expect { deep_merge!({}, []) }.to raise_error(TypeError)
    end

    it 'does merge an empty hash and a non-empty one' do
      hsh = {}

      deep_merge!(hsh, { a: 0, b: 1 })

      expect(hsh).to eq({
                          a: 0,
                          b: 1
                        })
    end

    it 'does merge an non-empty hash and an empty one' do
      hsh = { a: 0, b: 1 }

      deep_merge!(hsh, {})

      expect(hsh).to eq({
                          a: 0,
                          b: 1
                        })
    end

    it 'does merge two hashes' do
      hsh = { a: 0, b: 1 }

      deep_merge!(hsh, { c: 2, d: 3 })

      expect(hsh).to eq({
                          a: 0,
                          b: 1,
                          c: 2,
                          d: 3
                        })
    end

    it 'does merge two deep hashes' do
      hsh = { a: 0, b: { c: 1 } }

      deep_merge!(hsh, { b: { d: 2 } })

      expect(hsh).to eq({
                          a: 0,
                          b: {
                            c: 1,
                            d: 2
                          }
                        })
    end
  end
end
