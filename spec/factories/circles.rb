# frozen_string_literal: true

FactoryBot.define do
  factory :circle do
    association :frame

    radius { 0.3 }

    center do
      factory = RGeo::Cartesian.simple_factory(srid: 0)
      frame_center = frame.center
      factory.point(frame_center.x, frame_center.y)
    end
  end
end
