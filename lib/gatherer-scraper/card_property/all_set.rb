require 'gatherer-scraper/card_property'
require 'gatherer-scraper/kind_validator'

class AllSet
  ALL_RARITY_LIST = [:'Mythic Rare', :Rare, :Uncommon, :Common, :Land, :Special]
  include ActiveModel::Validations
  attr_reader :set_name
  validates :set_name, presence: true, kind: { type: Symbol }
  attr_reader :rarity
  validates :rarity, presence: true, kind: { type: Symbol },
    inclusion: { in: ALL_RARITY_LIST }
  def initialize(set_name, rarity)
    @set_name = set_name
    @rarity = rarity

    raise ArgumentError.new(errors.full_messages) if invalid?
  end
  def self.parse(node)
    return [] if node == nil
    alt_texts = node.xpath('div/a/img/@alt')
    alt_texts.map do |alt|
      _, set_name, rarity = alt.content.strip.match(/\A(.*) \((.*)\)\Z/).to_a
      CardProperty.validate_using_exception(new(set_name.to_sym, rarity.to_sym))
    end
  end
  def ==(rhs)
    @set_name == rhs.set_name && @rarity == rhs.rarity
  end
end
