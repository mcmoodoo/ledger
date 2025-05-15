use axum::{http::StatusCode, Json, extract::State};
use serde::Deserialize;


#[derive(Clone)]
pub struct AuthState {
    pub credentials: LoginRequest,
}

#[derive(Deserialize, Clone, PartialEq, Eq)]
pub struct LoginRequest {
    pub login: String,
    pub password: String,
}

pub async fn log_in(State(auth): State<AuthState>, Json(payload): Json<LoginRequest>) -> Result<String, StatusCode> {
    (payload == auth.credentials)
        .then(|| format!("jwt_token_here"))
        .ok_or(StatusCode::UNAUTHORIZED)
}

