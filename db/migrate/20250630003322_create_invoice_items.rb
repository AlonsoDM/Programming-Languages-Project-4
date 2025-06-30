class CreateInvoiceItems < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.decimal :unit_price, precision: 10, scale: 2, null: false
      t.decimal :tax_rate, precision: 5, scale: 2, null: false
      t.decimal :line_total, precision: 10, scale: 2, null: false
      t.decimal :tax_amount, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :invoice_items, [:invoice_id, :product_id]
  end
end
