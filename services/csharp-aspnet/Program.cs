var builder = WebApplication.CreateBuilder(args);

var port = Environment.GetEnvironmentVariable("PORT") is { Length: > 0 } value ? value : "3023";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var app = builder.Build();

app.MapGet("/", () => Results.Json(new { service = "csharp-aspnet", framework = "aspnet" }));

app.Run();
