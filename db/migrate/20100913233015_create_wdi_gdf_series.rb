class CreateWdiGdfSeries < ActiveRecord::Migration
  def self.up
    create_table :wdi_gdf_series do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :wdi_gdf_series
  end
end
