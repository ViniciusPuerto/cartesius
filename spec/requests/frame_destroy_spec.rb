require "rails_helper"

RSpec.describe "Frame delete API", type: :request do
  describe "DELETE /frames/:id" do
    let(:factory) { RGeo::Cartesian.simple_factory(srid: 0) }

    context "when frame has no circles" do
      let!(:frame) { create(:frame, origin_x: 0, origin_y: 0, side_length: 2) }

      it "deletes the frame and returns 204" do
        expect do
          delete "/frames/#{frame.id}", as: :json
        end.to change(Frame, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when frame has circles" do
      let!(:frame) { create(:frame, origin_x: 0, origin_y: 0, side_length: 2) }

      before do
        frame.circles.create!(radius: 0.5, center: factory.point(1, 1))
      end

      it "does not delete the frame and returns 422" do
        expect do
          delete "/frames/#{frame.id}", as: :json
        end.not_to change(Frame, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include(/Cannot delete frame/i)
      end
    end
  end
end
