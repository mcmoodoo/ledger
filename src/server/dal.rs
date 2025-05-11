use axum::Json;

use sqlx::postgres::{PgPool, PgPoolOptions};
use sqlx::types::BigDecimal;
use sqlx::{Pool, Postgres};
use std::env;

pub async fn perform_run() -> Result<(), sqlx::Error> {

    // add_funds(&pool, new_account, BigDecimal::from(102)).await?;

    Ok(())
}

pub async fn get_accounts_count(pool: &PgPool) -> Json<u64> {
    let row: (i64,) = sqlx::query_as("SELECT COUNT(*) FROM accounts")
        .fetch_one(pool)
        .await
        .unwrap();

    Json(row.0.try_into().unwrap())
}

pub async fn create_pool() -> Result<Pool<Postgres>, sqlx::Error> {
    let db_url: String = env::var("DATABASE_URL").unwrap();
    let pool = PgPoolOptions::new()
        .max_connections(4)
        .connect(db_url.as_str())
        .await?;

    Ok(pool)
}

pub async fn add_account(pool: &PgPool, amount: u64) -> Json<uuid::Uuid> {
    let user_id = uuid::Uuid::new_v4();

    sqlx::query!(
        "INSERT INTO accounts (user_id, balance) VALUES($1, $2)",
        user_id,
        BigDecimal::from(amount)
    )
    .execute(pool)
    .await.unwrap();

    Json(user_id)
}

pub async fn add_funds(
    pool: &PgPool,
    account: uuid::Uuid,
    amount: BigDecimal,
) {
    #[cfg(debug_assertions)]
    println!("Trying to fund the account {} with ${}", account, amount);
    sqlx::query!(
        "UPDATE accounts SET balance=balance + $2 WHERE id = $1",
        account,
        amount
    )
    .execute(pool)
    .await
    .unwrap();
}
