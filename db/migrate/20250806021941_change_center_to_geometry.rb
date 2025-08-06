class ChangeCenterToGeometry < ActiveRecord::Migration[8.0]
  def change
    change_column :frames, :center, :st_point, null: false, srid: 0
  end
end