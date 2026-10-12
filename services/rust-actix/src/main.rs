use actix_web::{get, App, HttpResponse, HttpServer};
use std::env;

#[get("/")]
async fn index() -> HttpResponse {
    HttpResponse::Ok()
        .content_type("application/json")
        .body(r#"{"service":"rust-actix"}"#)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let port = env::var("PORT").unwrap_or_else(|_| "3005".to_string());
    println!("rust-actix listening on http://127.0.0.1:{port}");

    HttpServer::new(|| App::new().service(index))
        .bind(("0.0.0.0", port.parse::<u16>().expect("invalid PORT")))?
        .run()
        .await
}