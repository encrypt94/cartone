module Cartone
  class Webapp < Sinatra::Base
    set :views, File.expand_path('../views', __FILE__)
    set :public_folder, File.expand_path('../public', __FILE__)
    es = Elasticsearch::Client.new(log: true)
    
    get '/' do
      fields = [ 'price', 'size', 'camere', 'locali' ]
      query = { "aggs" => {} }
      fields.each do |field|
        query["aggs"][field] = {
          "stats" => {
            "field" => "data."+field
          }
        }
      end
      results = es.search(index: 'annunci', type: 'annuncio', body: query)
      erb :search_form, locals: { fields: results['aggregations'] }
    end

    get '/search/:page' do |page|
      pars = [ 'locali', 'price', 'camere', 'size' ]
      annunci = 20
      query =  { 
        query: {
          multi_match: {
            query: "",
            fields: [ 'title', 'description' ],
            operator: 'or'
          }
        },
        post_filter: {
          range: {}
        },
        sort: [ 
               { 
                 "data.price" =>
                 {
                   order: "asc"
                 }
               } 
              ]
      }
      if params.has_key?('str') and !params[:str].empty?
        query[:query][:multi_match][:query] = params[:str]
      else
        query.delete(:query)
      end
      pars.each do |par|
        query[:post_filter][:range][par] = {}
        ['from','to'].each do |m|
          if params.has_key?(par+"_"+m)
            query[:post_filter][:range][par][m] = params[par+"_"+m].to_f
          else
            query[:post_filter][:range][par][m] = 0
          end
        end
      end
      results = es.search(index: 'annunci', type: 'annuncio', body: query, size: annunci, from: page.to_i*annunci)
      erb :annunci, locals: { query_string: request.query_string, annunci: results['hits']['hits'], results: results['total'], pages: results['hits']['total'].to_i/annunci, current: page.to_i }
    end

    get '/annuncio/:id' do |id|
      content_type :json
      if es.exists(index: 'annunci', type: 'annuncio', id: id)
        annuncio = es.get(index: 'annunci', type: 'annuncio', id: id)
        annuncio.to_json
      end
    end
  end
end
