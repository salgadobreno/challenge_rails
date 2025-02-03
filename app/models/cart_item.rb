class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true

  validates :quantity, presence: true
  validates_numericality_of :quantity, greater_than_or_equal_to: 0

  def total_price
    quantity * product.price
  end

  def serializable_hash(options = nil)
    r = {
      id: product.id,
      name: product.name,
      quantity: quantity,
      total_price: total_price.to_f,
      unit_price: product.price.to_f
    }
    r
  end
end
