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


def get_data_from_id(id)
    resp = RestClient.get "#{DB}/" + id
    obj = JSON.parse(resp)
    response = convert_obj_to_citation(obj)
    return response
end

def convert_obj_to_citation(obj)
    output  = "<b><a href='ref/'" + obj['myid'] + "'>";
    output += format_authors(obj);
    output += "</a></b> ";

    if( obj['year'] )
        output += obj['year'] + ". "
    end

    if( obj['title'] )
        output += obj['title'] + ". "
    end

    if( obj['journal']['name'] )
        output += '<i>' + obj['journal']['name'] + "</i>, "
    end

    if( obj['journal']['volume'] )
        output += '<b>' + obj['journal']['volume'] + "</b>"
    end

    if( obj['journal']['issue'] )
        output += '(' + obj['journal']['issue'] + ")"
    end

    if( obj['journal']['pages'] )
        output += " " + obj['journal']['pages'].gsub("--", "-") + "."
    end

    if( obj['doi'] )
        output += " <a href='http://dx.doi.org/"
        output += obj['doi'] + "'>doi:" + obj['doi'] + "</a>"
    end

    return output
end


def format_authors(obj)
    n_authors = "";

    obj['author'].each do |author|
        if( author['given'] && author['family'] )
            n_authors += author['family'] + " ";
            given = author['given'].split(" ");
            given.each do |name|
                name = name.gsub(".", "").strip[0,1]
                n_authors += name + ", "
            end

        elsif author['name']
            n = Namae.parse author['name']
            given = n[0].given.strip.gsub(".", "")[0,1];
            n_authors += n[0].family + " " + given + ", ";
        end
    end

    n_authors  = n_authors.strip.sub /,$/, ""
    n_authors += '.'
    return n_authors
end
