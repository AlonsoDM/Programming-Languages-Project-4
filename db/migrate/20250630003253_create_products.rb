class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.integer :stock_quantity, default: 0
      t.integer :minimum_stock, default: 0
      t.references :tax_rate, null: false, foreign_key: true
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :products, :sku, unique: true
    add_index :products, :active
  end
end
