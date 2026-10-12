import echo.EchoOuterClass.EchoReply
import echo.EchoOuterClass.EchoRequest
import io.grpc.MethodDescriptor
import io.grpc.Server
import io.grpc.ServerBuilder
import io.grpc.ServerServiceDefinition
import io.grpc.protobuf.ProtoUtils
import io.grpc.stub.ServerCalls
import io.grpc.stub.StreamObserver

fun main() {
    val port = System.getenv("PORT")?.toIntOrNull() ?: 50061

    val say: MethodDescriptor<EchoRequest, EchoReply> = MethodDescriptor.newBuilder<EchoRequest, EchoReply>()
        .setType(MethodDescriptor.MethodType.UNARY)
        .setFullMethodName(MethodDescriptor.generateFullMethodName("echo.Echo", "Say"))
        .setRequestMarshaller(ProtoUtils.marshaller(EchoRequest.getDefaultInstance()))
        .setResponseMarshaller(ProtoUtils.marshaller(EchoReply.getDefaultInstance()))
        .build()

    val echo = ServerServiceDefinition.builder("echo.Echo")
        .addMethod(
            say,
            ServerCalls.asyncUnaryCall<EchoRequest, EchoReply> { req, obs ->
                obs.onNext(EchoReply.newBuilder().setMessage("echo: " + req.message).build())
                obs.onCompleted()
            }
        )
        .build()

    val server = ServerBuilder.forPort(port).addService(echo).build().start()
    println("kotlin-grpc listening on 0.0.0.0:$port")
    server.awaitTermination()
}