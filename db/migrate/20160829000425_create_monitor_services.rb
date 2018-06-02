class CreateMonitorServices < ActiveRecord::Migration[4.2]
  def change
    create_table :monitor_services, comment: 'Таблица для заполнения курирующих подразделений' do |t|
      t.integer :department_id, null: false, comment: 'ИД курирующего подразделения'
    end
  end
end
