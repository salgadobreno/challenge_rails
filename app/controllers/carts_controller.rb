class CartsController < ApplicationController
  before_action :set_cart

  def show
    render json: @cart || {}
  end

  def create
    
  end

  private 

  def set_cart
    return unless session[:cart_id]

    @cart = Cart.find session[:cart_id]
  end
end
