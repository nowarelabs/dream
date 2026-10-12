package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"os"

	echo "go-grpc/echo"

	"google.golang.org/grpc"
)

type server struct {
	echo.UnimplementedEchoServer
}

func (s *server) Say(_ context.Context, req *echo.EchoRequest) (*echo.EchoReply, error) {
	return &echo.EchoReply{Message: fmt.Sprintf("echo: %s", req.Message)}, nil
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "50053"
	}

	lis, err := net.Listen("tcp", ":"+port)
	if err != nil {
		log.Fatal(err)
	}

	s := grpc.NewServer()
	echo.RegisterEchoServer(s, &server{})
	log.Printf("go-grpc listening on 0.0.0.0:%s", port)
	if err := s.Serve(lis); err != nil {
		log.Fatal(err)
	}
}