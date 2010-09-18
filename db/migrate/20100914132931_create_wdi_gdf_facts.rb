class CreateWdiGdfFacts < ActiveRecord::Migration
  def self.up
    create_table :wdi_gdf_facts do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :wdi_gdf_facts
  end
end
