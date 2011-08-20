class WdiGdfFactsController < ApplicationController
  def index
	@title = 'Welcome to DataClouds.net!'
  end


  def general_search
    if params[:search_words].nil? || params[:search_words].empty? then
       redirect_to(:controller=>"wdi_gdf_facts", :action=>"index") 
       flash[:message_1] = "Please specify your keywords."
	 end
   if params[:facet_topic] then
      ex_facets = WdiGdfFact.facets params[:search_words],
                                           :match_mode => :extended2,
                                           :group_by => 'series_code',
                                           :group_function => :attr,
                                           :group_clause =>"@count desc",
                                           :page => params[:page],
                                           :per_page => 250
    ser_ex = WdiGdfSeries.where('topic=?',params[:facet_topic]).select('subtopic1').map{|x| x.subtopic1}.uniq
    @result_subfacets = ex_facets[:series_subtopic].to_a.select{|y| ser_ex.include?(y[0])}
    @result_gs = ex_facets.for(:series_topic => params[:facet_topic])
         @search_words = ex_facets.args[0]
         @title = 'General Search Results for ' + "'"+ @search_words +"'" + ' within Topic: ' + "'" + params[:facet_topic] + "'"+'  : DataClouds.net Alpha'
  elsif params[:facet_subtopic] then
    ex_facets = WdiGdfFact.facets params[:search_words],
                                         :match_mode => :extended2,
                                         :group_by => 'series_code',
                                         :group_function => :attr,
                                         :group_clause =>"@count desc",
                                         :page => params[:page],
                                         :per_page => 250
    @result_gs = ex_facets.for(:series_subtopic => params[:facet_subtopic])
        @search_words = ex_facets.args[0]
        @title = 'General Search Results for ' + "'"+ @search_words +"'" + ' within Subopic: ' + "'" + params[:facet_subtopic] + "'"+'  : DataClouds.net Alpha'    
  else
        ex_gs = WdiGdfFact.search params[:search_words],
                                         :match_mode => :extended2,
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
            @result_facets = ex_gs.facets.values[0].to_a
            @result_gs = ex_gs
            @search_words = @result_gs.args[0]
            #@title = 'General Search Results for ' + "'"+ @search_words +"'"+' : DataClouds.net Alpha'
        end
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
    if params[:search_string].nil? || params[:search_string].empty? then
       redirect_to(:controller=>"wdi_gdf_facts", :action=>"index") 
       flash[:message_2] = "Please specify your keywords."
	end
        ver =WdiGdfCountry.
			  where('country_name LIKE ? OR country_code LIKE ?', 
			  params[:search_string], params[:search_string]).
			  first
        if ver.nil?
        then
	     params[:search_string]=''
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
    if params[:period].nil? || params[:period].empty? then params[:period]=2008 
       flash[:message_5] = "You may change the period between 1960 and 2010."
	end
    if params[:target_country_code].nil? || params[:target_country_code].empty? then params[:target_country_code]='WLD' 
       flash[:message_4] = "Please specify your target Area/Country."
	end

#Old codes
#    ex_overview = WdiGdfFact.select('wdi_gdf_facts.series_code, wdi_gdf_facts.series_name, wdi_gdf_facts.country_code, wdi_gdf_facts.country_name, wdi_gdf_facts.period_value, wdi_gdf_facts.data_value, wdi_gdf_series.overview').
#                             where('country_code =? AND 
#                                    overview !=? AND 
#                                    data_value !=? AND 
#                                    period_value =?', 
#                                    params[:target_country_code], '', '', params[:period]).
#                                    joins('left join wdi_gdf_series on wdi_gdf_series.id = series_id').
#                                    order('overview')

    ex_overview = WdiGdfFact.select('wdi_gdf_facts.series_code,
                                    wdi_gdf_facts.series_name,
                                    wdi_gdf_facts.country_code,
                                    wdi_gdf_facts.country_name,
                                    wdi_gdf_facts.data_value,
                                    wdi_gdf_facts.period_value').
                              where('wdi_gdf_facts.country_code =? AND
                                    overview !=? AND
                                    data_value !=? AND
                                    period_value =?', params[:target_country_code], '', '', params[:period]).
                              joins('left join wdi_gdf_series on wdi_gdf_facts.series_code=wdi_gdf_series.series_code').
                              order('overview')

    
#    @overview = ex_overview.sort_by{|ex| ex.overview.to_i}
    @overview = ex_overview
	  @country = ex_overview[0].country_code
	  @period = params[:period]
	  @country_name = ex_overview[0].country_name
	  @title = 'Summary for '+"'"+@country_name+"'"+': DataClouds.net Alpha'
  end


  def show
    if params[:target_country_code].nil? || params[:target_country_code].empty? then 
      params[:target_country_code]='WLD' 
      flash[:message_4] = "Please specify your target Area/Country." end

  	@country = params[:target_country_code]

	  subt = CGI.unescape(params[:target_subtopic])

    # from wdi_gdf_fact, retrieve rows with trgt_country_code and trgt_subtopic1, 
    # joining with show_ref, materialized-view table.
    c_subt_ex_min = WdiGdfFact.
        select('wdi_gdf_facts.series_code,
                wdi_gdf_facts.series_name,
                wdi_gdf_facts.country_code,
                wdi_gdf_facts.country_name,
                wdi_gdf_facts.data_value,
                wdi_gdf_facts.period_value,
                wdi_gdf_facts.showref_id').
        where('show_refs.country_code=? AND show_refs.subtopic1=?', @country, subt).
        joins('left join show_refs 
                on show_refs.series_code=wdi_gdf_facts.series_code 
                and show_refs.country_code=wdi_gdf_facts.country_code
                and show_refs.period_min=wdi_gdf_facts.period_value')

    c_subt_ex_max = WdiGdfFact.
        select('wdi_gdf_facts.data_value,
                wdi_gdf_facts.period_value,
                wdi_gdf_facts.showref_id').
        where('show_refs.country_code=? AND show_refs.subtopic1=?', @country, subt).
        joins('left join show_refs 
                on show_refs.series_code=wdi_gdf_facts.series_code 
                and show_refs.country_code=wdi_gdf_facts.country_code
                and show_refs.period_max=wdi_gdf_facts.period_value')

	  @country_series_value = []

    c_subt_ex_min.each do |ex_min|
      c_subt_ex_max.each do |ex_max|
        if ex_min.showref_id==ex_max.showref_id then
        element = [ex_min.series_code,ex_min.series_name,ex_min.period_value,ex_min.data_value,ex_max.period_value,ex_max.data_value]
        else next
        end

			  @country_series_value.push element

			end
	  end
  	@country_name = c_subt_ex_min[0].country_name
  	@subtopic = CGI.unescape(params[:target_subtopic])
	  @title = 'Series on '+"'"+@country_name+"'"+' & '+"'"+@subtopic +"'"+': DataClouds.net Alpha'
  end


  def detail
    if params[:target_country_code].nil? || params[:target_country_code].empty? then params[:target_country_code]='WLD' 
       flash[:message_4] = "Please specify your target Area/Country."
	  end
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
									long_definition,
									wdi",
                        :conditions => ["wdi_gdf_series.series_code = ?", 
										params[:target_series_code]]
                        )
		@title = "'"+@s_parts.series_name+"'"+' of '+"'"+@c_ex.country_name+"'"+': DataClouds.net Alpha'
		@chart_style = params[:chart_style]
		@chart_style = 'BarChart' if @chart_style.nil?
		if @s_parts.wdi=='WDI' then @source = 'WDI' else @source = 'GDF' end
  end
  def globalcompare
    if params[:period].nil? || params[:period].empty? then params[:period]=2008 
       flash[:message_5] = "You may change the period between 1960 and 2009."
	end
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

		@A_for_Graph = Array.new
        
		@g_comp_country.each do |g|
			if g.data_value.nil? || g.data_value==0 || g.nil? then next end
		
		  @A_for_Graph.push [g.country_name, g.data_value]
		
		end
		@A_for_Graph = @A_for_Graph.sort_by{|ex| ex[1]}

    @chart_style = params[:chart_style]
    @chart_style = 'BarChart' if @chart_style.nil?
	@series_name = @g_comp_country[0].series_name
	@period = params[:period]
    @series = params[:target_series_code]
	@title = 'Global Comparison on '+"'"+@g_comp_country[0].series_name+"'"+': DataClouds.net Alpha'
  end


end
