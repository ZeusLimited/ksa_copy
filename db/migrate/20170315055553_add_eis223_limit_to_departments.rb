class AddEis223LimitToDepartments < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column_with_comment :departments,
      :eis223_limit,
      :decimal,
      precision: 18, scale: 2,
      comment: 'Лимит установленный п. 15 ст. 4 223-ФЗ'
  end
end
