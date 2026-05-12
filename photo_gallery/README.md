# Photo Gallery (Rails + Hotwire Trial)

This app is a server-rendered Rails 8 photo gallery built for the Clever coding challenge. I focused on using Rails conventions and Hotwire primitives (Turbo Frames + Turbo Streams) to implement like/unlike behavior without a custom API or SPA framework.

## Approach

- Keep the stack simple and idiomatic: Rails MVC + Devise auth + Turbo for interactivity.
- Model likes as a real join table with database constraints, then let Rails associations drive behavior.
- Render the gallery and like controls on the server, and update only the changed like UI with Turbo.
- Add request/system/model tests around auth, like behavior, and counter cache correctness.

## Requirement Mapping

### 1) Authentication

- Implemented with `devise` using database-authenticatable sessions.
- `ApplicationController` enforces `before_action :authenticate_user!` so guests are redirected to sign-in.
- Registration/password reset flows are disabled in routes to match the trial scope.
- Seeded users are created in `db/seeds.rb` (no sign-up flow in UI).

### 2) Photo Gallery

- Photos are stored in the database (`photos` table) and rendered from `PhotosController#index`.
- Seed data is loaded from `photos.csv` into the DB in `db/seeds.rb` (not read at runtime).
- Each card includes:
  - `src.medium` image URL
  - photographer name
  - source link with `links.svg`
  - like button + current count with star assets

### 3) Like Functionality (Hotwire)

- Likes are implemented as a nested singular resource: `POST/DELETE /photos/:photo_id/like`.
- The like area is wrapped in a Turbo Frame (`dom_id(photo, :like)`).
- `LikesController#create/destroy` respond with Turbo Stream templates that re-render only that frame.
- Persistence and constraints:
  - `likes` join table stores `user_id` + `photo_id`
  - unique composite index prevents duplicate likes per user/photo
  - `counter_cache` keeps `photos.likes_count` in sync
- Added submit loading state via `data-turbo-submits-with` with a loading partial. This can be tested by adding `sleep 5` to the `LikesController#create/destroy` actions.

### 4) No JS Framework

- No React/Vue/client API layer was used.
- Interactivity is implemented with Hotwire/Turbo server responses.

## Data Model

- `User has_many :likes`
- `Photo has_many :likes`
- `Like belongs_to :user` and `belongs_to :photo, counter_cache: true`
- Uniqueness validation on `Like` plus DB unique index on `[user_id, photo_id]`

## Testing

RSpec coverage includes:

- request specs for gallery auth and like/unlike endpoints
- system specs for sign-in/sign-out flow and interactive like UI state changes
- model specs for like uniqueness and `likes_count` counter cache behavior

Run tests with:

```bash
bundle exec rspec
```

## Local Setup

From `photo_gallery/`:

```bash
bin/setup
```

This installs gems, prepares the DB, seeds users/photos, and starts `bin/dev`. The seeds are idempotent and can be safely re-run without creating duplicate records.

If needed, run manually:

```bash
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

## Seeded Access

- `reviewer@example.com` / `password123`

The seed script also creates sample users and random likes to make like-count states visible in the gallery.
