class PT
  include ActiveModel::Validations
  PT_REGEXP = /(?:-?\d+)|(?:\d+[\+-])?(?:\*)/
  SURROUNDED_PT_REGEXP = /\A#{PT_REGEXP}\Z/
  attr_reader :power
  validates :power, presence: true, format: { with: SURROUNDED_PT_REGEXP },
    kind: { type: String }
  attr_reader :toughness
  validates :toughness, presence: true, format: { with: SURROUNDED_PT_REGEXP },
    kind: { type: String }
  validates_presence_of :toughness
  validates_format_of :toughness, with: SURROUNDED_PT_REGEXP
  def initialize(power, toughness)
    @power = power
    @toughness = toughness

    raise ArgumentError.new(errors.full_messages) if invalid?
  end
  def self.parse(node)
    if node == nil
      nil
    else
      match_data = node.content.strip.match(/^(#{PT_REGEXP.to_s}) \/ (#{PT_REGEXP.to_s})$/)
      CardProperty.validate_using_exception(new(match_data[1], match_data[2]))
    end
  end
end
