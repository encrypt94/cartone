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
          query_string: {
            default_field: "_all",
            query: ""
          }
        },
        sort: [
               {
                 "data.price" => {
                   missing: "_last"
                 }
               },
               { 
                 "data.camere" => {
                   missing: "_last"
                 }
               },
               {
                 "data.locali" => {
                   missing: "_last"
                 }
               },
               {
                 "data.size" => {
                   missing: "_last"
                 }
               }
              ]
      }
      query[:query][:query_string][:query] = "((_missing_:data.price) OR (data.price:[#{params[:price_from].to_f} TO #{params[:price_to].to_f}])) AND ((_missing_:data.locali) OR (data.locali:[#{params[:locali_from].to_i} TO #{params[:locali_to].to_i}])) AND ((_missing_:data.camere) OR (data.camere:[#{params[:camere_from].to_i} TO #{params[:camere_to].to_i}])) AND ((_missing_:data.size) OR (data.size:[#{params[:size_from].to_i} TO #{params[:size_to].to_i}]))"
      if params.has_key?('str') and !params[:str].empty?
        #Sanitize input
        params[:str].gsub!('"','\"')
        query[:query][:query_string][:query] << " AND (title:(\"#{params[:str]}\") OR description:(\"#{params[:str]}\"))"
      end
      results = es.search(index: 'annunci', type: 'annuncio', body: query, size: annunci, from: page.to_i*annunci)
      erb :annunci, locals: { query_string: request.query_string, annunci: results['hits']['hits'], results: results['total'], pages: results['hits']['total'].to_i/annunci, current: page.to_i }
    end

    get '/annuncio/:id' do |id|
      if es.exists(index: 'annunci', type: 'annuncio', id: id)
        result = es.get(index: 'annunci', type: 'annuncio', id: id)
        erb :annuncio, locals: { annuncio: result['_source']}
      else
        404
      end
    end
  end
end
