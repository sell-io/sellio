# Local development

## Get the database and seed data

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

## Test accounts (from seeds)

After running `db:seed`, you can log in with:

| Email                     | Password        | Role              |
|---------------------------|-----------------|--------------------|
| alexsidorov05@gmail.com   | password123     | Verified seller    |
| adrianasecas12@gmail.com  | password123     | Regular user       |
| alexsidorov2005@gmail.com | Dr3amH0useEleven | Admin             |

- **alexsidorov05@gmail.com** is set as a **Verified Seller** locally so you can test the golden badge and 3 free ad boosts per month.
- To use different admin credentials, set `ADMIN_EMAIL` and `ADMIN_PASSWORD` before seeding, e.g. `ADMIN_EMAIL=you@example.com ADMIN_PASSWORD=secret bin/rails db:seed`.

## Creating your own account

You can also **Sign up** from the site (Log in → Sign up) to create a new user; no seed needed. To test Verified Seller features, mark that user as verified in **Admin → Users → Mark verified** (when logged in as admin).
