FactoryBot.define do
  factory :cart_item do
    
  end

  factory :shopping_cart, class: "Cart" do
    total_price { 0 }
  end
end
