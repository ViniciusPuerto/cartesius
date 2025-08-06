require "rails_helper"

RSpec.describe FrameStats do
  let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }
  let!(:frame)  { create(:frame, origin_x: 10, origin_y: 10, side_length: 4) } # center at 12,12

  before do
    frame.circles.create!(radius: 0.5, center: factory.point(12, 13.5))  # highest within frame
    frame.circles.create!(radius: 0.5, center: factory.point(12, 10.5))  # lowest within frame
    frame.circles.create!(radius: 0.5, center: factory.point(10.5, 12))  # leftmost within frame
    frame.circles.create!(radius: 0.5, center: factory.point(13.5, 12))  # rightmost within frame
  end

  subject { described_class.new(frame).call }

  it "returns center coordinates" do
    expect(subject[:x]).to eq(frame.center.x)
    expect(subject[:y]).to eq(frame.center.y)
  end

  it "counts circles" do
    expect(subject[:circles_total]).to eq(4)
  end

  it "finds highest, lowest, leftmost and rightmost circles" do
    expect(subject[:highest_circle]).to eq({ x: 12.0, y: 13.5 })
    expect(subject[:lowest_circle]).to  eq({ x: 12.0, y: 10.5 })
    expect(subject[:leftmost_circle]).to  eq({ x: 10.5, y: 12.0 })
    expect(subject[:rightmost_circle]).to eq({ x: 13.5, y: 12.0 })
  end
end
