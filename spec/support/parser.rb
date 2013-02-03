module SpecSupport
  module Parser

    def count_elements(element_type)
      parser[:schemas].inject(0) { |count, schema|
        count + schema[element_type].count
      }
    end

    def find_element(element_type, element_name)
      all_elements(element_type)[element_name]
    end

    def all_elements(element_type)
      parser[:schemas].inject({}) { |memo, schema|
        memo.merge schema[element_type]
      }
    end

  end
end
