# frozen_string_literal: true

# Idempotent seed data for development/production.
# Run with: bin/rails db:seed (already executed automatically on db:setup)

require "rgeo"

factory = RGeo::Cartesian.simple_factory(srid: 0)

puts "== Ensuring main board exists =="
board = Board.find_or_create_by!(name: "main")
puts "Board ##{board.id} (name=#{board.name})"

# -----------------------------------------------------------------------------
# Demo data – only generated if the board has no frames yet so re-running seeds
# doesn’t duplicate records.
# -----------------------------------------------------------------------------
if board.frames.none?
  puts "== Creating demo frame + circles =="

  side       = 4.0
  origin_x   = 8.0
  origin_y   = 8.0
  center_x   = origin_x + side / 2.0
  center_y   = origin_y + side / 2.0

  ring = factory.linear_ring([
    factory.point(origin_x,         origin_y),
    factory.point(origin_x + side,  origin_y),
    factory.point(origin_x + side,  origin_y + side),
    factory.point(origin_x,         origin_y + side),
    factory.point(origin_x,         origin_y)
  ])

  frame = board.frames.create!(
    shape:  factory.polygon(ring),
    center: factory.point(center_x, center_y)
  )

  puts "Created Frame ##{frame.id}"

  frame.circles.create!(radius: 0.8, center: factory.point(center_x - 1, center_y - 1))
  frame.circles.create!(radius: 0.6, center: factory.point(center_x + 1, center_y + 1))
  frame.circles.create!(radius: 0.5, center: factory.point(center_x,     center_y + 1.5))

  puts "Added 3 demo circles"
end

puts "== Seed finished =="