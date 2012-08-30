require 'gatherer-scraper/validations/kind_validator'

module GathererScraper::Attribute
  class PT
    include ActiveModel::Validations
    include GathererScraper::Validations

    PT_REGEXP = /(?:-?\d+)|(?:\d+[\+-])?(?:\*)/
    SURROUNDED_PT_REGEXP = /\A#{PT_REGEXP}\Z/
    attr_reader :power
    validates :power, presence: true, format: { with: SURROUNDED_PT_REGEXP },
      kind: { type: String }
    attr_reader :toughness
    validates :toughness, presence: true, format: { with: SURROUNDED_PT_REGEXP },
      kind: { type: String }
    def initialize(power, toughness)
      @power = power
      @toughness = toughness

      raise ArgumentError.new(errors.full_messages) if invalid?
    end
    def self.parse(node)
      if node == nil
        nil
      else
        pt_regexp = /^(#{PT_REGEXP.to_s}) \/ (#{PT_REGEXP.to_s})$/
        _, power, toughness = node.content.strip.match(pt_regexp).to_a
        new power, toughness
      end
    end
  end
end
