require 'base64' unless defined?(Base64)
require 'train-rest/auth_handler' unless defined?(Train)

# Just a demo for switching auth handlers. The ONTAP API is using normal Basic authentication which
# is built into Train-REST already.
#
# Other APIs, like Redfish or F5, have proprietary login/session-renewal requirements which would
# be included this way in a PSP.
module TrainPlugins
  module Rest
    class OntapBasic < AuthHandler
      def check_options
        raise ArgumentError.new("Need :username for Basic authentication") unless options[:username]
        raise ArgumentError.new("Need :password for Basic authentication") unless options[:password]
      end

      def auth_parameters
        {
          headers: {
            "Authorization" => format("Basic %s", Base64.encode64(options[:username] + ":" + options[:password]).chomp),
          },
        }
      end
    end
  end
end
