Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "oauth/connect_with_silverfin" => "oauth#silverfin_init"
  get "oauth/silverfin" => "oauth#silverfin_create"
  get "oauth/logout" => "oauth#logout", as: :logout

  root "home#index"
end
