require 'uri'

class UrlWithParams
  def initialize(path, params = {})
    @path = path
    @params = params
  end

  def concat
    params_str_pair = @params.collect do |k,v|
      "#{k}=#{v}"
    end
    URI.parse(URI.encode(@path + '?' + params_str_pair.join('&')))
  end

  def append_params new_params
    UrlWithParams.new(@path, @params.merge(new_params))
  end

  def remove_params key
    new_params = @params.dup
    new_params.delete(key)
    UrlWithParams.new(@path, new_params)
  end
end

class CardUrl < UrlWithParams
  def initialize(params = {})
    card_url = 'http://gatherer.wizards.com/Pages/Card/Details.aspx'
    super(card_url, params)
  end
end

class SearchUrl < UrlWithParams
  def initialize(params = {})
    search_url = 'http://gatherer.wizards.com/Pages/Search/Default.aspx'
    super(search_url, params_filter(params))
  end

  def append_params new_params
    super(params_filter(new_params))
  end

  private
  def params_filter(params)
    if params.has_key?(:set)
      params = params.dup
      params[:set] = '["' + params[:set] + '"]'
    end
    params
  end
end
