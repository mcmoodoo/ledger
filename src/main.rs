use dotenvy::dotenv;
use sqlx::postgres::{PgPoolOptions, PgPool};
use sqlx::types::BigDecimal;
use sqlx::{Pool, Postgres};
use std::env;

#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    dotenv().ok();

    let pool: Pool<Postgres> = create_pool().await?;
    
    let row: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts")
        .fetch_one(&pool)
        .await?;

    println!("Accounts count before: {}", row.0);

    // now let's add an account
    let new_account: uuid::Uuid = create_account(&pool).await?;

    let row: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts")
        .fetch_one(&pool)
        .await?;

    println!("Accounts count after: {}", row.0);

    add_funds(&pool, new_account, BigDecimal::from(102)).await?;

    Ok(())
}

async fn create_pool() -> Result<Pool<Postgres>, sqlx::Error> {
    let db_url: String = env::var("DATABASE_URL").unwrap();
    let pool = PgPoolOptions::new()
        .max_connections(4)
        .connect(db_url.as_str())
        .await?;

    Ok(pool)
}

async fn create_account(pool: &Pool<Postgres>) -> Result<uuid::Uuid, sqlx::Error> {
    let user_id = uuid::Uuid::new_v4();
    sqlx::query!("INSERT INTO accounts (user_id, balance) VALUES($1, $2)", user_id, BigDecimal::from(100))
    .execute(pool)
    .await?;

    Ok(user_id)
}

async fn add_funds(pool: &PgPool, account: uuid::Uuid, amount: BigDecimal) -> Result<(), sqlx::Error> {
    sqlx::query!("UPDATE accounts SET balance=$2 WHERE user_id = $1", account, amount)
    .execute(pool)
    .await?;

    Ok(())
}
