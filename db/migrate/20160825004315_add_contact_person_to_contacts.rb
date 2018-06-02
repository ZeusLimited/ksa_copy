class AddContactPersonToContacts < ActiveRecord::Migration[4.2]
  include MigrationHelper
  def change
    add_column :contacts, :contact_person, :text
    column_comment :contacts, :contact_person, 'Контактное лицо для PR-службы МСП'
  end
end
