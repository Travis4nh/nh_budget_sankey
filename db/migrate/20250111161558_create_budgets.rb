class CreateBudgets < ActiveRecord::Migration[7.2]
  def change
    create_table :budgets do |t|
      t.string :name
      t.references :timeperiod, null: false, foreign_key: true

      t.timestamps
    end
  end
end
