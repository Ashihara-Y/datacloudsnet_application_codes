# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101003114219) do

  create_table "wdi_gdf_countries", :force => true do |t|
    t.string "country_code",                  :limit => 8,   :null => false
    t.string "country_name",                  :limit => 80,  :null => false
    t.string "region",                        :limit => 48,  :null => false
    t.string "income_group",                  :limit => 48,  :null => false
    t.string "lending_category",              :limit => 48,  :null => false
    t.string "currency_unit",                 :limit => 48
    t.string "nationalaccount_baseyear",      :limit => 120
    t.string "nationalaccount_referenceyear", :limit => 48
    t.string "latest_population_census",      :limit => 48
    t.string "latest_household_survey",       :limit => 48
    t.text   "specialnote"
  end

  add_index "wdi_gdf_countries", ["country_code", "region", "income_group", "lending_category"], :name => "country_code"
  add_index "wdi_gdf_countries", ["country_name"], :name => "country_name"

  create_table "wdi_gdf_csnotes", :force => true do |t|
    t.string  "country_code", :limit => 8,  :null => false
    t.string  "series_code",  :limit => 24, :null => false
    t.text    "note",                       :null => false
    t.integer "series_id"
    t.integer "country_id"
  end

  add_index "wdi_gdf_csnotes", ["country_code", "series_code"], :name => "country_code"

  create_table "wdi_gdf_facts", :force => true do |t|
    t.string  "series_code",  :limit => 24,  :null => false
    t.string  "series_name",  :limit => 200, :null => false
    t.string  "country_code", :limit => 8,   :null => false
    t.string  "country_name", :limit => 80,  :null => false
    t.integer "period_value", :limit => 2,   :null => false
    t.float   "data_value",   :limit => 64
    t.integer "country_id",   :limit => 8,   :null => false
    t.integer "series_id",    :limit => 8,   :null => false
  end

  add_index "wdi_gdf_facts", ["country_id", "series_id"], :name => "country_id"
  add_index "wdi_gdf_facts", ["series_code", "country_code"], :name => "series_code_2"
  add_index "wdi_gdf_facts", ["series_code"], :name => "series_code"
  add_index "wdi_gdf_facts", ["series_name", "country_name"], :name => "series_name"

  create_table "wdi_gdf_fnotes", :force => true do |t|
    t.string  "country_code", :limit => 8,  :null => false
    t.string  "series_code",  :limit => 24, :null => false
    t.string  "time",         :limit => 10
    t.text    "footnote",                   :null => false
    t.integer "series_id"
    t.integer "country_id"
    t.integer "fact_id"
  end

  add_index "wdi_gdf_fnotes", ["country_code", "series_code"], :name => "country_code"

  create_table "wdi_gdf_series", :force => true do |t|
    t.string "series_code",        :limit => 24,  :null => false
    t.string "series_name",        :limit => 200, :null => false
    t.text   "long_definition",                   :null => false
    t.text   "short_definition",                  :null => false
    t.text   "source",                            :null => false
    t.text   "aggregation_method"
    t.text   "general_comments"
    t.string "topic",              :limit => 48,  :null => false
    t.string "subtopic1",          :limit => 48,  :null => false
    t.string "subtopic2",          :limit => 48
    t.string "subtopic3",          :limit => 48
    t.string "wdi",                :limit => 8
    t.string "gdf",                :limit => 8
  end

  add_index "wdi_gdf_series", ["series_code"], :name => "series_code"
  add_index "wdi_gdf_series", ["series_name", "long_definition", "source", "topic", "subtopic1"], :name => "series_name"

end
