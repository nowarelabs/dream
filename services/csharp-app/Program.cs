using System.Net;
using System.Text;

var port = int.Parse(Environment.GetEnvironmentVariable("PORT") is { Length: > 0 } value ? value : "4023");

using var listener = new HttpListener();
listener.Prefixes.Add($"http://127.0.0.1:{port}/");
listener.Start();

Console.WriteLine($"csharp-app listening on http://127.0.0.1:{port}");

var payload = Encoding.UTF8.GetBytes("{\"service\":\"csharp-app\"}");

while (true)
{
    var context = await listener.GetContextAsync();
    context.Response.StatusCode = 200;
    context.Response.ContentType = "application/json";
    context.Response.ContentLength64 = payload.Length;
    await context.Response.OutputStream.WriteAsync(payload);
    context.Response.Close();
}
