using Microsoft.AspNetCore.Server.Kestrel.Core;

var builder = WebApplication.CreateBuilder(args);

var port = int.Parse(Environment.GetEnvironmentVariable("PORT") is { Length: > 0 } value ? value : "50058");

builder.WebHost.ConfigureKestrel(options =>
{
    options.ListenAnyIP(port, listenOptions => listenOptions.Protocols = HttpProtocols.Http2);
});

builder.Services.AddGrpc();

var app = builder.Build();

app.MapGrpcService<EchoService>();

app.Run();
