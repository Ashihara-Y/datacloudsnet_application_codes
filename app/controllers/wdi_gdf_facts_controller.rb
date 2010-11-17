class WdiGdfFactsController < ApplicationController
  def index

    exx = WdiGdfFnote.find(:all, 
		:select => "country_code, series_code", 
		:order => 'RAND()',
		:limit => 5)

    i=0

    ex3=[]
    @exx2=[]

    exx.each do |ex|

      example2 = WdiGdfFact.find(:all,
          	:select => "country_name, series_name, period_value, data_value",
          	:conditions =>["data_value != ? AND country_code = ? AND series_code = ?", 
			'', ex.country_code, ex.series_code])

      ex1_i = example2.last
      ex2_i = example2.sample while ex2_i.nil?
      ex1_i.data_value = ex1_i.data_value.round(2)
      ex2_i.data_value = ex2_i.data_value.round(2)

      exx_i = Array.new
      exx_i.push ex2_i.country_name,
		 ex2_i.series_name,
		 ex2_i.period_value,
		 ex2_i.data_value,
		 ex1_i.period_value,
		 ex1_i.data_value

      ex3.push exx_i

      i+=1
    end

    @exx2 = ex3

  end
  def search
		ex_s = WdiGdfSeries.find_by_sql(["select * from wdi_gdf_series where match(series_name) against(?) order by subtopic1", params[:search_words]])

		if ex_s.nil?
		then
	     redirect_to(:controller=>"wdi_gdf_facts", :action=>"index")
         flash[:message] = "Sorry, we have no data for such keyword."
        else
			@result_s = Array.new
			 ex_s.each do |ex|
			 	@result_s.push [ex.series_name,ex.series_code,ex.topic,ex.subtopic1]
			 end
			
			@result_subtopic_list= WdiGdfSeries.find_by_sql(["select subtopic1, count(*) from wdi_gdf_series where match(series_name) against(?) group by subtopic1", params[:search_words]])
		@title = 'Results for '+"'"+params[:search_words]+"'"+': DataClouds.net Alpha'
		end
  end
  def list
        @ver =WdiGdfCountry.find(:first,
                :select => "country_code, country_name",
                :conditions =>
                ["country_name = ? OR country_code = ?",
                params[:search_string],
                params[:search_string]])
        if @ver.nil?
        then
	     redirect_to(:controller=>"wdi_gdf_facts", :action=>"index")
         flash[:message] = "Sorry, we have no data for such keyword."
        else
               if params[:search_string].match(/[A-Z]{3}/).nil?
                then @country_name = params[:search_string]
		        country_examp = WdiGdfCountry.find(:first, 
				:conditions => ["country_name = ?", params[:search_string]])
        		@c_subtopic_list=country_examp.wdi_gdf_series.count(:all,
                                :group => 'subtopic1',
                                :conditions => ["period_value = ?", 2009])
                      @country = country_examp.country_code
                 else @country = params[:search_string]
		        country_examp = WdiGdfCountry.find(:first, 
				:conditions => ["country_code = ?", params[:search_string]])
        		@c_subtopic_list=country_examp.wdi_gdf_series.count(:all,
                                :group => 'subtopic1',
                                :conditions => ["period_value = ?", 2009])
                      @country_name = country_examp.country_name
                end
                params[:target_country_code] = @country
				@title = 'Topic list for '+"'"+@country_name+"'"+': DataClouds.net Alpha'
        end
  end

  def show
  	@country = params[:target_country_code]
  	country_examp = WdiGdfCountry.find(:first,
   		:conditions => ["country_code = ?", params[:target_country_code]])

  	@country_name = country_examp.country_name
  	@subtopic = params[:target_subtopic]
	@title = 'Series on '+"'"+@country_name+"'"+' & '+"'"+@subtopic +"'"+': DataClouds.net Alpha'
  	@country_series_list=country_examp.wdi_gdf_series.find(:all,
            	:select=>"wdi_gdf_series.series_code, 
                          wdi_gdf_series.series_name, 
                          wdi_gdf_series.topic, 
                          wdi_gdf_series.subtopic1", 
            	:group => 'wdi_gdf_series.series_code',
            	:conditions => ["subtopic1 = ?", params[:target_subtopic]])

	@country_series_value = Array.new

    @country_series_list.each do |element|

		element_values = country_examp.wdi_gdf_facts.find(:all,
			:select => "series_code, series_name, period_value, data_value",
			:order => 'period_value',
			:conditions =>["series_code = ? AND data_value != ?", element.series_code, ''])

		element_last_value = element_values.last
		element_oldest_value= element_values.first

		country_series_value = Array.new
		country_series_value.push element_oldest_value.series_code,
								  element_oldest_value.series_name,
								  element_oldest_value.period_value,
								  element_oldest_value.data_value,
								  element_last_value.period_value,
								  element_last_value.data_value

		@country_series_value.push country_series_value
	    end
  end
=begin
=end
  def detail
        @detail = WdiGdfFact.find(:all,
				:select => "period_value, data_value",
				:order => 'period_value DESC',
                :conditions=>
                ["country_code = ? AND series_code = ? AND data_value != ?",
                 params[:target_country_code],
                 params[:target_series_code], ''
                ])

		@A_for_Graph = Array.new
        
		@detail.each do |obs|
			@A_for_Graph.push [obs.period_value.to_s, obs.data_value]
		end

        @series = params[:target_series_code]
        @country = params[:target_country_code]
		@c_ex = WdiGdfCountry.find(:first,
                        :conditions => ["country_code = ?", 
										params[:target_country_code]]
                        )

        @s_parts = WdiGdfSeries.find(:first,
                        :select => "series_name,
									topic,
									subtopic1,
									long_definition",
                        :conditions => ["wdi_gdf_series.series_code = ?", 
										params[:target_series_code]]
                        )
		@title = "'"+@s_parts.series_name+"'"+' of '+"'"+@c_ex.country_name+"'"+': DataClouds.net Alpha'
		@chart_style = params[:chart_style]
		@chart_style = 'BarChart' if @chart_style.nil?
  end

end
