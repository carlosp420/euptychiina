require 'rubygems'
require 'sinatra'
require 'haml'

require 'rest_client'
require 'json'
require 'namae'

DB = 'http://localhost:5984/euptychiina'

get '/' do
    @title = "Home Page"

    # last entries
    data = RestClient.get "#{DB}/_design/references/_view/by_time?limit=10";
    response = JSON.parse(data);
    response['rows'].each do|n|
        id = "#{n["id"]}"
        @result = get_data_from_id(id);
    end
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


def get_data_from_id(id)
    resp = RestClient.get "#{DB}/" + id
    obj = JSON.parse(resp)
    response = convert_obj_to_citation(obj)
end

def convert_obj_to_citation(obj)
    output  = "<b><a href='ref/'" + obj['myid'] + "'>";
    output += format_authors(obj);
    output += "</a></b>";

    output += obj['year']
end


def format_authors(obj)
    n_authors = "";

    obj['author'].each do |author|
        if( author['given'] && author['family'] )
            n_authors += author['family'] + " ";
        elsif author['name']
            n = Namae.parse author['name']
            given = n[0].given.strip.gsub(".", "")[0,1];
            n_authors += n[0].family + " " + given + ", ";
        end
    end

    return n_authors
end
