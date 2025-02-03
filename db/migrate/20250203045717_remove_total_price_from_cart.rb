class RemoveTotalPriceFromCart < ActiveRecord::Migration[7.1]
  def change
    remove_column :carts, :total_price
  end
end
