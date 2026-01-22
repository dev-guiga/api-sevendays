# ApiSevendays (WIP)

Work in progress (WIP). This API is under active development and may change.

## Overview
API built with Rails 8.1 for user authentication and account management. It uses Devise with custom controllers and is API-only (controllers inherit from `ActionController::API`).

## Tech Stack
- Ruby on Rails 8.1
- PostgreSQL
- Devise
- RSpec

## Setup
1. Install dependencies:
   - Ruby and Bundler
   - PostgreSQL (or Docker)
2. Install gems:
   ```bash
   bundle install
   ```
3. Database:
   ```bash
   bin/rails db:create db:migrate
   ```

### Postgres with Docker (optional)
```bash
docker-compose up -d
```

The default database settings are in `config/database.yml`.

## Running the App
```bash
bin/rails server
```

## Routes (current)
- `GET /up` health check
- `POST /sign_up` user registration
- Devise sessions:
  - `POST /users/sign_in`
  - `DELETE /users/sign_out`
- Devise passwords:
  - `POST /users/password` (send reset instructions)
  - `PUT /users/password` (reset with token)

## Tests
```bash
bundle exec rspec
```

## Notes
- The `User` model validates presence and uniqueness of email, username, and CPF.
- Authentication uses Devise with custom sessions and passwords controllers in `app/controllers/devise/`.

