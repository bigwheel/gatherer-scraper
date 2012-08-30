module GathererScraper::Validations
  class KindValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value.kind_of? options[:type]
        record.errors.add attribute, "This is not a kind of #{options[:type]}"
      end
    end

    module HelperMethods
      def validates_kind_of(*attr_names)
        validates_with KindValidator, _merge_attributes(attr_names)
      end
    end
  end
end
