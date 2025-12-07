Rails.application.routes.draw do
  # Devise routes should be at root level, but use controllers in namespaces
  devise_for :users,
             path: 'api/v1/users',
             controllers: {
               sessions: 'api/v1/users/sessions',
               registrations: 'api/v1/users/registrations'
             },
             path_names: { 
               sign_in: 'sign_in', 
               sign_out: 'sign_out', 
               registration: 'sign_up' 
             },
             defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      resources :books do
        collection do
          get 'search' # composite search
        end
      end

      resources :reservations, only: [:index, :create, :show, :update, :destroy]
      
      namespace :users do
        get 'profile', to: 'profile#show'
      end
    end
  end
end
