require "rails_helper"

RSpec.describe "Circle delete API", type: :request do
  describe "DELETE /circles/:id" do
    let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }
    let!(:frame)  { create(:frame, origin_x: 0, origin_y: 0, side_length: 2) }
    let!(:circle) { frame.circles.create!(radius: 0.5, center: factory.point(1, 1)) }

    it "deletes the circle and returns 204" do
      expect do
        delete "/circles/#{circle.id}", as: :json
      end.to change(Circle, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for nonexistent circle" do
      delete "/circles/999999", as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
