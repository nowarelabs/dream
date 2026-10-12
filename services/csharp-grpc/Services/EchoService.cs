using EchoProto;
using Grpc.Core;

public sealed class EchoService : Echo.EchoBase
{
    public override Task<EchoReply> Say(EchoRequest request, ServerCallContext context)
    {
        return Task.FromResult(new EchoReply { Message = $"echo: {request.Message}" });
    }
}
