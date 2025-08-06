require "rails_helper"

RSpec.describe "Circle update API", type: :request do
  describe "PUT /circles/:id" do
    let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }
    let!(:frame)  { create(:frame, origin_x: 0, origin_y: 0, side_length: 4) }
    let!(:circle) { frame.circles.create!(radius: 0.5, center: factory.point(1, 1)) }

    context "with valid new position" do
      let(:valid_params) do
        {
          circle: {
            center_x: 2,
            center_y: 2
          }
        }
      end

      it "updates the circle and returns 200" do
        put "/circles/#{circle.id}", params: valid_params, as: :json
        expect(response).to have_http_status(:ok)
        circle.reload
        expect(circle.center.x).to eq(2.0)
        expect(circle.center.y).to eq(2.0)
      end
    end

    context "with invalid new position (outside frame)" do
      let(:invalid_params) do
        {
          circle: {
            center_x: 10,
            center_y: 10
          }
        }
      end

      it "does not update and returns 422" do
        put "/circles/#{circle.id}", params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        circle.reload
        expect(circle.center.x).to eq(1.0)
      end
    end
  end
end
