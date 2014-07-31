#!/usr/bin/env ruby

require 'cartone'
require 'cartone/services/subito'
require 'cartone/services/affitto'
require 'cartone/services/bakeca'
require 'cartone/services/kijiji'
require 'digest'
require 'elasticsearch'

services = [
            Cartone::Services::AffittoIt,
            Cartone::Services::KijijiIt,
            Cartone::Services::SubitoIt,
            Cartone::Services::KijijiIt
           ]

elastic = Elasticsearch::Client.new(log: true)

services.each do |service|
  service = service.new
  3.times do
    service.fetch.each do |annuncio|
      elastic.index(index: 'annunci',
                    type: 'annuncio',
                    id: Digest::SHA1.hexdigest(annuncio.id),
                    body: annuncio.to_json)
    end
    service.next_page
  end
end
