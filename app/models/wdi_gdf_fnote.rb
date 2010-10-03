class WdiGdfFnote < ActiveRecord::Base
	belongs_to :wdi_gdf_country, :foreign_key => 'country_id'
	belongs_to :wdi_gdf_series, :foreign_key => 'series_id'
	belongs_to :wdi_gdf_fact, :foreign_key => 'fact_id'
end
