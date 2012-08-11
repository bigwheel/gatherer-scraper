class UniqueEnumerableValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (not value.kind_of? Enumerable)
      record.errors.add attribute, "This is not a kind of Enumerable"
    elsif value.uniq.size != value.size
      record.errors.add attribute, "This is not unique"
    end
  end
  module HelperMethods
    def validates_unique_enumerable_of(*attr_names)
      validates_with UniqueEnumerableValidator, _merge_attributes(attr_names)
    end
  end
end
