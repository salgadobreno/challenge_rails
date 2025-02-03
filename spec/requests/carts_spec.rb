require 'rails_helper'

RSpec.describe "/cart", type: :request do
  let(:product) { create(:product, name: "Test Product", price: 10.0) }

  describe "GET /" do
    context "when there's no cart in the session" do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({})
      end

      it 'returns an empty JSON' do
        get cart_url, as: :json
        expect(response).to be_successful
        expect(response.body).to eq("{}")
      end
    end

    context "when there's a cart in the session" do
      let(:cart) { create(:cart) }
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
      end

      it 'returns cart JSON' do
        get cart_url, as: :json
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
    context 'no previous cart in session' do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({})
      end

      it 'creates cart with requested items and returns cart JSON' do
        product_id = product.id
        quantity = 10
        unit_price = product.price.to_f
        total_price = 10 * unit_price

        post '/cart', params: { product_id:, quantity: }, as: :json
        expect(response).to be_successful
        expect(JSON.parse(response.body)).to have_key "id"
        expect(JSON.parse(response.body)).to include({
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: quantity,
              unit_price: unit_price,
              total_price: total_price
            }.stringify_keys
          ],
          total_price: total_price
        }.stringify_keys)
      end
    end

    context 'already existing cart in session' do
      let(:cart) { create(:cart) }

      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({cart_id: cart.id})
      end

      it 'adds requested items to cart and returns cart JSON' do
        product_id = product.id
        quantity = 10
        unit_price = product.price.to_f
        total_price = 10 * unit_price

        post '/cart', params: { product_id:, quantity: }, as: :json
        expect(response).to be_successful
        expect(JSON.parse(response.body)).to eq({
          id: cart.id,
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: quantity,
              unit_price: unit_price,
              total_price: total_price
            }.stringify_keys
          ],
          total_price: total_price
        }.stringify_keys)
      end
    end
  end

  describe "POST /add_item" do
    let(:cart) { Cart.create }

    before do
      allow_any_instance_of(CartsController).to receive(:session).and_return({cart_id: cart.id})
    end

    context 'when the product already is in the cart' do
      let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end
end
