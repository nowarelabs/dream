#include <microhttpd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char *BODY =
    "{\"service\":\"c-microhttpd\",\"framework\":\"microhttpd\"}";

#if MHD_VERSION >= 0x01000000
#define MHD_ANSWER_RESULT enum MHD_Result
#else
#define MHD_ANSWER_RESULT int
#endif

static MHD_ANSWER_RESULT answer(void *cls, struct MHD_Connection *connection,
                                const char *url, const char *method,
                                const char *version, const char *upload_data,
                                size_t *upload_data_size, void **con_cls) {
  (void)cls;
  (void)url;
  (void)method;
  (void)version;
  (void)upload_data;

  if (*con_cls == NULL) {
    *con_cls = (void *)1;
    return MHD_YES;
  }
  if (*upload_data_size != 0) {
    *upload_data_size = 0;
    return MHD_YES;
  }

  struct MHD_Response *response = MHD_create_response_from_buffer(
      strlen(BODY), (void *)BODY, MHD_RESPMEM_PERSISTENT);
  MHD_add_response_header(response, "content-type", "application/json");
  MHD_ANSWER_RESULT ret =
      MHD_queue_response(connection, MHD_HTTP_OK, response);
  MHD_destroy_response(response);
  return ret;
}

int main(void) {
  const char *port_env = getenv("PORT");
  unsigned short port = (unsigned short)(port_env ? atoi(port_env) : 3020);

  struct MHD_Daemon *daemon =
      MHD_start_daemon(MHD_USE_INTERNAL_POLLING_THREAD, port, NULL, NULL,
                       &answer, NULL, MHD_OPTION_END);
  if (daemon == NULL) {
    fprintf(stderr, "failed to start microhttpd daemon\n");
    return 1;
  }

  fprintf(stderr, "c-microhttpd listening on http://127.0.0.1:%u\n",
          (unsigned)port);

  for (;;) {
    pause();
  }

  MHD_stop_daemon(daemon);
  return 0;
}
