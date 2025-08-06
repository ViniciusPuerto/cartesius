require "rails_helper"

RSpec.describe "Circles API", type: :request do
  describe "POST /frames/:id/circles" do
    let!(:frame) { create(:frame, origin_x: 10, origin_y: 10, side_length: 2) }
    let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }

    context "with valid parameters" do
      let(:valid_params) do
        {
          circle: {
            center_x: 11,
            center_y: 11,
            radius: 0.5
          }
        }
      end

      it "creates a circle and returns 201" do
        expect do
          post "/frames/#{frame.id}/circles", params: valid_params, as: :json
        end.to change(Circle, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["id"]).to be_present
        expect(json["radius"]).to eq(0.5)
        expect(json["frame_id"]).to eq(frame.id)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          circle: {
            center_x: 0,   # outside the frame
            center_y: 0,
            radius: 0.5
          }
        }
      end

      it "does not create a circle and returns 422" do
        expect do
          post "/frames/#{frame.id}/circles", params: invalid_params, as: :json
        end.not_to change(Circle, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_an(Array)
      end
    end
  end
end
