class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :cart, presence: true
  validates :product, presence: true

  validates :quantity, presence: true
  validates_numericality_of :quantity, greater_than_or_equal_to: 0
end
