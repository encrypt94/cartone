module Cartone
  class Webapp < Sinatra::Base
    set :views, File.expand_path('../views', __FILE__)
    set :public_folder, File.expand_path('../public', __FILE__)
    es = Elasticsearch::Client.new(log: true)
    
    get '/' do
    end
    
    get '/annunci/pages/' do
      redirect '/annunci/pages/0'
    end
    
    get '/annunci/pages/:page' do |page|
      annunci = 20
      query =  { 
        sort: [ 
               { 
                 "data.price" =>
                 {
                   order: "asc"
                 }
               } 
              ]
      }
      results = es.search(index: 'annunci', type: 'annuncio', body: query, size: annunci, from: page.to_i*annunci)
      erb :annunci, locals: { annunci: results['hits']['hits'], results: results['total'], pages: results['hits']['total'].to_i/annunci, current: page.to_i }
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
