class CreateDebts < ActiveRecord::Migration[8.1]
  def change
    create_table :debts do |t|
      t.string :name
      t.decimal :value
      t.date :date

      t.timestamps
    end
  end
end
