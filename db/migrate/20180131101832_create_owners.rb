class CreateOwners < ActiveRecord::Migration
  def change
    create_table :owners do |t|
      t.string :name
      t.string :company_name
      t.string :owner_national_number
      t.boolean :company
      t.date :birthday

      t.timestamps null: false
    end
  end
end
