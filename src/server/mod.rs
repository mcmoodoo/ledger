use axum::{extract::{Path, State}, http::StatusCode, response::IntoResponse, routing::{delete, get, post}, Json, Router};
use serde::Deserialize;
use sqlx::PgPool;
use uuid::Uuid;

pub mod dal;

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

        .route("/accounts", get(get_all_accounts))
        .route("/accounts", post(add_account))
        .route("/accounts/{id}", get(get_account))
        .route("/accounts/{id}/fund", post(fund_account))
        .route("/accounts/{id}/withdraw", post(withdraw_from_account))
        .route("/accounts/{id}", delete(delete_account))
        .with_state(pool)
}

async fn get_account() -> impl IntoResponse {
}

async fn get_all_accounts() -> impl IntoResponse {

}

async fn withdraw_from_account() -> impl IntoResponse {

}

async fn delete_account() -> impl IntoResponse {

}

async fn get_accounts_count(State(pool): State<PgPool>) -> impl IntoResponse {
    dal::get_accounts_count(&pool).await
}

async fn add_account(State(pool): State<PgPool>, Json(payload): Json<AccountRequest>) -> impl IntoResponse {
    dal::add_account(&pool, payload.amount).await
}

async fn fund_account(State(pool): State<PgPool>, Path(id): Path<Uuid>, Json(payload): Json<AddFundsRequest>) -> impl IntoResponse {
    dal::add_funds(&pool, id, payload.amount.into()).await;
    StatusCode::OK
}
