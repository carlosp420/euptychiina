require 'couchrest'


def get_data_from_myid(myid)
    mydb = CouchRest.database("http://localhost:5984/euptychiina");
    myid = myid.to_s()
    params = { :key => myid }

    resp = mydb.view("reference/by_myid", params)
    id = resp['rows'][0]['id']
    response = get_data_from_id(id)
    return response
end



def get_data_from_id(id)
    resp = RestClient.get "#{DB}/" + id
    obj = JSON.parse(resp)
    response = convert_obj_to_citation(obj)
    
    if( obj['_attachments'] )
        obj['_attachments'].each do |k,v|
            filename = k;
            @attachment = %Q{<h3>Attachments:</h3>}
            if( v['content_type'] == "application/pdf" )
                @attachment += %Q{ <a href='#{DB}/} + id + '/' + filename
                @attachment += %Q{'><img src='../images/pdf.png' /> </a> }
            elsif( v['content_type'] == "image/pdf" )
                @attachment += %Q{ <a href='#{DB}/} + id + '/' + filename
                @attachment += %Q{'><img src='../images/pdf.png' /> </a> }
            end
        end
    end

    return response
end



def convert_obj_to_citation(obj)
    output  = "<b><a href='" + request.base_url + "/ref/" + obj['myid'] + "'>";
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
        output += '(' + obj['journal']['issue'] + "): "
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
                n_authors += name
            end
            n_authors += ", "

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


