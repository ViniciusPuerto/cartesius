# frozen_string_literal: true

require "rails_helper"

RSpec.describe Frame, type: :model do
  subject { build(:frame) if defined?(FactoryBot) }

  it { is_expected.to belong_to(:board) }
  it { is_expected.to validate_presence_of(:shape) }
  it { is_expected.to validate_presence_of(:center) }

  let(:board) { Board.create!(name: "Main") }
  let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }

  context "validations" do
    it "is invalid without a shape" do
      frame = Frame.new(board: board)
      expect(frame).not_to be_valid
      expect(frame.errors[:shape]).to include("can't be blank")
    end

    it "is valid with a polygon shape and center" do
      ring = factory.linear_ring([
        factory.point(0, 0),
        factory.point(1, 0),
        factory.point(1, 1),
        factory.point(0, 1),
        factory.point(0, 0)
      ])
      polygon = factory.polygon(ring)
      center_point = factory.point(0.5, 0.5)

      frame = Frame.new(board: board, shape: polygon, center: center_point)
      expect(frame).to be_valid
    end
  end
end
