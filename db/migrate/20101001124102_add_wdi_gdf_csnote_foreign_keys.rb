class AddWdiGdfCsnoteForeignKeys < ActiveRecord::Migration
  def self.up
	add_column :wdi_gdf_csnotes, :country_id, :integer
	add_column :wdi_gdf_csnotes, :series_id, :integer
  end

  def self.down
	remove_column :wdi_gdf_csnotes, :country_id
	remove_column :wdi_gdf_csnotes, :series_id
  end
end
