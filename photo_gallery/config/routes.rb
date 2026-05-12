Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations, :passwords, :confirmations, :unlocks ]

  root "photos#index"

  resources :photos, only: %i[index] do
    resource :like, only: %i[create destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
