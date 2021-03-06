Rails.application.routes.draw do
 #Devise自動建立通往認證使用者的功能
 devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

 #前台首頁
resources :restaurants, only: [:index, :show] do

   resources :comments, only: [:create, :destroy]


   collection do
     # 瀏覽所有餐廳的最新動態
     # GET restaurants/feeds
     get :feeds

     #十大人氣餐廳
     get :ranking
   end

    member do
    # 瀏覽個別餐廳的 Dashboard
    # GET restaurants/:id/dashboard
     get :dashboard

    # 收藏 / 取消收藏
     post :favorite
     post :unfavorite
    end
end

  resources :users, only: [:index, :show, :edit, :update] do
    member do
      get :friend_list
    end
  end


  resources :categories,only: :show
  root "restaurants#index"

  resources :followships, only: [:create, :destroy]
  resources :friendships, only: [:create, :destroy]


#後台功能:Restaurant CRUD & Categories CRUD以及後台首頁
namespace :admin do
  resources :restaurants
  resources :categories
  root "restaurants#index"
 end

end
