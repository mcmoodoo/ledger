CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    balance NUMERIC NOT NULL DEFAULT 0
);

CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  account_id UUID REFERENCES accounts(id),
  amount NUMERIC(20, 4) NOT NULL,
  created_at TIMESTAMP DEFAULT now()
);

