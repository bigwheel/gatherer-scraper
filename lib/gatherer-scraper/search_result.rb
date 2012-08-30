require 'uri'

module GathererScraper
  class SearchResult
    CARD_NUMBER_IN_A_PAGE = 25
    SEARCH_URL = 'http://gatherer.wizards.com/Pages/Search/Default.aspx'

    attr_reader :card_urls

    def initialize(params)
      bracketted_params = Hash[params.map { |k, v| [k, "[\"#{v}\"]"] }]
      search_result_base_url = SEARCH_URL + '?' +
        URI.encode_www_form(bracketted_params)
      doc = Nokogiri::HTML(open(search_result_base_url))

      result_number = self.class.result_number(doc)
      page_size = (result_number / 25.to_f).ceil

      @card_urls = (0...page_size).map do |page_number|
        self.class.card_urls(search_result_base_url, page_number)
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

    def self.card_urls(search_result_base_url, page_number)
      search_result_page_url = search_result_base_url + '&' +
        URI.encode_www_form(page: page_number)
      doc = Nokogiri::HTML(open(search_result_page_url))
      doc.xpath("//span[@class='cardTitle']/a/@href").map do |href|
        URI.join(search_result_page_url, href)
      end
    end
  end

  class << self
    def search_result(params)
      SearchResult.new(params).card_urls
    end
  end
end
