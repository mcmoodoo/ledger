use axum::{
    Json, Router,
    extract::{Path, State},
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
};
use serde::Deserialize;
use sqlx::PgPool;
use uuid::Uuid;

pub mod db;

#[derive(Deserialize)]
struct AccountRequest {
    amount: u64,
}

#[derive(Deserialize)]
struct AddFundsRequest {
    amount: u64,
}

pub fn router(pool: PgPool) -> Router {
    Router::new()
        .route("/count", get(get_accounts_count))
        .route("/accounts", get(list_accounts).post(create_account))
        .route("/accounts/{id}", get(get_account).delete(delete_account))
        .route("/accounts/{id}/fund", post(fund_account))
        .route("/accounts/{id}/withdraw", post(withdraw_from_account))
        .with_state(pool)
}

async fn get_account() -> impl IntoResponse {}

async fn list_accounts(State(pool): State<PgPool>) -> Json<Vec<db::Account>> {
    db::list_accounts(&pool).await
}

async fn withdraw_from_account() -> impl IntoResponse {}

async fn delete_account() -> impl IntoResponse {}

async fn get_accounts_count(State(pool): State<PgPool>) -> impl IntoResponse {
    db::get_accounts_count(&pool).await
}

async fn create_account(
    State(pool): State<PgPool>,
    Json(payload): Json<AccountRequest>,
) -> impl IntoResponse {
    // TODO: match the response from the add_account and return proper response code based on that
    db::add_account(&pool, payload.amount).await
}

async fn fund_account(
    State(pool): State<PgPool>,
    Path(id): Path<Uuid>,
    Json(payload): Json<AddFundsRequest>,
) -> impl IntoResponse {
    db::add_funds(&pool, id, payload.amount.into()).await;
    StatusCode::OK
}
