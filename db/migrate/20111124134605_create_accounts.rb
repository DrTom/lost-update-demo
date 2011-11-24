class CreateAccounts < ActiveRecord::Migration

  def up
    create_table :accounts do |t|
      t.integer :balance, :default => 0, :null => false
      t.integer :_update_token, :default => nil , :null => false
    end
  end

  def down
    drop_table :accounts
  end


end
