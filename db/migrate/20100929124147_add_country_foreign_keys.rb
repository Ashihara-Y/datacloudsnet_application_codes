class AddCountryForeignKeys < ActiveRecord::Migration
  def self.up
	remove_column :wdi_gdf_facts, :country_id
	add_column :wdi_gdf_facts, :country_id, :integer
  end

  def self.down
	remove_column :wdi_gdf_facts, :country_id
  end
end
