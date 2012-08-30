require 'gatherer-scraper/validations/kind_validator'

module GathererScraper::Attribute
  class ManaCost
    include ActiveModel::Validations
    include GathererScraper::Validations

    BASIC_COLORS = { White: '{W}', Blue: '{U}', Black: '{B}', Red: '{R}',
                     Green: '{G}' }
    X_COLOR = { :'Variable Colorless' => '{X}' }
    PHYREXIAN_COLORS = { :'Phyrexian White' => '{W/P}',
                         :'Phyrexian Blue'  => '{U/P}',
                         :'Phyrexian Black' => '{B/P}',
                         :'Phyrexian Red'   => '{R/P}',
                         :'Phyrexian Green' => '{G/P}' }
    HYBRID_COLORS = { :'White or Blue'  => '{W/U}', :'White or Black' => '{W/B}',
                      :'Blue or Black'  => '{U/B}', :'Blue or Red'    => '{U/R}',
                      :'Black or Red'   => '{B/R}', :'Black or Green' => '{B/G}',
                      :'Red or Green'   => '{R/G}', :'Red or White'   => '{R/W}',
                      :'Green or White' => '{G/W}', :'Green or Blue'  => '{G/U}' }
    MONOCOLORED_HYBRID_COLORS = { :'Two or White' => '{2/W}',
                                  :'Two or Blue'  => '{2/U}',
                                  :'Two or Black' => '{2/B}',
                                  :'Two or Red'   => '{2/R}',
                                  :'Two or Green' => '{2/G}' }

    CHARACTERIZE_MANA_SYMBOL = BASIC_COLORS.merge(X_COLOR).merge(PHYREXIAN_COLORS)\
      .merge(HYBRID_COLORS).merge(MONOCOLORED_HYBRID_COLORS)
    MANA_SYMBOL_LIST = CHARACTERIZE_MANA_SYMBOL.keys

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
        new(mana_symbols)
      end
    end

    #field :mana_symbols, type: Array
    attr_reader :mana_symbols
    validates_presence_of :mana_symbols
    validates :mana_symbols, presence: true, kind: { type: Enumerable }
    validate do
      if mana_symbols.kind_of? Enumerable
        characterized_mana_symbols = characterize_mana_symbols(mana_symbols)
        if errors.size == 0
          validate_mana_symbols_order characterized_mana_symbols
        end
      end
      # don't write error handling if mana_symbols is not a Enumerable object
      # because that is already written in above kind validation
    end

    def initialize(mana_symbols)
      @mana_symbols = mana_symbols
      raise ArgumentError.new(errors.full_messages) if invalid?
    end

    private
    def characterize_mana_symbols mana_symbols
      mana_symbols.map do |mana_symbol|
        if mana_symbol.kind_of? Symbol
          if MANA_SYMBOL_LIST.include? mana_symbol
            CHARACTERIZE_MANA_SYMBOL[mana_symbol]
          else
            errors.add(:mana_symbols, "#{mana_symbol}" +
                       " is not contained in Mana Symbol List")
          end
        elsif mana_symbol.kind_of? Integer
          if 0 <= mana_symbol
            "{#{mana_symbol}}"
          else
            errors.add(:mana_symbols, "#{mana_symbol} is not a Natural Number")
          end
        else
          errors.add(:mana_symbols, "#{mana_symbol}" +
                     " is neither a kind of Integer nor Symbol")
        end
      end
    end

    def validate_mana_symbols_order characterized_mana_symbols
      def regexp_alize hash_to_characterize
        characterized_colors = hash_to_characterize.values.map do |color|
          Regexp.escape color
        end
        "(#{characterized_colors.join('|')})"
      end

      x = /(#{regexp_alize(X_COLOR)})*/
      number = /(\{(0|[1-9]\d*)\})?/
      hybrid_color = /(#{regexp_alize(HYBRID_COLORS.\
                       merge(MONOCOLORED_HYBRID_COLORS))})*/
                         base_color = /(#{regexp_alize(BASIC_COLORS.merge(PHYREXIAN_COLORS))})*/
                         mana_symbols_order = /\A#{x}#{number}#{hybrid_color}#{base_color}\Z/
                         unless characterized_mana_symbols.join('') =~ mana_symbols_order
                           errors.add(:mana_symbols, "#{characterized_mana_symbols}" +
                                      " is invalid mana symbol order")
                         end
    end
  end
end
