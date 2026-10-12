import os
from concurrent import futures

import echo_pb2
import echo_pb2_grpc
import grpc


class EchoServicer(echo_pb2_grpc.EchoServicer):
    def Say(self, request, context):
        return echo_pb2.EchoReply(message="echo: " + request.message)


def main():
    port = os.environ.get("PORT", "50062")
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=4))
    echo_pb2_grpc.add_EchoServicer_to_server(EchoServicer(), server)
    server.add_insecure_port("0.0.0.0:" + port)
    server.start()
    print(f"python-grpc listening on 0.0.0.0:{port}", flush=True)
    server.wait_for_termination()


if __name__ == "__main__":
    main()
