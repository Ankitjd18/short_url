Rails.application.routes.draw do
  get '/:url_code' => 'api/v1/mini_url#full_url'
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      # APIs to generate miniurl, signup and login
      post 'miniurl' => 'mini_url#create'
      post 'signup' => 'users#create'
      post 'login' => 'sessions#login'
      put 'token/refresh' => 'sessions#refresh_token'
      delete 'logout' => 'sessions#destroy'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
