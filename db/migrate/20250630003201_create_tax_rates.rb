class CreateTaxRates < ActiveRecord::Migration[8.0]
  def change
    create_table :tax_rates do |t|
      t.string :name, null: false
      t.decimal :rate, precision: 5, scale: 2, null: false
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :tax_rates, :active
  end
end
