class CardNumber
  include ActiveModel::Validations
  attr_reader :number
  validates :number, presence: true, kind: { type: Integer },
    numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  attr_reader :face
  validates :face, kind: { type: Symbol, allow_nil: true },
    inclusion: { in: [ :a, :b ], allow_nil: true }
  def initialize(number, face)
    @number = number
    @face = face

    raise ArgumentError.new(errors.full_messages) if invalid?
  end
  def self.parse(node)
    return nil if node == nil

    match_data = node.content.strip.match(/\A(\d*)([ab])?\Z/)
    number = match_data[1].to_i
    face = match_data[2] ? match_data[2].to_sym : nil
    new(number, face)
  end
end
