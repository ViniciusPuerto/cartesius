require "rails_helper"

RSpec.describe "Frame show API", type: :request do
  describe "GET /frames/:id" do
    let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }
    let!(:frame)  { create(:frame, origin_x: 0, origin_y: 0, side_length: 4) } # center 2,2

    before do
      frame.circles.create!(radius: 0.5, center: factory.point(2, 3))  # highest
      frame.circles.create!(radius: 0.5, center: factory.point(2, 1))  # lowest
      frame.circles.create!(radius: 0.5, center: factory.point(0.5, 2))  # leftmost
      frame.circles.create!(radius: 0.5, center: factory.point(3.5, 2))  # rightmost
    end

    it "returns stats json" do
      get "/frames/#{frame.id}", as: :json
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["circles_total"]).to eq(4)
      expect(json["highest_circle"]).to eq({"x"=>2.0, "y"=>3.0})
      expect(json["lowest_circle"]).to  eq({"x"=>2.0, "y"=>1.0})
      expect(json["leftmost_circle"]).to eq({"x"=>0.5, "y"=>2.0})
      expect(json["rightmost_circle"]).to eq({"x"=>3.5, "y"=>2.0})
    end
  end
end
