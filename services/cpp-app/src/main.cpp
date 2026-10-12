#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

static const std::string BODY = "{\"service\":\"cpp-app\"}";

static void handle(int fd) {
  char buf[4096];
  std::string request;
  for (;;) {
    ssize_t n = ::read(fd, buf, sizeof(buf));
    if (n <= 0) {
      break;
    }
    request.append(buf, static_cast<size_t>(n));
    if (request.find("\r\n\r\n") != std::string::npos) {
      break;
    }
  }

  std::string response = "HTTP/1.1 200 OK\r\n"
                         "content-type: application/json\r\n"
                         "content-length: " +
                         std::to_string(BODY.size()) +
                         "\r\n"
                         "connection: close\r\n"
                         "\r\n" +
                         BODY;

  size_t off = 0;
  while (off < response.size()) {
    ssize_t w = ::write(fd, response.data() + off, response.size() - off);
    if (w <= 0) {
      break;
    }
    off += static_cast<size_t>(w);
  }
  ::close(fd);
}

int main() {
  const char *port_env = std::getenv("PORT");
  int port = port_env ? std::atoi(port_env) : 4021;

  int server = ::socket(AF_INET, SOCK_STREAM, 0);
  if (server < 0) {
    std::perror("socket");
    return 1;
  }

  int one = 1;
  ::setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));

  sockaddr_in addr;
  std::memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons(static_cast<uint16_t>(port));

  if (::bind(server, reinterpret_cast<sockaddr *>(&addr), sizeof(addr)) < 0) {
    std::perror("bind");
    return 1;
  }
  if (::listen(server, 128) < 0) {
    std::perror("listen");
    return 1;
  }

  std::fprintf(stderr, "cpp-app listening on http://127.0.0.1:%d\n", port);

  for (;;) {
    int fd = ::accept(server, nullptr, nullptr);
    if (fd < 0) {
      continue;
    }
    handle(fd);
  }
}
