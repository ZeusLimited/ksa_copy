# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  class << self
    def multi_value_filter(expression, search_string)
      search_string
        .strip
        .split(/[\s,]+/)
        .map { |w| sanitize_sql([expression, "#{w}%"]) }
        .compact
        .join(' OR ')
    end
  end
end
