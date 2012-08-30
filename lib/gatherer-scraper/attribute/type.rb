# -*- encoding: utf-8 -*-

require 'gatherer-scraper/validations/kind_validator'
require 'gatherer-scraper/validations/unique_enumerable_validator'

module GathererScraper::Attribute
  class Type
    include ActiveModel::Validations
    include GathererScraper::Validations

    # imcomplete lists
    ALL_CARDTYPE_LIST = [:Land, :Creature, :Enchantment, :Artifact, :Instant,
                         :Tribal, :Sorcery, :Planeswalker]
    ALL_SUPERTYPE_LIST = [:Basic, :Legendary, :World, :Snow]
    attr_reader :supertypes
    validates :supertypes, unique_enumerable: true
    attr_reader :cardtypes
    validates :cardtypes, unique_enumerable: true, presence: true
    attr_reader :subtypes
    validates :subtypes, unique_enumerable: true, kind: { type: Enumerable, allow_nil: false }

    validate do
      errors.add(:supertypes, "#{supertypes} can't be nil") if supertypes == nil
      errors.add(:subtypes, "#{subtypes} can't be nil") if subtypes == nil
      if supertypes.kind_of? Enumerable
        supertypes.each do |supertype|
          unless ALL_SUPERTYPE_LIST.include? supertype
            errors.add(:supertypes, "#{supertype} is not a supertype.")
          end
        end
      end

      if cardtypes.kind_of? Enumerable
        cardtypes.each do |cardtype|
          unless ALL_CARDTYPE_LIST.include? cardtype
            errors.add(:cardtypes, "#{cardtype} is not a cardtype.")
          end
        end
        errors.add(:cardtypes, "This is a blank") if cardtypes.blank?
      else
        errors.add(:cardtypes, "#{cardtypes} is not a kind of #{Array}")
      end
    end
    def initialize(supertypes, cardtypes, subtypes)
      @supertypes = supertypes
      @cardtypes = cardtypes
      @subtypes = subtypes

      raise ArgumentError.new(errors.full_messages) if invalid?
    end
    def self.parse(node)
      _, supertype_and_cardtypes, subtypes =
        node.content.strip.match(/\A(.*?)(?:\s+—\s+(.*?))?\Z/).to_a
      s_c_types_symbol = supertype_and_cardtypes.split(' ').map {|t| t.to_sym}
      supertypes, cardtypes =
        s_c_types_symbol.partition{|symbol| ALL_SUPERTYPE_LIST.include? symbol}

      subtypes = if subtypes == nil
                   []
                 else
                   subtypes.split(' ').map {|t| t.to_sym}
                 end
      new(supertypes, cardtypes, subtypes)
    end
  end
end
