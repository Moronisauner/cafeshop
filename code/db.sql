-- SQL dump generated using DBML (dbml-lang.org)
-- Database: PostgreSQL
-- Generated at: 2022-11-05T21:05:21.750Z

CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" text UNIQUE NOT NULL
);

CREATE TABLE "plans" (
  "id" SERIAL PRIMARY KEY,
  "name" text,
  "month_price" decimal,
  "description" text
);

CREATE TABLE "signatures" (
  "id" SERIAL PRIMARY KEY,
  "user_id" integer,
  "plan_id" integer,
  "start_date" date DEFAULT (CURRENT_DATE),
  "end_date" date DEFAULT (CURRENT_DATE + interval '1 year'),
  "status" text DEFAULT 'active'
);

CREATE TABLE "products" (
  "id" SERIAL PRIMARY KEY,
  "name" text,
  "price" decimal
);

CREATE TABLE "orders" (
  "id" SERIAL PRIMARY KEY,
  "user_id" int,
  "invoice_id" int,
  "product_id" int,
  "amount" int NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "invoices" (
  "id" SERIAL PRIMARY KEY,
  "price" decimal,
  "signature_id" int,
  "user_id" int,
  "paid" boolean DEFAULT false,
  "due_date" date
);

ALTER TABLE "signatures" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "signatures" ADD FOREIGN KEY ("plan_id") REFERENCES "plans" ("id");

ALTER TABLE "orders" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "orders" ADD FOREIGN KEY ("product_id") REFERENCES "products" ("id");

ALTER TABLE "orders" ADD FOREIGN KEY ("invoice_id") REFERENCES "invoices" ("id");

ALTER TABLE "invoices" ADD FOREIGN KEY ("signature_id") REFERENCES "signatures" ("id");

ALTER TABLE "invoices" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
