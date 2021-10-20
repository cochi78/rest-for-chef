require_relative '../../spec_helper'

require_relative '../../../libraries/mixins/dsl_rest_resource'

describe Chef::DSL::RestResource do
  include Chef::DSL::RestResource

  it 'implements rest_property_map' do
    expect(self.class).to respond_to(:rest_property_map)
  end

  it 'implements rest_api_collection' do
    expect(self.class).to respond_to(:rest_api_collection)
  end

  it 'implements rest_api_document' do
    expect(self.class).to respond_to(:rest_api_document)
  end

  it 'implements rest_identity_map' do
    expect(self.class).to respond_to(:rest_identity_map)
  end

  it 'implements rest_post_only_properties' do
    expect(self.class).to respond_to(:rest_post_only_properties)
  end

  it 'implements rest_api_document_first_element_only' do
    expect(self.class).to respond_to(:rest_api_document_first_element_only)
  end

  it 'implements resource_type' do
    expect(self.class).to respond_to(:resource_type)
  end
end
