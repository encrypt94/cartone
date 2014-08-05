# -*- coding: utf-8 -*-
module Cartone

  module Services

    class SubitoIt < Service
      def initialize()
        super('subito.it', 'http://www.subito.it','/annunci-emilia-romagna/affitto/appartamenti/bologna/?search_town=037006&th=1&f=p')
      end

      def fetch()
        annunci = []
        page = Nokogiri::HTML(open(self.base_url+self.request))
        
        page.css("ul.list > li").select do |li|
          annuncio = Cartone::Annuncio.new()
          li.css("div.descr > p > a").select do |link| 
            annuncio.service = self.name
            annuncio.link = self.base_url+link["href"] 
            annuncio.id = self.name+link["name"]
          end
          annuncio.date = Annuncio.parse_date(li.css(".date").text)
          annuncio.title = li.css("div.descr > p > a > strong").text
          info = li.css("div.descr > p.price").text.gsub(' ','').gsub(10.chr, '')
          unless(info.empty?)
            if(info =~ /([0-9.]*)€/)
              annuncio.data["price"] = $1.gsub('.','').to_f
            end
            if(info =~ /([0-9.]*)mq/)
              annuncio.data["size"] = $1.to_i
            end
            if(info =~ /([0-9]*)locali/)
              annuncio.data["locali"] = $1.to_i
            end
          end
          adv_pg = Nokogiri::HTML(open(annuncio.link))
          annuncio.description = adv_pg.css("#body_txt").text.gsub(10.chr, '')
          adv_pg.css("#view_gallery > .annuncio_thumbs > .scrollgallery > ul > li").select do |li|
            if li["onclick"] =~ /showMainImage\('(.*)'\)/
              annuncio.images.push($1)
            end
          end
          annunci.push(annuncio)
        end
        return annunci
      end
      
      def next_page()
        if self.request =~ /&o=([0-9]*)/
          page_index = $1.to_i+1
          self.request.gsub!("&o="+$1.to_s,"&o="+page_index.to_s)
        else
          self.request = self.request+"&o=2"
        end
      end
    end
  end
end
