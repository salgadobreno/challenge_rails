require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'relationships' do
    let(:cart_item) { build(:cart_item) }
    it 'has a product' do
      expect(cart_item).to respond_to(:product)
    end
    it 'belongs to a cart' do
      expect(cart_item).to respond_to(:cart)
    end
  end

  describe 'validations' do
    it 'validates the presence of quantity' do
      cart_item = build(:cart_item, quantity: nil)
      expect(cart_item.valid?).to be false
      expect(cart_item.errors[:quantity]).to include("can't be blank")
    end

    it 'validates numericality of quantity' do
      cart_item = build(:cart_item, quantity: "abc")
      expect(cart_item.valid?).to be false
      expect(cart_item.errors[:quantity]).to include("is not a number")
    end

    it 'validates quantity is greater than 0' do
      cart_item = build(:cart_item, quantity: -1)
      expect(cart_item.valid?).to be false
      expect(cart_item.errors[:quantity]).not_to be_empty 
    end

    it 'validates the presence of cart' do
      cart_item = build(:cart_item, cart: nil)
      expect(cart_item.valid?).to be false
      expect(cart_item.errors[:cart]).to include("can't be blank")
    end

    it 'validates the presence of product' do
      cart_item = build(:cart_item, product: nil)
      expect(cart_item.valid?).to be false
      expect(cart_item.errors[:product]).to include("can't be blank")
    end
  end

  describe 'total_price' do
    it 'multiplies unit price by quantity' do
      product = create(:product, price: 10)
      cart_item = build(:cart_item, product:, quantity: 3)

      expect(cart_item.total_price).to eq 30
    end
  end

  describe 'serializable_hash' do
    it 'returns the correct hash' do
      product = create(:product, name: "Test Product", price: 10)
      cart_item = build(:cart_item, product: product, quantity: 3)

      expect(cart_item.serializable_hash).to eq({
        id: product.id,
        name: "Test Product",
        quantity: 3,
        total_price: 30,
        unit_price: 10
      })
    end
  end
end
