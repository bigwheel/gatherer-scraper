require 'uri'

require 'gatherer-scraper/card_property/all_set'
require 'gatherer-scraper/card_property/mana_cost'
require 'gatherer-scraper/card_property/p_t'
require 'gatherer-scraper/card_property/type'
require 'gatherer-scraper/card_property/card_number'
require 'gatherer-scraper/kind_validator'
require 'gatherer-scraper/strip_validator'
require 'gatherer-scraper/unique_enumerable_validator'

STRIPED_LINE = '\A(\S|\S.*\S)\Z'
STRIPED_LINE_REGEXP  = Regexp.new(STRIPED_LINE)
STRIPED_LINES_REGEXP = Regexp.new(STRIPED_LINE, Regexp::MULTILINE)

class CardProperty
  include ActiveModel::Validations
  extend KindValidator::HelperMethods
  include KindValidator::HelperMethods

  attr_reader :multiverseid
  validates :multiverseid, presence: true, kind: { type: Integer },
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  attr_reader :card_image_url
  validates :card_image_url, presence: true, kind: { type: URI::HTTP }
  validate do
    url_text = @card_image_url.to_s
    prefix = Regexp.escape('http://gatherer.wizards.com/Handlers/' +
                           'Image.ashx?multiverseid=')
    type_parameter = Regexp.escape('&type=card')
    rotate_option = Regexp.escape('&options=rotate180')
    image_regexp = /\A#{prefix}\d+#{type_parameter}(#{rotate_option})?\Z/
    unless url_text =~ image_regexp
      errors.add(:card_image_url, "#{url_text} is not a valid url")
    end
  end

  attr_reader :card_name
  validates :card_name, presence: true, kind: { type: String },
    strip: { multiline: false }

  attr_reader :mana_cost
  validates :mana_cost, kind: { type: ManaCost, allow_nil: true }

  attr_reader :converted_mana_cost
  validates :converted_mana_cost, kind: { type: Integer, allow_nil: true },
    numericality: { only_integer: true, greater_than_or_equal_to: 0, allow_nil: true }

  attr_reader :type
  validates :type, presence: true, kind: { type: Type }

  attr_reader :card_text
  validates :card_text, strip: { multiline: true, allow_nil: true },
    kind: { type: String, allow_nil: true }

  attr_reader :flavor_text
  validates :flavor_text, strip: { multiline: true, allow_nil: true },
    kind: { type: String, allow_nil: true }

  WATERMARK_SCARS_OF_MIRRODIN = [:Mirran, :Phyrexian]
  WATERMARK_RAVNICA = [:Boros, :Orzhov, :Azorius, :Selesnya, :Gruul, :Rakdos,
                       :Golgari, :Izzet, :Simic, :Dimir]
  attr_reader :watermark
  validates :watermark, kind: { type: Symbol, allow_nil: true },
    inclusion: { in: WATERMARK_RAVNICA + WATERMARK_SCARS_OF_MIRRODIN, allow_nil: true }

  ALL_COLORS = [:White, :Blue, :Black, :Red, :Green]
  attr_reader :color_indicator
  validates :color_indicator, unique_enumerable: { allow_nil: true }
  validate do
    return if color_indicator == nil

    if color_indicator.kind_of? Enumerable
      color_indicator.each do |color|
        unless ALL_COLORS.include? color
          errors.add(:color_indicator, "#{color} is a unknown color")
        end
      end
    end
  end

  attr_reader :p_t
  validates :p_t, kind: { type: PT, allow_nil: true }

  attr_reader :loyalty
  validates :loyalty, kind: { type: Integer, allow_nil: true },
    numericality: { only_integer: true, greater_than_or_equal_to: 1, allow_nil: true }

  SUPPORTING_EXPANSION_LIST = [
    :'Fourth Edition', :'Chronicles',
    :'Fifth Edition',
    :'Classic Sixth Edition',
    :'Seventh Edition',
    :'Ice Age', :'Alliances', :'Coldsnap',
    :'Mirage', :'Visions', :'Weatherlight',
    :'Tempest', :'Stronghold', :'Exodus',
    :'Urza\'s Saga', :'Urza\'s Legacy', :'Urza\'s Destiny',
    :'Mercadian Masques', :'Nemesis', :'Prophecy',
    :'Invasion', :'Planeshift', :'Apocalypse',
    :'Odyssey', :'Torment', :'Judgment',
    :'Onslaught', :'Legions', :'Scourge',
    :'Eighth Edition',
    :'Mirrodin', :'Darksteel', :'Fifth Dawn',
    :'Champions of Kamigawa', :'Betrayers of Kamigawa', :'Saviors of Kamigawa',
    :'Ninth Edition',
    :'Ravnica: City of Guilds', :'Guildpact', :'Dissension',
    :'Time Spiral', :'Time Spiral "Timeshifted"', :'Planar Chaos', :'Future Sight',
    :'Tenth Edition',
    :'Lorwyn', :'Morningtide', :'Shadowmoor', :'Eventide',
    :'Shards of Alara', :'Conflux', :'Alara Reborn',
    :'Magic 2010',
    :'Zendikar', :'Worldwake', :'Rise of the Eldrazi',
    :'Magic 2011',
    :'Scars of Mirrodin', :'Mirrodin Besieged', :'New Phyrexia',
    :'Magic 2012',
    :'Innistrad', :'Dark Ascension', :'Avacyn Restored',
    :'Magic 2013' ]
  attr_reader :expansion
  validates :expansion, presence: true, kind: { type: Symbol },
    strip: true, inclusion: { in: SUPPORTING_EXPANSION_LIST }

  ALL_RARITY_LIST = [:'Mythic Rare', :Rare, :Uncommon, :Common, :'Basic Land', :Special]
  attr_reader :rarity
  validates :rarity, presence: true, kind: { type: Symbol },
    inclusion: { in: ALL_RARITY_LIST }

  attr_reader :all_sets
  validates :all_sets, kind: { type: Enumerable }
  validate do
    if all_sets == nil
      errors.add(:all_sets, "#{all_sets} is can't be nil")
    elsif all_sets.kind_of? Enumerable
      all_sets.each do |all_set|
        unless all_set.kind_of? AllSet
          errors.add(:all_sets, "all_sets can only contain #{AllSet} object")
        end
      end
    end
  end

  attr_reader :card_number
  validates :card_number, kind: { type: CardNumber, allow_nil: true }

  attr_reader :artist
  validates :artist, kind: { type: String, allow_nil: true },
    strip: { multiline: false, allow_nil: true }

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  def initialize(multiverseid, card_image_url, card_name, mana_cost,
                 converted_mana_cost, type, card_text, flavor_text, watermark,
                 color_indicator, p_t, loyalty, expansion, rarity,
                 all_sets, card_number, artist)
    @multiverseid = multiverseid
    @card_image_url = card_image_url
    @card_name = card_name
    @mana_cost = mana_cost
    @converted_mana_cost = converted_mana_cost
    @type = type
    @card_text = card_text
    @flavor_text = flavor_text
    @watermark = watermark
    @color_indicator = color_indicator
    @p_t = p_t
    @loyalty = loyalty
    @expansion = expansion
    @rarity = rarity
    @all_sets = all_sets
    @card_number = card_number
    @artist = artist

    raise ArgumentError.new(errors.full_messages) if invalid?
  end

  def self.parse(card_url)
    queries = Hash[URI.decode_www_form(URI(card_url).query)]

    printed = queries.delete('printed')
    if printed != nil && printed != 'false'
      raise ArgumentError.new('This class only supports oracle text')
    end

    multiverseid = queries.delete('multiverseid').to_i
    card_name_from_url = queries.delete('part')
    unless queries.empty?
      raise ArgumentError.new("url has unknown parameters #{queries}")
    end


    doc = Nokogiri::HTML(open(card_url))
    def self.xpath_class_condition(class_name)
      "[contains(concat(' ', normalize-space(@class), ' '), ' #{class_name} ')]"
    end
    def self.quotes_escaped_xpath_literal(text)
      if text.include?("'")
        "concat('#{text.gsub("'", "', \"'\", '")}')"
        #text.split(/(')/).map { |e| e == "'" ? %!"#{e}"! : "'#{e}'" }.join(", ")
      else
        "'#{text}'"
      end
    end
    table_xpath = "//table#{xpath_class_condition('cardDetails')}"
    if card_name_from_url
      table_xpath += "[.//div[@class='label'][contains(text(), 'Card Name')]" +
        "/../div[@class='value']" +
        "[contains(text(), #{quotes_escaped_xpath_literal(card_name_from_url)})]]"
    end
    table = doc.at_xpath(table_xpath)

    def table.delete_node_by_label(label_name)
      node = at_xpath(".//div[@class='label']" +
                      "[contains(text(), '#{label_name}')]/..")
      return nil unless node

      node.unlink.at_xpath("./div[@class='value']")
    end

    def table.value_of_label(label_name)
      node = delete_node_by_label(label_name)

      return nil if node == nil

      if block_given?
        yield node
      else
        node.content.strip
      end
    end

    card_image_url = URI.join(URI(card_url), table.at_xpath('.//img[contains(@id, "cardImage")]/@src').content)
    card_name = table.value_of_label('Card Name')
    mana_cost = ManaCost.parse(table.delete_node_by_label('Mana Cost'))
    converted_mana_cost = table.value_of_label('Converted Mana Cost').to_i
    type = Type.parse(table.delete_node_by_label('Types'))
    card_text = table.value_of_label('Card Text') do |node|
      node.inner_html.strip
    end
    flavor_text = table.value_of_label('Flavor Text') do |node|
      node.inner_html.strip
    end
    watermark = table.value_of_label('Watermark') do |node|
      node.at_xpath('./div/i').inner_html.strip.to_sym
    end
    color_indicator = table.value_of_label('Color Indicator') do |node|
      node.content.strip.split(',').map { |color| color.strip.to_sym }
    end
    p_t = PT.parse(table.delete_node_by_label('P/T'))
    loyalty = table.value_of_label('Loyalty')
    loyalty = loyalty.to_i if loyalty
    expansion = table.value_of_label('Expansion') do |node|
      node.at_xpath("div/a[contains(@href, 'Pages/Search')]").content.strip.to_sym
    end
    rarity = table.value_of_label('Rarity') do |node|
      node.at_xpath('span').content.strip.to_sym
    end
    all_sets = AllSet.parse(table, multiverseid)
    card_number = CardNumber.parse(table.delete_node_by_label('Card #'))
    artist = table.value_of_label('Artist') do |node|
      # Because value_of_label has a side effect,
      # following rare case 29896 is written in here
      if multiverseid == 29896
        'Don Hazeltine'
      else
        node.at_xpath('a').content.strip
      end
    end
    table.delete_node_by_label('Community Rating')

    rest_of_labels = table.xpath(".//div[@class='label']/..")
    unless rest_of_labels.size == 0
      raise 'There are not crawling label element' + rest_of_labels.inner_html
    end

    new(multiverseid, card_image_url, card_name, mana_cost,
        converted_mana_cost, type, card_text, flavor_text, watermark,
        color_indicator, p_t, loyalty, expansion, rarity, all_sets,
        card_number, artist)
  end
end
