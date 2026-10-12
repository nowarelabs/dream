#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

static const char *BODY = "{\"service\":\"c-app\"}";

static void handle(int fd) {
  char buf[4096];
  ssize_t n;
  for (;;) {
    n = read(fd, buf, sizeof(buf));
    if (n <= 0) {
      break;
    }
    buf[n < (ssize_t)sizeof(buf) ? n : (ssize_t)sizeof(buf) - 1] = '\0';
    if (strstr(buf, "\r\n\r\n") != NULL) {
      break;
    }
  }

  char response[512];
  int len = snprintf(response, sizeof(response),
                     "HTTP/1.1 200 OK\r\n"
                     "content-type: application/json\r\n"
                     "content-length: %zu\r\n"
                     "connection: close\r\n"
                     "\r\n"
                     "%s",
                     strlen(BODY), BODY);

  ssize_t off = 0;
  while (off < len) {
    ssize_t w = write(fd, response + off, (size_t)(len - off));
    if (w <= 0) {
      break;
    }
    off += w;
  }
  close(fd);
}

int main(void) {
  const char *port_env = getenv("PORT");
  int port = port_env ? atoi(port_env) : 4020;

  int server = socket(AF_INET, SOCK_STREAM, 0);
  if (server < 0) {
    perror("socket");
    return 1;
  }

  int one = 1;
  setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));

  struct sockaddr_in addr;
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_ANY);
  addr.sin_port = htons((uint16_t)port);

  if (bind(server, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
    perror("bind");
    return 1;
  }
  if (listen(server, 128) < 0) {
    perror("listen");
    return 1;
  }

  fprintf(stderr, "c-app listening on http://127.0.0.1:%d\n", port);

  for (;;) {
    int fd = accept(server, NULL, NULL);
    if (fd < 0) {
      continue;
    }
    handle(fd);
  }
}
