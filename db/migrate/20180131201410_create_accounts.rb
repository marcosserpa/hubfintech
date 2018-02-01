class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.float :balance
      t.string :status
      t.boolean :main
      t.references :parent, index: true, null: true

      t.timestamps null: false
    end
  end
end
