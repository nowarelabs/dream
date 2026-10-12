import echo.EchoOuterClass.{EchoReply, EchoRequest}
import io.grpc.protobuf.ProtoUtils
import io.grpc.stub.ServerCalls
import io.grpc.{MethodDescriptor, Server, ServerBuilder, ServerServiceDefinition}

object Main {
  def main(args: Array[String]): Unit = {
    val port = sys.env.getOrElse("PORT", "50059").toInt

    val say = MethodDescriptor
      .newBuilder[EchoRequest, EchoReply]()
      .setType(MethodDescriptor.MethodType.UNARY)
      .setFullMethodName(MethodDescriptor.generateFullMethodName("echo.Echo", "Say"))
      .setRequestMarshaller(ProtoUtils.marshaller(EchoRequest.getDefaultInstance))
      .setResponseMarshaller(ProtoUtils.marshaller(EchoReply.getDefaultInstance))
      .build()

    val echo = ServerServiceDefinition
      .builder("echo.Echo")
      .addMethod(
        say,
        ServerCalls.asyncUnaryCall(
          (req, obs) => {
            obs.onNext(EchoReply.newBuilder().setMessage("echo: " + req.getMessage).build())
            obs.onCompleted()
          }
        )
      )
      .build()

    val server = ServerBuilder.forPort(port).addService(echo).build().start()
    println("scala-grpc listening on 0.0.0.0:" + port)
    server.awaitTermination()
  }
}