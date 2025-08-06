require "rails_helper"

RSpec.describe "Circle search API", type: :request do
  describe "GET /circles" do
    let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }
    let!(:frame1) { create(:frame, origin_x: 0, origin_y: 0, side_length: 4) }
    let!(:frame2) { create(:frame, origin_x: 10, origin_y: 10, side_length: 4) }

    let!(:circle1) { frame1.circles.create!(radius: 0.5, center: factory.point(1, 1)) }
    let!(:circle2) { frame1.circles.create!(radius: 0.5, center: factory.point(2, 2)) }
    let!(:circle3) { frame2.circles.create!(radius: 0.5, center: factory.point(11, 11)) }

    it "returns circles within radius across all frames" do
      get "/circles", params: { center_x: 1, center_y: 1, radius: 1.5 }
      expect(response).to have_http_status(:ok)
      ids = JSON.parse(response.body).map { |c| c["id"] }
      expect(ids).to match_array([circle1.id, circle2.id])
    end

    it "filters by frame_id" do
      get "/circles", params: { center_x: 11, center_y: 11, radius: 2, frame_id: frame2.id }
      expect(response).to have_http_status(:ok)
      ids = JSON.parse(response.body).map { |c| c["id"] }
      expect(ids).to eq([circle3.id])
    end

    it "returns 422 when required params missing" do
      get "/circles", params: { center_x: 0 }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
