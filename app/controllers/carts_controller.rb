class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: @cart || {}
  end

  def create
    if !@cart
      @cart = Cart.create!
      session[:cart_id] = @cart.id
    end
    product = Product.find item_params.require(:product_id)
    quantity = item_params.require(:quantity).to_i
    @cart.register_item(product:, quantity:)

    render json: @cart
  end

  def add_item
    return unless @cart

    product = Product.find item_params.require(:product_id)
    quantity = item_params.require(:quantity).to_i
    @cart.add_item(product:, quantity:)

    render json: @cart
  end

  private 

  def set_cart
    return unless session[:cart_id]

    @cart = Cart.find session[:cart_id]
  end

  def item_params
    params.permit(:product_id, :quantity)
  end
end
