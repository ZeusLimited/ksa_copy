module AxlsxExt
  # Класс для авто объединения ячеек в заголовке таблиц
  #
  # следующие данные:
  #
  # | name1 | nil | name2 | name3 | nil   | name4 |
  # | nil   | nil | nil   | name5 | name6 | nil   |
  # | 1     | 2   | 3     | 4     | 5     | 6     |
  #
  # преобразуются в:
  #
  # |     name1   | name2 |     name3     | name4 |
  # |             |       | name5 | name6 |       |
  # | 1     | 2   | 3     | 4     | 5     | 6     |
  class AutoMergeNil
    def self.merge_rows(rows)
      rows.each_with_index do |r, r_i|
        r.cells.each_with_index do |c, c_i|
          unless c.value.nil?
            last_cell = rows[get_last_row_index(rows, c_i, r_i)].cells[get_last_col_index(rows, c_i, r_i)]
            c.merge(last_cell) if c != last_cell
          end
        end
      end
    end

    def self.get_last_col_index(rows, col_index, row_index)
      row = rows[row_index]
      if  row.cells.size > col_index + 1 &&
          row.cells[col_index + 1].value.nil? &&
          rows[0..row_index].all? { |r| r.cells[col_index + 1].value.nil? }
        get_last_col_index(rows, col_index + 1, row_index)
      else
        col_index
      end
    end

    def self.get_last_row_index(rows, col_index, row_index)
      if rows.size > row_index + 1 && rows[row_index + 1].cells[col_index].value.nil?
        get_last_row_index(rows, col_index, row_index + 1)
      else
        row_index
      end
    end
  end

  # Класс для формул
  class Formula
    # суммирует ячейки по индексам в колонке
    def self.sum_numbers_by_column(column, numbers)
      cells = numbers.map { |n| "#{column}#{n}" }
      cells.size > 0 ? "=#{cells.join('+')}" : 0
    end

    # суммирует все значения в колонке между начальным и конечным индексом
    def self.sum_by_column(column, start_index, end_index)
      format('=SUM(%s%s:%s%s)', column, start_index, column, end_index)
    end

    # суммирует все значения в колонке между начальным и конечным индексом удовлетворяющие условию
    def self.sum_by_column_if(column_if, column_sum, criteria, start_index, end_index)
      range = format('%s%s:%s%s', column_if, start_index, column_if, end_index)
      sum_range = format('%s%s:%s%s', column_sum, start_index, column_sum, end_index)
      format '=SUMIF(%s,%s,%s)', range, criteria, sum_range
    end

    def self.del_eq(formula)
      formula[1..-1]
    end
  end

  class SimpleSheet
    def initialize(sheet, columns_count, styles = nil)
      @sheet, @columns_count, @styles = sheet, columns_count, styles
    end

    def add_row_title(text, options = {})
      cc = options[:columns_count] || @columns_count
      ii = options[:initial_index] || 0
      mc = options[:merge_count] || (cc - ii)

      values = Array.new(cc)
      values[ii] = text
      row = @sheet.add_row(values, options)
      @sheet.merge_cells row.cells.first(mc)
      row
    end

    def row_values
      Array.new(@columns_count)
    end

    def change_column_widths(col_widths = nil)
      widths = col_widths.is_a?(Array) ? col_widths : Array.new(@columns_count) { col_widths || 30 }
      @sheet.column_widths(*widths)
    end

    def add_rows_from_csv(file, col_sep = ';', style = :th)
      head_rows = CSV.read(file, col_sep: col_sep)
      rows = []
      head_rows.each { |head_row| rows << @sheet.add_row(head_row, style: @styles[style]) }
      AutoMergeNil.merge_rows(rows)
      rows
    end
  end
end
