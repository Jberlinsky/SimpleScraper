require 'anemone'
require 'rgl/adjacency'
require 'pry'
require 'rgl/dot'

class Scraper
  class << self
    def is_excluded?(url, exclusions)
      url = url.to_s
      exclusions.each do |exclusion|
        return true if url.match(exclusion)
      end
      return false
    end

    def safely(&block)
      # DRY up a bunch of single-statement begin-rescues
      begin
        block.call
      rescue ; end
    end

    def is_internal_link?(url)
      url = url.to_s
      url.match(/joingrouper\.com/) || ((url[0] == '/' && url[1] != '/') && !url.include?("http://") && !url.include?("https://"))
    end

    def get_source_from_tags(nokogiri_doc, tag)
      raise ArgumentError, 'You must specify a tag' unless tag
      nokogiri_doc.css(tag).map { |t| t['src'] }.select { |link| is_internal_link?(link)  }
    end

    def run(domain='https://www.joingrouper.com/', options = {})
      storage = options.delete(:storage) || Anemone::Storage.Redis
      extension = options.delete(:extension) || 'jpg'
      exclusions = options.delete(:exclusions) || []

      Anemone.crawl(domain) do |crawl|
        crawl.storage = storage
        crawl.focus_crawl do |page|
          page.links.reject do |link|
            is_excluded?(link, exclusions)
          end
        end
        crawl.on_every_page do |page|
          # Add static assets to links
          safely { css_sources(page.doc).each { |link| page.links << URI(link) } }
          safely { script_sources(page.doc).each { |link| page.links << URI(link) } }
          safely { image_sources(page.doc).each { |link| page.links << URI(link) } }# NOTE: Does not consider S3, per spec to not leave joingrouper.com domain

          sitemap.add_vertex(page.url.to_s)
          page.links.each do |other_vertex|
            next if other_vertex.to_s == page.url.to_s
            sitemap.add_vertex(other_vertex.to_s)
            sitemap.add_edge(page.url.to_s, other_vertex.to_s)
          end
        end
      end

      sitemap.write_to_graphic_file(extension)
    end

    private

    def build_adjacency_graph
      RGL::DirectedAdjacencyGraph.new
    end

    def sitemap
      @sitemap ||= build_adjacency_graph
    end

    def image_sources(nokogiri_doc)
      get_source_from_tags(nokogiri_doc, 'img[src]')
    end

    def css_sources(nokogiri_doc)
      get_source_from_tags(nokogiri_doc, 'link[rel=stylesheet][href]')
    end

    def script_sources(nokogiri_doc)
      get_source_from_tags(nokogiri_doc, 'script[src]')
    end
  end
end

Scraper.run('https://www.joingrouper.com/', extension: 'jpg', exclusions: [/groupergrams/])
