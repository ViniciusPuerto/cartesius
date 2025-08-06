# frozen_string_literal: true

class CreateFrames < ActiveRecord::Migration[8.0]
  def change
    create_table :frames do |t|
      t.references :board, null: false, foreign_key: true
    
      t.geometry :shape,  null: false, srid: 0
      t.st_point :center, null: false, srid: 0
    
      t.timestamps
    end
    
    add_index :frames, :shape, using: :gist
    end
end
