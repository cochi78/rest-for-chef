class Chef
  class Exceptions
    class RestError < RuntimeError; end

    class RestTargetError < RestError; end

    class RestTimeout < RestError; end

    class RestOperationFailed < RestError; end
  end
end
