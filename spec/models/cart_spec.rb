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

    it 'calculates total_price correctly' do
      expect(cart.total_price).to eq 7.96
    end
  end

  describe 'register_item' do
    let(:cart) { create(:cart) }

    it 'registers new item at the specified quantity' do
      expect {
        cart.register_item product: product1, quantity: 5
      }.to change(CartItem, :count).by(1)
      expect(cart.cart_items.last.quantity).to eq 5
    end

    it 'updates last_interaction_at' do
      expect(cart.last_interaction_at).to eq nil
      cart.register_item product: product1, quantity: 5
      expect(cart.last_interaction_at).not_to be_nil
    end

    context 'item was already in cart' do
      it 'overrides product quantity, does not duplicate cart products' do
        expect {
          cart.register_item product: product1, quantity: 5
          cart.register_item product: product1, quantity: 5
          cart.register_item product: product1, quantity: 5
          cart.register_item product: product1, quantity: 5
          cart.register_item product: product1, quantity: 10
        }.to change(CartItem, :count).by(1)
        expect(cart.cart_items.last.quantity).to eq 10
      end
    end

    context 'quantity is 0 or less' do
      it 'does nothing' do
        expect {
          cart.register_item product: product1, quantity: 0
          cart.register_item product: product1, quantity: -1
        }.to change(CartItem, :count).by(0)
      end
    end
  end

  describe 'add_item' do
    let(:cart) { create(:cart) }

    context 'product is not in cart' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product2, quantity: 3) }
      it 'does nothing' do
        expect {
          cart.reload.add_item product: product1, quantity: 3
        }.to change(CartItem, :count).by(0)
      end
    end

    context 'product is in cart' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product1, quantity: 3) }

      it 'sums item quantity' do
        cart.reload.add_item product: product1, quantity: 3
        expect(cart.cart_items.last.quantity).to eq 6
      end

      it 'updates last_interaction_at' do
        expect(cart.last_interaction_at).to eq nil
        cart.add_item product: product1, quantity: 5
        expect(cart.last_interaction_at).not_to be_nil
      end

      context 'quantity is negative' do
        it 'subtracts item quantity' do
          cart.reload.add_item product: product1, quantity: -2
          expect(cart.cart_items.last.quantity).to eq 1
        end

        it 'does not go less than 0' do
          cart.reload.add_item product: product1, quantity: -20
          expect(cart.cart_items.last.quantity).to eq 0
        end
      end

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
