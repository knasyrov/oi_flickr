Oi::Application.routes.draw do
  root 'home#index'
  get '/search' => 'home#search'
end
