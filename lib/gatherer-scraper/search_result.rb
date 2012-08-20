require 'uri'

require_relative 'uri_with_params.rb'

module GathererScraper
  class SearchResult
    CARD_NUMBER_IN_A_PAGE = 25

    attr_reader :card_urls

    def initialize(params)
      base_url = SearchUrl.new(params)
      doc = Nokogiri::HTML(open(base_url.concat))

      result_number = self.class.result_number(doc)
      page_size = (result_number / 25.to_f).ceil

      @card_urls = (0...page_size).map do |page_number|
        self.class.card_urls(base_url, page_number)
      end.flatten

      unless @card_urls.size == result_number
        raise 'Result card number don\'t confirm to displayed card number'
      end
    end

    private
    def self.result_number(doc)
      span_tag = doc.at_xpath("//div[@class='contentTitle']" +
                              "[contains(text(), 'Search:')]/span")
      span_tag.at_xpath('i').unlink # remove a child <i> ~ </i> node
      match_data = span_tag.content.strip.match(/\A\((\d+)\)\Z/)
      match_data[1].to_i
    end

    def self.card_urls(base_url, page_number)
      a_search_result_page = base_url.append_params(page: page_number)
      doc = Nokogiri::HTML(open(a_search_result_page.concat))
      doc.xpath("//span[@class='cardTitle']/a/@href").map do |href|
        URI.join(a_search_result_page.concat, href)
      end
    end
  end

  class << self
    def search_result(params)
      SearchResult.new(params).card_urls
    end
  end
end
