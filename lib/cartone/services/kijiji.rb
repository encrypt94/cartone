# -*- coding: utf-8 -*-
module Cartone
  module Services
    class KijijiIt < Service
      def initialize()
        super('kijiji.it', 'http://www.kijiji.it', '/case/affitto/annunci-bologna/')
      end

      def fetch()
        annunci = []
        page = Nokogiri::HTML(open(self.base_url+self.request))
        
        page.css("#search-results-list > div.search-results-list-item").select do |item|
          annuncio = Annuncio.new()
          annuncio.service = self.name
          annuncio.title = item.css('h2.list-item-title > a').text
          item.css('h2.list-item-title > a').select do |link|
            annuncio.id = self.name+link["namhttp://www.kijiji.it/annunci/stanze-e-posti-letto/bologna-annunci-malpighi/3-singole-in-via-del-pratello/67610840e"]
            annuncio.link = link["href"]
          end
          annuncio.data["price"] = item.css('.list-item-price').text.gsub(/[^0-9,]/,'').to_f
          adv_pg = Nokogiri::HTML(open(annuncio.link))
          annuncio.description = adv_pg.css('#item_description').text.chomp
          adv_pg.css('#thumb-gallery > a').select do |a|
            annuncio.images.push(a["href"])
          end
          adv_pg.css('#main_attributes > ul > li').select do |li|
            key = li.css('span.bold').text.chomp.strip.gsub(':','').downcase
            li.css('span.bold').remove
            value = li.text.chomp.strip.downcase
            case key
            when 'pubblicato'
              annuncio.date = Annuncio.parse_date(value)
            when 'tipo'
              annuncio.data["type"] = value
            when 'locali'
              annuncio.data["locali"] = value.gsub(/[^0-9]/,'').to_i
            when 'mq'
              annuncio.data["size"] = value.gsub(/[^0-9]/,'').to_i
            end

          end
          annunci.push annuncio
        end
        return annunci
      end

      def next_page()
        if self.request =~ /\?p=([0-9]*)/
          page_index = $1.to_i+1
          self.request.gsub!("\?p="+$1, "\?p="+page_index.to_s)
        else
          self.request = self.request+"?p=2"
        end
      end

      def is_alive(link)
        !Nokogiri::HTML(open(link)).css(".warning").text.include?("non è più disponibile")
      end
    end
  end
end
