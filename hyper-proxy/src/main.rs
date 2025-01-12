use bytes::Bytes;
use http_body_util::{combinators::BoxBody, BodyExt};
use hyper::client::conn::http1::Builder;
use hyper::server::conn::http1;
use hyper::service::service_fn;
use hyper::{Request, Response};
use hyper_util::rt::TokioIo;
use std::{error::Error, net::SocketAddr};
use tokio::{
    net::{TcpListener, TcpStream},
    stream,
};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let addr = SocketAddr::from(([0, 0, 0, 0], 8001));
    let listener = TcpListener::bind(addr).await?;

    println!("Listing on http://{}", addr);

    loop {
        let (stream, _) = listener.accept().await?;
        let io = hyper_util::rt::TokioIo::new(stream);

        tokio::task::spawn(async move {
            if let Err(err) = http1::Builder::new()
                .preserve_header_case(true)
                .title_case_headers(true)
                .serve_connection(io, service_fn(proxy))
                .with_upgrades()
                .await
            {
                println!("Failed to serve connection: {:?}", err)
            }
        });
    }
}

async fn proxy(
    req: Request<hyper::body::Incoming>,
) -> Result<Response<BoxBody<Bytes, hyper::Error>>, hyper::Error> {
    let forward_host = String::from("ping-server");
    let forward_port = 9000u16;

    let stream = TcpStream::connect((forward_host, forward_port))
        .await
        .unwrap();
    let io = TokioIo::new(stream);
    let (mut sender, conn) = Builder::new()
        .preserve_header_case(true)
        .title_case_headers(true)
        .handshake(io)
        .await?;
    tokio::task::spawn(async move {
        if let Err(err) = conn.await {
            println!("Connection failed: {:?}", err)
        }
    });
    let resp = sender.send_request(req).await?;
    Ok(resp.map(|b| b.boxed()))
}
