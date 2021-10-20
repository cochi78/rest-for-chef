module Ontap
  module ChefHelpers
    def netapp_ontap?
      ::Chef.node['os'] == 'ontap'
    end
  end
end

# Send helpers to Chef Universal DSL
Chef::DSL::Universal.include Ontap::ChefHelpers
