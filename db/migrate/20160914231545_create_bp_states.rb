class CreateBpStates < ActiveRecord::Migration[4.2]
  def change
    create_table :bp_states, comment: 'Справочник бюджетный кодификатор' do |t|
      t.string :num, comment: 'Номер бюджетного кодификатора', null: false
      t.string :name, comment: 'Наименование', null: false
    end
  end
end
