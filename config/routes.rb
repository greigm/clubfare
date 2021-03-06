Clubfare::Application.routes.draw do

	resources :beers
	resources :brewers
	resources :users
	resources :streams
	resources :sessions, only: [:new, :create, :destroy]

	namespace :api do
		resources :beers
	end

	root 'streams#dash'

	match '/dash',		to: 'streams#dash',			via: 'get'
	match '/signin',	to: 'sessions#new',			via: 'get'
	match '/signout',	to: 'sessions#destroy',		via: 'delete'

	# Allow SSE streaming
	get 'streaming' => 'streams#update_stream', as: 'streaming'
	
	# Beer label generation
	match 'beers/:id/label' => 'beers#label', as: :beers_label, via: 'get'

	# Beer tasting notes
	match '/menu',			to: 'beers#menu',				via: 'get'
	match '/menushort',		to: 'beers#menushort',			via: 'get'
	
	# Empty kegs for return
	match '/empties',		to: 'beers#empties',	via: 'get'
	
end
