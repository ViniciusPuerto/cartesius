# frozen_string_literal: true

require "rails_helper"

RSpec.describe Board, type: :model do
  context "validations" do
    it "is invalid without a name" do
      board = Board.new(name: nil)
      expect(board).not_to be_valid
      expect(board.errors[:name]).to include("can't be blank")
    end

    it "is invalid with a duplicate name" do
      Board.create!(name: "Main")
      duplicate = Board.new(name: "Main")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "is valid with a unique name" do
      board = Board.new(name: "Secondary")
      expect(board).to be_valid
    end
  end
end
