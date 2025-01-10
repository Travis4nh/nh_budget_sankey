class CreateTransfers < ActiveRecord::Migration[7.2]
  def change
    create_table :transfers do |t|
      t.decimal :amount
      t.references :from, null: false, foreign_key: true
      t.references :to, null: false, foreign_key: true

      t.timestamps
    end
  end
end
