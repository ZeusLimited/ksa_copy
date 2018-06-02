class AddBpStateToPlanLots < ActiveRecord::Migration[4.2]
  def change
    add_column :plan_specifications, :bp_state_id, :integer, comment: 'Ссылка на номер бюджетного кодификатора'
  end
end
