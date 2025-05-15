use axum::{extract::State, Router};

pub mod handler;
use handler::log_in;
use handler::LoginRequest;
use handler::AuthState;

pub fn auth_routes() -> Router {
    let state: AuthState = AuthState {
        credentials: LoginRequest { login: "Rashid".into(), password: "secret".into() },
    };

    Router::new().route("/login", axum::routing::post(log_in)).with_state(state)
}
