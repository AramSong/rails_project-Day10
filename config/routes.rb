Rails.application.routes.draw do

  #cafe
  resources :cafes, except: [:destroy]
  post '/join_cafe/:cafe_id' => 'cafes#join_cafe', as: 'join_cafe'

  #authenticate
  get '/sign_up' => 'authenticate#sign_up'
  post '/sign_up' => 'authenticate#user_sign_up'
  get '/sign_in' => 'authenticate#sign_in'
  post '/sign_in' => 'authenticate#user_sign_in'
  delete '/sign_out' => 'authenticate#sign_out'
  get '/user_info/:user_name' => 'authenticate#user_info'


  post 'posts/:id/comments/create' => 'comments#create'
  delete 'comments/:id' => 'comments#destroy'
  
  get 'comments/destroy'
  


  resources :posts
  root 'cafes#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
