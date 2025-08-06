require "rails_helper"

RSpec.describe "Frames API", type: :request do
  describe "POST /frames" do
    let!(:board) { create(:board) }

    # before { host! "example.org" }

    context "with valid parameters" do
      let(:valid_params) do
        {
          frame: {
            board_id: board.id,
            center_x: 10,
            center_y: 10,
            width:    2,
            height:   3
          }
        }
      end

      it "creates a new frame and returns 201" do
        post "/frames", params: valid_params, as: :json
        expect(response).to have_http_status(:created)
        expect(Frame.count).to eq(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["id"]).to be_present
        expect(json["board_id"]).to eq(board.id)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        {
          frame: {
            board_id: board.id,
            center_x: 10,
            center_y: 10,
            width:    0,
            height:   3
          }
        }
      end

      it "does not create a frame and returns 422" do
        expect do
          post "/frames", params: invalid_params, as: :json, headers: { "HOST" => "example.org" }
        end.not_to change(Frame, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_an(Array)
      end
    end
  end
end
