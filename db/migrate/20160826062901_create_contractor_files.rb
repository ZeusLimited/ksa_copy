class CreateContractorFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :contractor_files, comment: 'Файлы контрагентов' do |t|
      t.integer :contractor_id, comment: 'ID контрагента', null: false
      t.integer :tender_file_id, comment: 'ID файла', null: false
      t.integer :file_type_id, comment: 'ID типа файла', null: false
      t.text :note, comment: 'Примечания'
    end
    add_index :contractor_files, :contractor_id, name: 'i_contractor_file_contractor'
  end
end
