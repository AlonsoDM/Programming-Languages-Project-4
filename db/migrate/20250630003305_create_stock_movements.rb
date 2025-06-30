class CreateStockMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.string :movement_type, null: false # 'in' or 'out'
      t.integer :quantity, null: false
      t.text :notes
      t.datetime :movement_date, null: false

      t.timestamps
    end

    add_index :stock_movements, [:product_id, :movement_date]
    add_index :stock_movements, :movement_type
  end
end
