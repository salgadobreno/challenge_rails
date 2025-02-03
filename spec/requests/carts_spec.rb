require 'rails_helper'

RSpec.describe "/cart", type: :request do

  describe "GET /" do
    context "when there's no cart in the session" do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({})
      end

      it 'returns an empty json' do
        get cart_url
        expect(response).to be_successful
        expect(response.body).to eq("{}")
      end
    end

    context "when there's a cart in the session" do
      let(:cart) { create(:cart) }
      let(:product) { create(:product, name: "Test Product", price: 10.0) }
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      it 'returns cart JSON' do
        get cart_url
        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eq({
          id: cart.id,
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 1,
              unit_price: product.price.to_f,
              total_price: product.price.to_f
            }.stringify_keys
          ],
          total_price: product.price.to_f
        }.stringify_keys)
      end
    end
  end

  describe "POST /" do
    
  end

  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        skip
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
