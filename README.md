## Journal

This will create the table 
```bash
psql --username=postgres --host=localhost --dbname=dbname -f sql/create-table.sql 

```


## TODOs
### Add dotenvy

Add the dotenvy crate to the project
```bash
cargo add dotenvy
```

Add the rust code to pull the value from the local env var. Not sure if having it in a `.env` file is sufficient or loading the file is necessary?
```rust
use sqlx::{Pool, Postgres};
use dotenvy::dotenv;
use std::env;

async fn create_pool() -> Pool<Postgres> {
    dotenv().ok();
    let db_url = env::var("DATABASE_URL").expect("Missing DATABASE_URL");
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
