class CreateAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :account_tiers do |t|
      t.string :name
      t.references :budget, null: false, foreign_key: true
      t.timestamps
    end

    create_table :accounts do |t|
      t.string :name
      t.references :account_tier, null: false, foreign_key: true

      t.timestamps
    end


  end
end
