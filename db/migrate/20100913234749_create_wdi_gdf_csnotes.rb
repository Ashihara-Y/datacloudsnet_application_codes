class CreateWdiGdfCsnotes < ActiveRecord::Migration
  def self.up
    create_table :wdi_gdf_csnotes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :wdi_gdf_csnotes
  end
end
