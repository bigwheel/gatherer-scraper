require 'gatherer-scraper/card_property/all_set'
require 'gatherer-scraper/card_property/mana_cost'
require 'gatherer-scraper/card_property/p_t'
require 'gatherer-scraper/card_property/type'
require 'gatherer-scraper/kind_validator'
require 'gatherer-scraper/strip_validator'

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

  attr_reader :p_t
  validates :p_t, kind: { type: PT, allow_nil: true }

  SUPPORTING_EXPANSION_LIST = [ :'Magic 2013' ]
  attr_reader :expansion
  validates :expansion, presence: true, kind: { type: Symbol },
    strip: true, inclusion: { in: SUPPORTING_EXPANSION_LIST }

  ALL_RARITY_LIST = [:'Mythic Rare', :Rare, :Uncommon, :Common, :'Basic Land']
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
  validates :card_number, presence: true, kind: { type: Integer },
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  attr_reader :artist
  validates :artist, presence: true, kind: { type: String },
    strip: { multiline: false }

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  def initialize(multiverseid, card_name, mana_cost, converted_mana_cost,
                 type, card_text, flavor_text, p_t, expansion, rarity,
                 all_sets, card_number, artist)
    @multiverseid = multiverseid
    @card_name = card_name
    @mana_cost = mana_cost
    @converted_mana_cost = converted_mana_cost
    @type = type
    @card_text = card_text
    @flavor_text = flavor_text
    @p_t = p_t
    @expansion = expansion
    @rarity = rarity
    @all_sets = all_sets
    @card_number = card_number
    @artist = artist

    raise ArgumentError.new(errors.full_messages) if invalid?
  end

  def self.parse(multiverseid)
    url = CardUrl.new(multiverseid: multiverseid)
    doc = Nokogiri::HTML(open(url.concat))

    card_name = value_of_label(doc, 'Card Name')
    mana_cost = ManaCost.parse(node_by_label(doc, 'Mana Cost'))
    converted_mana_cost = value_of_label(doc, 'Converted Mana Cost').to_i
    type = Type.parse(node_by_label(doc, 'Types'))
    card_text = value_of_label(doc, 'Card Text') do |node|
      node.inner_html.strip
    end
    flavor_text = value_of_label(doc, 'Flavor Text') do |node|
      node.inner_html.strip
    end
    p_t = PT.parse(node_by_label(doc, 'P/T'))
    expansion = value_of_label(doc, 'Expansion') do |node|
      node.at_xpath("div/a[contains(@href, 'Pages/Search')]").content.strip.to_sym
    end
    rarity = value_of_label(doc, 'Rarity') do |node|
      node.at_xpath('span').content.strip.to_sym
    end
    all_sets = AllSet.parse(node_by_label(doc, 'All Sets'))
    card_number = value_of_label(doc, 'Card #').to_i
    artist = value_of_label(doc, 'Artist') do |node|
      node.at_xpath('a').content.strip
    end
    obj = new(multiverseid, card_name, mana_cost, converted_mana_cost,
              type, card_text, flavor_text, p_t, expansion, rarity,
              all_sets, card_number, artist)
    validate_using_exception(obj)
  end
  def self.validate_using_exception(obj)
    if obj.invalid?
      raise ArgumentError.new('invalid document')
    else
      obj
    end
  end
  private
  def self.node_by_label(nokogiri_doc, label_name)
    xpath = "//div[@class='label'][contains(text(), '#{label_name}')]" +
      "/../div[@class='value']"
    nokogiri_doc.at_xpath(xpath)
  end
  def self.value_of_label(nokogiri_doc, label_name)
    node = node_by_label(nokogiri_doc, label_name)
    if node == nil
      nil
    elsif block_given?
      yield node
    else
      node.content.strip
    end
  end
end
