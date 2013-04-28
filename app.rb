require 'rubygems'
require 'sinatra'
require 'haml'

require 'rest_client'
require 'json'
require 'namae'


require './functions'

DB = 'http://localhost:5984/euptychiina'

get '/' do
    @title = "Home Page" 

    # last entries
    data = RestClient.get "#{DB}/_design/references/_view/by_time?limit=10";
    response = JSON.parse(data);

    last_entries = "<ul>";
    response['rows'].each do|n|
        id = "#{n["id"]}"
        last_entries += "<li>" + get_data_from_id(id) + "</li>\n";
    end
    last_entries += "</ul>"
    @result = last_entries

    haml :index
end

get '/about' do
    @title = "About Page"
    haml :about
end

get '/contact' do
    @title = "Contact Page"
    haml :contact
end


get '/ref/:myid' do
    myid = "#{params[:myid]}"
    @citation = get_data_from_myid(myid) 

    haml :ref
end
