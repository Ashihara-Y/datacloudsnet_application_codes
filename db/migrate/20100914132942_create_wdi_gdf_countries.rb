class CreateWdiGdfCountries < ActiveRecord::Migration
  def self.up
    create_table :wdi_gdf_countries do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :wdi_gdf_countries
  end
end
