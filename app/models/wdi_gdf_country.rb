class WdiGdfCountry < ActiveRecord::Base
	has_many :wdi_gdf_facts, :foreign_key => :country_id
#	has_many :csnotes
#	has_many :fnotes
end
