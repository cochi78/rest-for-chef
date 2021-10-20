require 'chefspec' unless defined?(ChefSpec)

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
  config.log_level = :error
end
