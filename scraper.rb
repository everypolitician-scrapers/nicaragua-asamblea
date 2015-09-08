#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//table[//tr[contains(.,"APELLIDOS")]]//tr').drop(2).each do |tr|
    tds = tr.css('td')
    email = tds[2].text.tidy
    email = tds[3].text.tidy if email.to_s.empty?

    data = { 
      name: tds[1].text.tidy.sub('DIP. ',''),
      party: tds[4].text.tidy,
      email: email,
      term: 2012,
      source: 'http://apps.asamblea.gob.ni/Recursos/rpt3/'
    }
    puts data
    ScraperWiki.save_sqlite([:name, :party, :term], data)
  end
end

# We want http://apps.asamblea.gob.ni/Recursos/rpt3/ 
# but it injects the content into an iframe in a way that I couldn't get
# a scraper to read, so for now I'm going with the approach of just
# loading it the browser, and copying the rendered source of the page to
# a file on disk. If someone can work out how to get the live version of
# the page, I'd be very grateful!
scrape_list('page.html')
