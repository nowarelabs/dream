#include <grpc/byte_buffer.h>
#include <grpc/byte_buffer_reader.h>
#include <grpc/credentials.h>
#include <grpc/grpc.h>
#include <grpc/slice.h>
#include <grpc/support/time.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint8_t *read_bytes(grpc_byte_buffer *bb, size_t *out_len) {
  if (bb == NULL) {
    *out_len = 0;
    return NULL;
  }

  size_t cap = grpc_byte_buffer_length(bb);
  uint8_t *buf = malloc(cap > 0 ? cap : 1);

  grpc_byte_buffer_reader reader;
  if (!grpc_byte_buffer_reader_init(&reader, bb)) {
    free(buf);
    *out_len = 0;
    return NULL;
  }

  size_t off = 0;
  grpc_slice slice;
  while (grpc_byte_buffer_reader_next(&reader, &slice)) {
    size_t sl = GRPC_SLICE_LENGTH(slice);
    if (off + sl > cap) {
      buf = realloc(buf, off + sl);
      cap = off + sl;
    }
    memcpy(buf + off, GRPC_SLICE_START_PTR(slice), sl);
    off += sl;
    grpc_slice_unref(slice);
  }
  grpc_byte_buffer_reader_destroy(&reader);
  *out_len = off;
  return buf;
}

static char *parse_message_field(const uint8_t *data, size_t len) {
  if (data == NULL || len < 2 || data[0] != 0x0A) {
    return strdup("");
  }

  size_t i = 1;
  uint64_t mlen = 0;
  int shift = 0;
  while (i < len && (data[i] & 0x80)) {
    mlen |= (uint64_t)(data[i] & 0x7F) << shift;
    shift += 7;
    i++;
    if (shift > 63) {
      return strdup("");
    }
  }
  if (i >= len) {
    return strdup("");
  }
  mlen |= (uint64_t)(data[i] & 0x7F) << shift;
  i++;
  if (i + mlen > len) {
    return strdup("");
  }

  char *s = malloc((size_t)mlen + 1);
  memcpy(s, data + i, (size_t)mlen);
  s[mlen] = '\0';
  return s;
}

static uint8_t *serialize_message_field(const char *msg, size_t *out_len) {
  size_t mlen = strlen(msg);
  size_t varint_len = 1;
  size_t tmp = mlen;
  while (tmp >= 0x80) {
    varint_len++;
    tmp >>= 7;
  }

  size_t total = 1 + varint_len + mlen;
  uint8_t *buf = malloc(total);
  size_t i = 0;
  buf[i++] = 0x0A;
  tmp = mlen;
  while (tmp >= 0x80) {
    buf[i++] = (uint8_t)((tmp & 0x7F) | 0x80);
    tmp >>= 7;
  }
  buf[i++] = (uint8_t)(tmp & 0x7F);
  memcpy(buf + i, msg, mlen);
  i += mlen;
  *out_len = i;
  return buf;
}

int main(void) {
  const char *port_env = getenv("PORT");
  const char *port = port_env ? port_env : "50055";
  char addr[64];
  snprintf(addr, sizeof(addr), "0.0.0.0:%s", port);

  grpc_init();

  grpc_completion_queue *cq = grpc_completion_queue_create_for_next(NULL);
  grpc_server *server = grpc_server_create(NULL, NULL);
  grpc_server_register_completion_queue(server, cq, NULL);

  void *method = grpc_server_register_method(
      server, "/echo.Echo/Say", NULL,
      GRPC_SRM_PAYLOAD_READ_INITIAL_BYTE_BUFFER, 0);
  if (method == NULL) {
    fprintf(stderr, "failed to register method\n");
    return 1;
  }

  grpc_server_credentials *creds = grpc_insecure_server_credentials_create();
  int bound = grpc_server_add_http2_port(server, addr, creds);
  grpc_server_credentials_release(creds);
  if (bound == 0) {
    fprintf(stderr, "failed to bind %s\n", addr);
    return 1;
  }

  grpc_server_start(server);
  fprintf(stderr, "c-grpc listening on grpc://%s\n", addr);

  for (;;) {
    grpc_call *call = NULL;
    grpc_metadata_array metadata;
    grpc_metadata_array_init(&metadata);
    grpc_byte_buffer *payload = NULL;
    gpr_timespec deadline;
    memset(&deadline, 0, sizeof(deadline));

    grpc_call_error err = grpc_server_request_registered_call(
        server, method, &call, &deadline, &metadata, &payload, cq, cq,
        (void *)1);
    if (err != GRPC_CALL_OK) {
      grpc_metadata_array_destroy(&metadata);
      continue;
    }

    grpc_event ev = grpc_completion_queue_next(
        cq, gpr_inf_future(GPR_CLOCK_REALTIME), NULL);
    if (ev.type == GRPC_QUEUE_SHUTDOWN) {
      grpc_metadata_array_destroy(&metadata);
      break;
    }
    if (ev.type != GRPC_OP_COMPLETE || !ev.success) {
      grpc_metadata_array_destroy(&metadata);
      if (call != NULL) {
        grpc_call_unref(call);
      }
      continue;
    }

    size_t req_len = 0;
    uint8_t *req_bytes = read_bytes(payload, &req_len);
    char *req_msg = parse_message_field(req_bytes, req_len);
    free(req_bytes);

    char *reply_msg = malloc(strlen(req_msg) + 7);
    sprintf(reply_msg, "echo: %s", req_msg);

    size_t resp_len = 0;
    uint8_t *resp_bytes = serialize_message_field(reply_msg, &resp_len);
    grpc_slice slice =
        grpc_slice_from_copied_buffer((const char *)resp_bytes, resp_len);
    grpc_byte_buffer *resp_payload = grpc_raw_byte_buffer_create(&slice, 1);
    grpc_slice_unref(slice);

    grpc_op ops[4];
    memset(ops, 0, sizeof(ops));
    int cancelled = 0;

    ops[0].op = GRPC_OP_SEND_INITIAL_METADATA;
    ops[0].data.send_initial_metadata.count = 0;

    ops[1].op = GRPC_OP_SEND_MESSAGE;
    ops[1].data.send_message.send_message = resp_payload;

    ops[2].op = GRPC_OP_SEND_STATUS_FROM_SERVER;
    ops[2].data.send_status_from_server.status = GRPC_STATUS_OK;
    ops[2].data.send_status_from_server.trailing_metadata_count = 0;

    ops[3].op = GRPC_OP_RECV_CLOSE_ON_SERVER;
    ops[3].data.recv_close_on_server.cancelled = &cancelled;

    grpc_call_start_batch(call, ops, 4, (void *)2, NULL);
    grpc_completion_queue_next(cq, gpr_inf_future(GPR_CLOCK_REALTIME), NULL);

    grpc_byte_buffer_destroy(resp_payload);
    if (payload != NULL) {
      grpc_byte_buffer_destroy(payload);
    }
    grpc_metadata_array_destroy(&metadata);
    grpc_call_unref(call);
    free(req_msg);
    free(reply_msg);
    free(resp_bytes);
  }

  grpc_server_shutdown_and_notify(server, cq, (void *)3);
  grpc_server_destroy(server);
  grpc_completion_queue_destroy(cq);
  grpc_shutdown();
  return 0;
}
