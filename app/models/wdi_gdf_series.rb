class WdiGdfSeries < ActiveRecord::Base
	has_many :wdi_gdf_facts, :foreign_key => :series_id
	has_many :wdi_gdf_csnotes, :foreign_key => :csnote_id
	has_many :wdi_gdf_fnotes, :foreign_key => :fnote_id
end
