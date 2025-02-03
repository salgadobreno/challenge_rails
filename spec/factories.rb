FactoryBot.define do
  factory :cart, class: "Cart" do
  end

  factory :shopping_cart, class: "Cart" do
  end

  factory :product do
    name { "Test Product" }
    price { 10.0 }
  end

  factory :cart_item do
    cart
    product
    quantity { 1 }
  end
end
