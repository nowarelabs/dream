require 'grpc'
require_relative 'echo_pb'

module Echo
  class Service
    include GRPC::GenericService
    self.marshal_class_method = :encode
    self.unmarshal_class_method = :decode
    self.service_name = 'echo.Echo'

    rpc :Say, EchoRequest, EchoReply
  end

  Stub = Service.rpc_stub_class
end