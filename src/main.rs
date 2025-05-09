use sqlx::postgres::PgPoolOptions;
use dotenvy::dotenv;
use std::env;
 
#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    dotenv().ok();
    println!("Rashid loves {}", env::var("HER").unwrap());
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect("postgres://postgres:secret@localhost/dbname")
        .await?;

    let row: (i64, ) = sqlx::query_as("SELECT COUNT(*) FROM users")
        .fetch_one(&pool)
        .await?;

    println!("User count: {}", row.0);
    Ok(())
}
