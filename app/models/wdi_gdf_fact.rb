class WdiGdfFact < ActiveRecord::Base
	belongs_to :wdi_gdf_country, :foreign_key => 'country_id'
	belongs_to :wdi_gdf_series, :foreign_key => 'series_id'
	belongs_to :show_ref, :foreign_key => 'showref_id'
	has_many :wdi_gdf_fnotes, :foreign_key => 'fact_id'

	define_index do
		indexes country_name, :sortable => true
		indexes series_name, :sortable => true
		indexes wdi_gdf_series.topic, :as => :series_topic, :facet => true
		indexes wdi_gdf_series.subtopic1, :as => :series_subtopic, :facet => true

		has country_code, series_code
	end
end
