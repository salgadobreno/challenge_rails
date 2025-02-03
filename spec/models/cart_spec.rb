require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:product1) {
    create(
      :product, 
      name: "Nome do produto",
      price: 1.99
    )
  }
  let(:product2) {
    create(
      :product, 
      name: "Nome do produto 2",
      price: 1.99
    )
  }

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end

  describe 'total_price' do
    it 'calculates total_price correctly' do
      cart = create(
        :cart,
        cart_items: [
          build(
            :cart_item,
            product: product1,
            quantity: 2
          ),
          build(
            :cart_item,
            product: product2,
            quantity: 2
          )
        ]
      )
      
      expect(cart.total_price).to eq 7.96
    end
  end

  describe 'serialization' do
    let(:cart) { 
      create(
        :cart,
        cart_items: [
          build(
            :cart_item,
            product: product1,
            quantity: 2
          ),
          build(
            :cart_item,
            product: product2,
            quantity: 2
          )
        ]
      )
    }
    let(:expectation) {
      {
        "id" => cart.id,
        "products" => [
          {
            "id" => product1.id,
            "name" => "Nome do produto",
            "quantity" => 2,
            "unit_price" => 1.99,
            "total_price" => 3.98,
          },
          {
            "id" => product2.id,
            "name" => "Nome do produto 2",
            "quantity" => 2,
            "unit_price" => 1.99,
            "total_price" => 3.98,
          },
        ],
        "total_price" => 7.96
      }
    }

    it 'serializes correctly' do
      expect(cart.as_json).to eq(expectation)
    end
  end
end
