class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :email
      t.string :phone
      t.text :address
      t.string :tax_id
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :clients, :active
  end
end
