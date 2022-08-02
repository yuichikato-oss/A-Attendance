Rails.application.routes.draw do

  root to: 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users do
    collection {post :import}
    
    member do
      get 'edit_basic_info'
      get 'edit_basic_info_admin'
      get 'working_list'
      patch 'update_basic_info'
      get 'attendance_log'
      get 'csv_export'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      
    end
    resources :attendances do
      get 'edit_overwork_reqest'
      get 'edit_overwork_notice'
      get 'edit_day_notice'
      
      patch 'update_overwork_reqest'
      
      collection do
        patch 'edit_overwork_approval'
        patch 'edit_day_approval'
      end
    end
  end
  resources :bases do
  end
end
