class CreateTransfers < ActiveRecord::Migration[7.2]
  def change
    create_table :transfers do |t|
      t.references :budget, null: false, foreign_key: true
      t.references :source, null: false, foreign_key: {to_table: :accounts}
      t.references :dest, null: false, foreign_key: {to_table: :accounts}
      t.decimal :amount

      t.timestamps
    end
  end
end
