#include <crow.h>

#include <cstdint>
#include <cstdlib>

int main() {
  const char *port_env = std::getenv("PORT");
  std::uint16_t port =
      static_cast<std::uint16_t>(port_env ? std::atoi(port_env) : 3021);

  crow::SimpleApp app;

  CROW_ROUTE(app, "/")([]() {
    crow::json::wvalue body;
    body["service"] = "cpp-crow";
    body["framework"] = "crow";
    return body;
  });

  app.port(port).multithreaded().run();
  return 0;
}
