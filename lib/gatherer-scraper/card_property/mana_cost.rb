require 'gatherer-scraper/kind_validator'

class ManaCost
  include ActiveModel::Validations
  MANA_SYMBOL_LIST = [:White, :Blue, :Black, :Red, :Green, :'Variable Colorless']
  CHARACTERIZE_MANA_SYMBOL = { White: 'W', Blue: 'U', Black: 'B', Red: 'R',
                               Green: 'G', :'Variable Colorless' => 'X' }
  #field :mana_symbols, type: Array
  attr_reader :mana_symbols
  validates_presence_of :mana_symbols
  validates :mana_symbols, presence: true, kind: { type: Enumerable }
  validate do
    if mana_symbols.kind_of? Enumerable
      characterized_mana_symbols = mana_symbols.map do |mana_symbol|
        if mana_symbol.kind_of? Symbol
          if MANA_SYMBOL_LIST.include? mana_symbol
            CHARACTERIZE_MANA_SYMBOL[mana_symbol]
          else
            errors.add(:mana_symbols, "#{mana_symbol} is not contained in Mana Symbol List")
          end
        elsif mana_symbol.kind_of? Integer
          if 0 <= mana_symbol
            mana_symbol
          else
            errors.add(:mana_symbols, "#{mana_symbol} is not a Natural Number")
            # Memnite or Ornithopter is 0 mana
          end
        else
          errors.add(:mana_symbols, "#{mana_symbol} is neither a kind of Integer nor Symbol")
        end
      end

      if errors.size == 0
        errors.add(:mana_symbols, "#{characterized_mana_symbols} is invalid mana symbol order") unless characterized_mana_symbols.join('') =~
        /\AX?(0|[1-9]\d*)?[WUBRG]*\Z/
      end
    end
    # don't write error process in else statement because
    # that is duplicating above presence validation
  end
  def self.parse(node)
    if node == nil
      nil
    else
      mana_symbol_texts = node.xpath('img/@alt').map do |alt|
        alt.content.strip
      end
      mana_symbols = mana_symbol_texts.map do |symbol|
        if symbol =~ /\A\d*\Z/
          symbol.to_i
        else
          symbol.to_sym
        end
      end
      CardProperty.validate_using_exception(new(mana_symbols))
    end
  end
  def initialize(mana_symbols)
    @mana_symbols = mana_symbols
    raise ArgumentError.new(errors.full_messages) if invalid?
  end
end
