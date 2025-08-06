# frozen_string_literal: true

class EnablePostgis < ActiveRecord::Migration[8.0]
  def change
    enable_extension "postgis"
  end
end
