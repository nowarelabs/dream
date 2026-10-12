require 'grpc'
require_relative 'echo_pb'
require_relative 'echo_services'

module Echo
  class EchoServer < Service
    def say(req, _call)
      EchoReply.new(message: "echo: #{req.message}")
    end
  end
end

$stdout.sync = true
port = ENV.fetch('PORT', '50052')
server = GRPC::RpcServer.new
server.add_http2_port("0.0.0.0:#{port}", :this_port_is_insecure)
puts "ruby-grpc listening on 0.0.0.0:#{port}"
server.handle(Echo::EchoServer)
server.run_till_terminated_or_interrupted([1, 'int', 'SIGTERM'])