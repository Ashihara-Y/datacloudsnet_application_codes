class WdiGdfFactsController < ApplicationController
  def index
	@title = 'Welcome to DataClouds.net!'
  end
  def general_search
		ex_gs = WdiGdfFact.search params[:search_words], 
		                                 :match_mode => :extended2,
		                                 #:group_by => 'country_code',
		                                 :group_by => 'series_code',
		                                 :group_function => :attr,
		                                 :group_clause => "@count desc",
		                                 :page => params[:page],
		                                 :per_page => 250

        if ex_gs.length==0
        then
          redirect_to(:controller=>"wdi_gdf_facts", :action=>"index")
          flash[:message_1] = "Sorry, we have no data for such keywords."
        else           
            @result_gs = ex_gs
            @result_facets = ex_gs.facets
			@search_words = @result_gs.args[0]
            @title = 'General Search Results for +"'"+@search_words+"'": DataClouds.net Alpha'
            #session[:search_words] = params[:search_words]
            #@result_gs_total_length = ex_gs.total_entries
        end
  end
  def search
		ex_s = WdiGdfSeries.find_by_sql(["select * from wdi_gdf_series where match(series_name) against(?) order by subtopic1", params[:search_words]])

		if ex_s.length==0
		then
	     redirect_to(:controller=>"wdi_gdf_facts", :action=>"index")
         flash[:message_3] = "Sorry, we have no data for such keyword."
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
        ver =WdiGdfCountry.
			  where('country_name LIKE ? OR country_code LIKE ?', 
			  params[:search_string], params[:search_string]).
			  first
        if ver.nil?
        then
	     redirect_to(:controller=>"wdi_gdf_facts", :action=>"index")
         flash[:message_2] = "Sorry, we have no data for such keyword."
        else
               if params[:search_string].match(/[A-Z]{3}/).nil?
                then 
					@country_name = ver.country_name
					c_s = ver.
						  wdi_gdf_series.
						  select('topic, subtopic1, wdi_gdf_series.series_code').
						  where('period_value=?',2000)
					c_s_subtopic_list = c_s.map{|ex| ex.subtopic1 }.uniq
					c_sub_a =[]				
					c_s_subtopic_list.each do |ex|
						count = c_s.select{|x| x.subtopic1==ex}.count
						topic = c_s.select{|y| y.subtopic1==ex}[0].topic
						c_sub_a.push [ex, count, topic]
					end
					@c_subtopic_list = c_sub_a.sort_by{|e| e[2]}                
					@country = ver.country_code
                else @country = ver.country_code
					c_s = ver.
						  wdi_gdf_series.
			     		  where('period_value=?',2000).
						  select('topic, subtopic1, wdi_gdf_series.series_code')
					c_s_subtopic_list = c_s.map{|ex| ex.subtopic1}.uniq
					c_sub_a = []
					c_s_subtopic_list.each do |ex|
						count = c_s.select{|x| x.subtopic1==ex}.count
						topic = c_s.select{|y| y.subtopic1==ex}[0].topic
						c_sub_a.push [ex, count, topic]
					end
					@c_subtopic_list = c_sub_a.sort_by{|e| e[2] }
                	@country_name = ver.country_name
                end
                params[:target_country_code] = @country
				@title = 'Topic list for '+"'"+@country_name+"'"+': DataClouds.net Alpha'
        end
  end
  def summary
    if params[:period].nil? then params[:period]=2008 end
    ex_overview = WdiGdfFact.select('wdi_gdf_facts.series_code, wdi_gdf_facts.series_name, wdi_gdf_facts.country_code, wdi_gdf_facts.country_name, wdi_gdf_facts.period_value, wdi_gdf_facts.data_value, wdi_gdf_series.overview').
                             where('country_code =? AND 
                                    overview >=? AND 
                                    data_value !=? AND 
                                    period_value =?', 
                                    params[:target_country_code], 1, '', params[:period]).
                                    joins('left join wdi_gdf_series on wdi_gdf_series.id = series_id')
    
    @overview = ex_overview.sort_by{|ex| ex.overview.to_i}
	@country = ex_overview[0].country_code
	@period = params[:period]
	@country_name = ex_overview[0].country_name
	@title = 'Summary for '+"'"+@country_name+"'"+': DataClouds.net Alpha'
  end
  def show
  	@country = params[:target_country_code]
    #c_ex = WdiGdfCountry.where('country_code=?', @country).first
	subt = CGI.unescape(params[:target_subtopic])
  	c_subt_ex = WdiGdfFact.
				select('series_id, 
						period_value, 
						data_value,
						country_name').
				where('country_code=? AND subtopic1=? AND data_value !=?', @country,subt,'').
				joins('left join wdi_gdf_series on wdi_gdf_series.id=series_id').
				order('period_value')
   	series_ex = WdiGdfSeries.
				where('subtopic1=?', subt).
				select('id, series_code, series_name')
	#s_id_ex = series_ex.map{|x| x.id}
	@country_series_value = []
	series_ex.each do |ex|
			c_s_ex = c_subt_ex.select{|x| x.series_id==ex.id }
			if c_s_ex[0].nil? then next else
				oldest_v  = c_s_ex[0].data_value
				oldest_p  = c_s_ex[0].period_value
				current_v = c_s_ex.last.
						   data_value
				current_p = c_s_ex.last.
						   period_value
				element = []
				element.push ex.series_code,
							 ex.series_name,
							 oldest_p,
							 oldest_v,
							 current_p,
							 current_v
				@country_series_value.push element
			end
	end
  	@country_name = c_subt_ex[0].country_name
  	@subtopic = CGI.unescape(params[:target_subtopic])
	@title = 'Series on '+"'"+@country_name+"'"+' & '+"'"+@subtopic +"'"+': DataClouds.net Alpha'
  end
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
		@A_for_Graph = @A_for_Graph.sort_by{|ex| ex[0]}
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
  def globalcompare
    if params[:period].nil? then params[:period] = 2008 end
    @g_comp_country = WdiGdfFact.select('wdi_gdf_facts.country_name, 	
										wdi_gdf_facts.country_code, 
										series_code, 
										series_name, 
										data_value').
                              order('data_value desc').
                              where('series_code =? AND period_value =? AND region !=?', 
	                              params[:target_series_code],
	                              params[:period],
	                              'Aggregates').
                              joins('left join wdi_gdf_countries 
									on wdi_gdf_countries.id = wdi_gdf_facts.country_id')

    @chart_style = params[:chart_style]
    @chart_style = 'BarChart' if @chart_style.nil?
	@series_name = @g_comp_country[0].series_name
	@period = params[:period]
    @series = params[:target_series_code]
	@title = 'Global Comparison on'+"'"+@g_comp_country[0].series_name+"'"+': DataClouds.net Alpha'
  end


end
