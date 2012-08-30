module GathererScraper::Validations
  class StripValidator < ActiveModel::Validations::FormatValidator
    def initialize(options)
      format = if options.delete :multiline
                 { with: STRIPED_LINES_REGEXP }
               else
                 { with: STRIPED_LINE_REGEXP }
               end
      super format.merge options
    end
  end
end
