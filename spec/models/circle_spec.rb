# frozen_string_literal: true

require "rails_helper"

RSpec.describe Circle, type: :model do
  subject { build(:circle) }

  it { is_expected.to belong_to(:frame) }
  it { is_expected.to validate_numericality_of(:radius).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:center) }

  describe "business rules" do
    let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }
    let!(:frame) do
      create(:frame, origin_x: 10, origin_y: 10, side_length: 2)
    end

    it "is invalid when overlapping another circle" do
      c1 = frame.circles.create!(radius: 0.5, center: factory.point(11, 11))
      c2 = frame.circles.build(radius: 0.6, center: factory.point(11.8, 11))
      expect(c2).not_to be_valid
      expect(c2.errors.to_a).to include(/overlaps/)
    end

    it "is invalid when outside the frame" do
      circle = frame.circles.build(radius: 1.2, center: factory.point(0.3, 0.3))
      expect(circle).not_to be_valid
      expect(circle.errors.to_a).to include(/fit inside/)
    end
  end
end
