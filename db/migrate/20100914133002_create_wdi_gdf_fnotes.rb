class CreateWdiGdfFnotes < ActiveRecord::Migration
  def self.up
    create_table :wdi_gdf_fnotes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :wdi_gdf_fnotes
  end
end
