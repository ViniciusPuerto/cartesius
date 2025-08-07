# Cartesius API

Geometric playground built with **Ruby on Rails 8 (API-only)**, PostgreSQL 16 & PostGIS 3.4, all dockerised.

It manages boards (Cartesian planes), square frames, and circles with spatial validations powered by PostGIS.  
The default demo data contains a single *main* board plus one frame and a few circles.


[Here](https://app.swaggerhub.com/apis-docs/VINICIUSALVESPORTO/Cartesius/1.0.0) you can see the swagger docs for the api

[Production (HTTP)](http://ec2-52-67-23-66.sa-east-1.compute.amazonaws.com) — public deployment behind Caddy. Use this as the base URL for manual tests.

---
## 1. Prerequisites

* Docker ≥ 24
* Docker Compose plugin (`docker compose` CLI)

Nothing else is required on your host – no Ruby, Node or database.

---
## 2. Quick start (development)

```bash
# Clone and enter the project
$ git clone https://github.com/ViniciusPuerto/cartesius
$ cd cartesius

# Build image & start PostGIS container
$ docker compose up -d db

# Install gems and compile the Rails image
$ docker compose build

# Prepare the database (create + migrate + seed)
$ docker compose run --rm app bundle exec rails db:prepare db:seed

# Launch the API (port 3000)
$ docker compose up app  # or: docker compose up -d
```

Visit <http://localhost:3000/up> – you should get `{"status":"OK"}`.

---
## 3. Running the test suite

```bash
# Isolated test database is cartesius_test
$ docker compose run --rm \
    -e RAILS_ENV=test \
    -e PGDATABASE=cartesius_test \
    app bundle exec rspec
```

All specs (models, services and requests) should pass.

---
## 4. Seed data

`db/seeds.rb` is **idempotent**: you can run it any time.

* Guarantees a board named `main` (created if missing).
* Creates one 4×4 frame centred at (10,10) and 3 circles *only* when the board has no frames yet.

```bash
# Re-run seeds safely
$ docker compose run --rm app bundle exec rails db:seed
```

---
## 5. REST API

```text
POST   /frames                     – create frame (+optional circles)
GET    /frames/:id                 – statistics for frame
DELETE /frames/:id                 – delete frame if it has no circles
POST   /frames/:id/circles         – add circle to frame

GET    /circles                    – spatial search (query params)
PUT    /circles/:id                – move / resize a circle
DELETE /circles/:id                – delete circle
```

### 5.1 Examples

Create a frame with two circles:
```bash
curl -X POST http://localhost:3000/frames \
     -H 'Content-Type: application/json' \
     -d '{
          "frame": {
            "board_id": 1,
            "center_x": 10,
            "center_y": 10,
            "width": 4,
            "height": 4
          },
          "circles": [
            {"center_x": 9, "center_y": 9, "radius": 0.8},
            {"center_x": 11, "center_y": 11, "radius": 0.6}
          ]
        }'
```

Move a circle:
```bash
curl -X PUT http://localhost:3000/circles/12 \
     -H 'Content-Type: application/json' \
     -d '{"circle":{"center_x":10.5,"center_y":10.5}}'
```

Spatial query (all frames):
```bash
curl "http://localhost:3000/circles?center_x=10&center_y=10&radius=2"
```

Spatial query limited to a frame:
```bash
curl "http://localhost:3000/circles?center_x=10&center_y=10&radius=2&frame_id=5"
```

---
## 6. Useful Docker commands

```bash
# Rails console (development DB)
docker compose run --rm app bundle exec rails console

# Run a one-off migration
docker compose run --rm app bundle exec rails db:migrate

# Rebuild image after Gemfile changes
docker compose build
```

---
## 7. Architecture highlights

* **PostGIS** geometry (`geometry`, `st_point`) with GiST indexes.
* Model validations use spatial SQL (`ST_DWithin`, `ST_Intersects`, `ST_Covers`).
* Service objects:
  * `FrameBuilder` – converts width/height + center into a polygon.
  * `FrameStats`   – aggregates min/max circle positions.
* RSpec + FactoryBot + Shoulda-Matchers.

Enjoy hacking! 🚀
