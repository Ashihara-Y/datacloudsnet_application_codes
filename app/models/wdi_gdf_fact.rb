class WdiGdfFact < ActiveRecord::Base
	belongs_to :wdi_gdf_country, :foreign_key => 'country_id'
	belongs_to :wdi_gdf_series, :foreign_key => 'series_id'
	has_many :wdi_gdf_fnotes, :foreign_key => 'fact_id'
end
