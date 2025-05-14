use axum::Json;

use sqlx::postgres::{PgPool, PgPoolOptions};
use sqlx::types::BigDecimal;
use sqlx::{Pool, Postgres};
use std::env;
use uuid::Uuid;

#[derive(sqlx::FromRow, serde::Serialize)]
pub struct Account {
    id: Uuid,
    balance: BigDecimal,
}

pub async fn list_accounts(pool: &PgPool) -> Result<Json<Vec<Account>>, sqlx::Error> {
    let rows = sqlx::query_as!(Account, "SELECT id, balance FROM accounts")
        .fetch_all(pool)
        .await?;

    Ok(Json(rows))
}

pub async fn create_pool() -> Result<Pool<Postgres>, sqlx::Error> {
    let db_url: String = env::var("DATABASE_URL").unwrap();
    let pool = PgPoolOptions::new()
        .max_connections(4)
        .connect(db_url.as_str())
        .await?;

    Ok(pool)
}

pub async fn add_account(pool: &PgPool, amount: u64) -> Result<(), sqlx::Error> {
    sqlx::query!(
        "INSERT INTO accounts (balance) VALUES($1)",
        BigDecimal::from(amount)
    )
    .execute(pool)
    .await?;

    Ok(())
}

pub async fn add_funds(
    pool: &PgPool,
    account: uuid::Uuid,
    amount: BigDecimal,
) -> Result<(), sqlx::Error> {
    #[cfg(debug_assertions)]
    println!("Trying to fund the account {} with ${}", account, amount);
    sqlx::query!(
        "UPDATE accounts SET balance=balance + $2 WHERE id = $1",
        account,
        amount
    )
    .execute(pool)
    .await?;

    Ok(())
}
