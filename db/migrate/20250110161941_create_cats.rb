class CreateCats < ActiveRecord::Migration[7.2]
  def change
    create_table :cats do |t|
      t.string :name
      t.references :budget, null: false, foreign_key: true

      t.timestamps
    end
  end
end
