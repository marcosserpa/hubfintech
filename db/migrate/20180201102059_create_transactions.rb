class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :destination
      t.string :origin
      t.string :code
      t.boolean :reversal, default: false
      t.float :value

      t.timestamps null: false
    end
  end
end
