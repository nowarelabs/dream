#include <grpcpp/grpcpp.h>

#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>

#include "echo.grpc.pb.h"

using grpc::Server;
using grpc::ServerBuilder;
using grpc::ServerContext;
using grpc::Status;

class EchoServiceImpl final : public echo::Echo::Service {
  Status Say(ServerContext *context, const echo::EchoRequest *request,
             echo::EchoReply *reply) override {
    (void)context;
    reply->set_message("echo: " + request->message());
    return Status::OK;
  }
};

int main() {
  const char *port_env = std::getenv("PORT");
  std::string port = port_env ? port_env : "50056";
  std::string address = "0.0.0.0:" + port;

  EchoServiceImpl service;

  ServerBuilder builder;
  builder.AddListeningPort(address, grpc::InsecureServerCredentials());
  builder.RegisterService(&service);

  std::unique_ptr<Server> server(builder.BuildAndStart());
  if (!server) {
    std::cerr << "failed to start cpp-grpc server" << std::endl;
    return 1;
  }

  std::cout << "cpp-grpc listening on " << address << std::endl;
  server->Wait();
  return 0;
}
