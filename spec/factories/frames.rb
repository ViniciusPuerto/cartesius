# frozen_string_literal: true

FactoryBot.define do
  factory :frame do
    association :board

    transient do
      side_length { 1.0 }
      origin_x { 0.0 }
      origin_y { 0.0 }
    end

    # Use RGeo factory to build square polygon and its centroid
    shape do
      factory = RGeo::Cartesian.simple_factory(srid: 0)
      ring = factory.linear_ring([
        factory.point(origin_x, origin_y),
        factory.point(origin_x + side_length, origin_y),
        factory.point(origin_x + side_length, origin_y + side_length),
        factory.point(origin_x, origin_y + side_length),
        factory.point(origin_x, origin_y)
      ])
      factory.polygon(ring)
    end

    center do
      factory = RGeo::Cartesian.simple_factory(srid: 0)
      factory.point(origin_x + side_length / 2.0, origin_y + side_length / 2.0)
    end
  end
end
