use dotenvy::dotenv;
use sqlx::postgres::PgPoolOptions;
use sqlx::{Pool, Postgres};
use std::env;

#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    // println!("Rashid loves {}", env::var("HER").unwrap());

    match create_pool().await {
        Ok(pool) => {
            let row: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts")
                .fetch_one(&pool)
                .await?;
            println!("Account count: {}", row.0);
            Ok(())
        }
        Err(e) => {
            eprintln!("Failed to create the pool {}", e);
            Err(e)
        }
    }
}

async fn create_pool() -> Result<Pool<Postgres>, sqlx::Error> {
    dotenv().ok();
    let pool = PgPoolOptions::new()
        .max_connections(4)
        .connect("postgres://postgres:secret@localhost/ledgerdb")
        .await?;

    Ok(pool)
}
