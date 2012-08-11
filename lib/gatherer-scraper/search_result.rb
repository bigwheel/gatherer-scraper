require_relative 'uri_with_params.rb'

module GathererScraper
  class SearchResult
    attr_reader :multiverseids
    def initialize params
      base_url = SearchUrl.new(params)
      doc = Nokogiri::HTML(open(base_url.concat))

      page_size = (self.class.result_number(doc) / 25.0).ceil

      @multiverseids = (0...page_size).map do |page_number|
        self.class.multiverseids(base_url, page_number)
      end.flatten
    end
    private
    def self.result_number doc
      span_tag = doc.at_xpath("//div[@class='contentTitle']" +
                              "[contains(text(), 'Search:')]/span")
      span_tag.at_xpath('i').unlink # remove a child <i> ~ </i> node
      match_data = span_tag.content.strip.match(/\((\d+)\)/)
      match_data[1].to_i
    end
    def self.multiverseids(base_url, page_number)
      a_search_result_page = base_url.append_params(page: page_number)
      doc = Nokogiri::HTML(open(a_search_result_page.concat))
      doc.xpath("//span[@class='cardTitle']/a/@href").map do |href|
        prefix = Regexp.escape %!../Card/Details.aspx?multiverseid=!
        match_data = href.content.match(/#{prefix}(\d+)/)
        match_data[1].to_i
      end
    end
  end
end
