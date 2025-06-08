Rails.application.routes.draw do
  get '/sheets/new', to: 'sheets#new', as: :new_sheet
  match '/sheets/auth', to: 'sheets#auth', via: [:get, :post], as: :auth_sheet
  get '/sheets/callback', to: 'sheets#callback'
  get '/sheets/update', to: 'sheets#update', as: :update_sheet

  # Route cho OAuth flow
  get '/auth/google_oauth2', to: 'sheets#oauth_redirect'
  
  # Route cho OAuth callback
  get '/auth/callback', to: 'sheets#callback'

  root 'home#index' # Tùy chọn
end
