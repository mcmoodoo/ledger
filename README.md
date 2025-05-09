## Journal

I need to build a microservice in Rust that will:
    - expose a CRUD API
    - allow a person to create an account with the exchange
    - allow a person to deposit funds
    - allow a person to provide personal info for KYC
    - allow account holders to send funds internally to other account holders

## TODOs

```rust
use sqlx::{Pool, Postgres};
use dotenvy::dotenv;
use std::env;

async fn create_pool() -> Pool<Postgres> {
    dotenv().ok();
    let db_url = env::var("DATABASE_URL").expect("Missing DATABASE_URL");
    println!("The db_url is {}", &db_url);
    sqlx::PgPool::connect(&db_url).await.unwrap()
}
```

```bash
sqlx migrate add init
# add your .sql file under migrations/
sqlx migrate run
```

Use sqlx macros for type-safe queries:

```rust
sqlx::query!(
    "INSERT INTO transactions (account_id, amount) VALUES ($1, $2)",
    account_id,
    amount
)
.execute(&pool)
.await?;
```
