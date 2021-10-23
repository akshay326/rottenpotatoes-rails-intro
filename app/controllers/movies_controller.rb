class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.order(:rating).select(:rating).map(&:rating).uniq
    @ratings_to_show = []
    @checked_ratings = check
    @checked_ratings.each do |rating|
      params[rating] = true
    end

    # update session from incoming params
    session[:checked_ratings] = @checked_ratings if @checked_ratings
    session[:ordered_by] = @ordered_by if @ordered_by

    if params[:sort]
      @movies = Movie.order(params[:sort])
    else
      @movies = Movie.where(:rating => @checked_ratings)
    end

    if params[:sort] && @checked_ratings != @all_ratings
      @movies = Movie.where(:rating => @checked_ratings).order(params[:sort])
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def check
    if params[:ratings]
      if params[:ratings].kind_of?(Array)
        params[:ratings]
      else
        params[:ratings].keys
      end
    else
      @all_ratings
    end
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
