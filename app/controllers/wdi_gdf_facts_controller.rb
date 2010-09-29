class WdiGdfFactsController < ApplicationController
  def index
    example = WdiGdfFnote.find(:all, :order => 'RAND()', :limit =>4)

    i=0

    @exx2=[]

    example.each do |ex|

      example2 = WdiGdfFact.find(:all,
          :select => "country_name, series_name, period_value, data_value",
          :conditions =>[
		"data_value != ? AND country_code = ? AND series_code = ?", 
		'', ex.country_code, ex.series_code])

      exx_i = example2.sample
      exx_i.data_value = exx_i.data_value.round(1)

      @exx2.push exx_i

      i+=1
    end
  end
  def find
        @ver =WdiGdfCountry.find(:first,
                :select => "country_code, country_name",
                :conditions =>
                ["country_name = ? OR country_code = ?",
                params[:search_string],
                params[:search_string]])
        if @ver.nil?
        then
    	 example = WdiGdfFnote.find(:all, :order => 'RAND()', :limit =>4)
    	 i=0
    	 @exx2=[]
    	 example.each do |ex|
      	  example2 = WdiGdfFact.find(:all,
          	:select => "country_name, series_name, period_value, data_value",
          	:conditions =>[
			"data_value != ? AND country_code = ? AND series_code = ?", 
			'', ex.country_code, ex.series_code])
      	  exx_i = example2.sample
      	  exx_i.data_value = exx_i.data_value.round(1)
      	  @exx2.push exx_i
      	  i+=1
    	 end
	 render :action => "index"
	 return
        else
                if params[:search_string].match(/[A-Z]{3}/).nil?
                then @country_name = params[:search_string]
                        @example = WdiGdfFact.find(:all,
                                :select =>"series_code, series_name, country_code, country_name, period_value, data_value",
                                :conditions =>
                                ["country_name = ? AND period_value = ?",
                                params[:search_string],
                                2007])
                        @country = @example[0].country_code
                else @country = params[:search_string]
                        @example = WdiGdfFact.find(:all,
                                :select =>"series_code, series_name, country_code, country_name, period_value, data_value",
                                :conditions =>
                                ["country_code = ? AND period_value = ?",
                                params[:search_string],
                                2007])
                        @country_name = @example[0].country_name
                end
                params[:target_country_code] = @country
        end
  end
  def detail
        @detail = WdiGdfFact.find(:all,
                :conditions=>
                ["country_code = ? AND series_code = ?",
                 params[:target_country_code],
                 params[:target_series_code]
                ])
        @series = params[:target_series_code]
        @country = params[:target_country_code]
        country = WdiGdfCountry.find(:first,
                        :select => "country_name, region, income_group, lending_category",
                        :conditions => ["country_code = ?", params[:target_country_code]]
                        )
        @country_name = country.country_name
        @country_region = country.region
        @country_income_group = country.income_group
        @country_lending_category = country.lending_category
        series = WdiGdfSeries.find(:first,
                        :select => "series_name, long_definition, topic, subtopic1",
                        :conditions => ["series_code = ?", params[:target_series_code]]
                        )
        @series_name = series.series_name
        @series_definition = series.long_definition
        @series_topic = series.topic
        @series_subtopic1 = series.subtopic1
  end

end