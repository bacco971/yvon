class RestaurantsController < ApplicationController
  before_action :set_restaurant, only: [:show, :edit, :update, :duty]
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    @restaurants = Restaurant.where.not(latitude: nil, longitude: nil)

    @hash = Gmaps4rails.build_markers(@restaurants) do |restaurant, marker|
      marker.lat restaurant.latitude
      marker.lng restaurant.longitude
      # marker.infowindow render_to_string(partial: "/flats/map_box", locals: { flat: flat })
    end
  end

  def show
    @new_meal = @restaurant.meals.new
  end

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = current_user.restaurants.new(restaurant_params)
    # pundit approval
    # authorize @restaurant
    # @restaurant = Restaurant.new(restaurant_params)
    # @restaurant.user = current_user
    if @restaurant.save
      respond_to do |format|
        format.html { redirect_to @restaurant }
        format.js
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.js
      end
    end
  end

  def edit
  end

  def update
    @restaurant.update(restaurant_params)
    if @restaurant.save
      respond_to do |format|
        format.html { redirect_to @restaurant }
        format.js
      end
    else
      @new_meal = @restaurant.meals.new
      respond_to do |format|
        format.html { render :show }
        format.js
      end
    end
  end

  def duty
    @restaurant.on_duty = (params[:state] == "on" ? true : false)
    @restaurant.save
  end

  private

  def set_restaurant
    @restaurant = Restaurant.find(params[:id])
  end

  def restaurant_params
    params.require(:restaurant).permit(:name, :user_id, :address, :category, :on_duty, :shift, :photo, :description, :preperation_time, :facebook_url)
  end

end
