class AddWdiGdfFactForeignKeys < ActiveRecord::Migration
  def self.up
	add_column :wdi_gdf_fnotes, :fact_id, :integer
  end

  def self.down
	remove_column :wdi_gdf_fnotes, :fact_id
  end
end
