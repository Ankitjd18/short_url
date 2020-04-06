Rails.application.routes.draw do
  get '/:url_code' => 'api/v1/mini_url#full_url'
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      post 'miniurl' => 'mini_url#create'
      post 'signup' => 'users#create'
      post 'login' => 'users#login'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
