use tonic::{Request, Response, Status, transport::Server};

pub mod echo {
    tonic::include_proto!("echo");
}

use echo::echo_server::{Echo, EchoServer};
use echo::{EchoReply, EchoRequest};

#[derive(Default)]
pub struct EchoSvc;

#[tonic::async_trait]
impl Echo for EchoSvc {
    async fn say(&self, request: Request<EchoRequest>) -> Result<Response<EchoReply>, Status> {
        let message = request.into_inner().message;
        println!("rust-grpc say: {message}");
        Ok(Response::new(EchoReply {
            message: format!("echo: {message}"),
        }))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let port = std::env::var("PORT").unwrap_or_else(|_| "50051".to_string());
    let addr = format!("0.0.0.0:{port}").parse()?;
    println!("rust-grpc listening on 0.0.0.0:{port}");

    Server::builder()
        .add_service(EchoServer::new(EchoSvc::default()))
        .serve(addr)
        .await?;

    Ok(())
}