# frozen_string_literal: true

class CreateCircles < ActiveRecord::Migration[8.0]
  def change
    create_table :circles do |t|
      t.references :frame, null: false, foreign_key: true
      t.float :radius, null: false
      t.st_point :center, null: false, srid: 0

      t.timestamps
    end

    add_index :circles, :center, using: :gist
  end
end
