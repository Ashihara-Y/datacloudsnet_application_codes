class ShowRef < ActiveRecord::Base
	has_many :wdi_gdf_facts, :foreign_key => 'showref_id'

end
