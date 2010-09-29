class AddSeriesForeignKeys < ActiveRecord::Migration
  def self.up
	remove_column :facts, :series_id
	add_column :facts, :series_id, :integer
  end

  def self.down
	remove_column :facts, :series_id
  end
end
