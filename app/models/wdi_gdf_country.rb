class WdiGdfCountry < ActiveRecord::Base
	has_many :wdi_gdf_facts, :foreign_key => 'country_id'
	has_many :wdi_gdf_csnotes, :foreign_key => 'country_id'
	has_many :wdi_gdf_fnotes, :foreign_key => 'country_id'
	has_many :wdi_gdf_series, :through => :wdi_gdf_facts
end
