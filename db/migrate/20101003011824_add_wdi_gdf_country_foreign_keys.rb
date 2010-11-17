class AddWdiGdfCountryForeignKeys < ActiveRecord::Migration
  def self.up
	add_column :wdi_gdf_csnotes, :country_id, :integer
	add_column :wdi_gdf_fnotes, :country_id, :integer
  end

  def self.down
	remove_column :wdi_gdf_csnotes, :country_id
	remove_column :wdi_gdf_fnotes, :country_id
  end
end
