class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.belongs_to :cart, null: false
      t.belongs_to :product, null: false
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
