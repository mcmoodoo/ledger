use dotenvy::dotenv;
use ledger::server;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv().ok();

    let connection_pool = server::dal::create_pool().await?;

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await?;

    // Reminder: it's cheap to clone here as that merely increases Atomic Reference Count on the stack
    // without cloning heap contents. No performance overhead!
    axum::serve(listener, server::router(connection_pool.clone())).await?;

    Ok(())
}
