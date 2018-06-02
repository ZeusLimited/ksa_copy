module Sortable
  extend ActiveSupport::Concern

  included do
    attr_writer :sort_column, :sort_direction
  end

  private
    def sort_direction
      @sort_direction || 'asc'
    end

    def sort_direction_desc?
      @sort_direction == 'desc'
    end

    def sort_column
      @sort_column || 'id'
    end

    def max_sort_column(obj)
      @max_sort_column ||= obj.map(&"#{sort_column}".to_sym).compact.max
      @max_sort_column
    end
end
