package com.example;

import echo.EchoOuterClass.EchoReply;
import echo.EchoOuterClass.EchoRequest;
import io.grpc.MethodDescriptor;
import io.grpc.Server;
import io.grpc.ServerBuilder;
import io.grpc.ServerServiceDefinition;
import io.grpc.protobuf.ProtoUtils;
import io.grpc.stub.ServerCalls;

public class Main {
  public static void main(String[] args) throws Exception {
    int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "50057"));

    MethodDescriptor<EchoRequest, EchoReply> say =
        MethodDescriptor.<EchoRequest, EchoReply>newBuilder()
            .setType(MethodDescriptor.MethodType.UNARY)
            .setFullMethodName(MethodDescriptor.generateFullMethodName("echo.Echo", "Say"))
            .setRequestMarshaller(ProtoUtils.marshaller(EchoRequest.getDefaultInstance()))
            .setResponseMarshaller(ProtoUtils.marshaller(EchoReply.getDefaultInstance()))
            .build();

    ServerServiceDefinition echo =
        ServerServiceDefinition.builder("echo.Echo")
            .addMethod(
                say,
                ServerCalls.asyncUnaryCall(
                    (req, obs) -> {
                      obs.onNext(
                          EchoReply.newBuilder().setMessage("echo: " + req.getMessage()).build());
                      obs.onCompleted();
                    }))
            .build();

    Server server = ServerBuilder.forPort(port).addService(echo).build().start();
    System.out.println("java-grpc listening on 0.0.0.0:" + port);
    server.awaitTermination();
  }
}