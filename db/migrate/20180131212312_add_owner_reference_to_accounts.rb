class AddOwnerReferenceToAccounts < ActiveRecord::Migration
  def change
    add_reference :accounts, :owner, index: true, foreign_key: true
  end
end
