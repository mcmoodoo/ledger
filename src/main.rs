use sqlx::postgres::PgPoolOptions;

 
#[tokio::main]
async fn main() -> Result<(), sqlx::Error> {
    let pool = PgPoolOptions::new()
        .max_connections(5)
        .connect("postgres://postgres:secret@localhost/dbname").await?;

    let row: (i64, ) = sqlx::query_as("SELECT COUNT(*) FROM users")
        .fetch_one(&pool)
        .await?;

    println!("User count: {}", row.0);
    Ok(())
}
