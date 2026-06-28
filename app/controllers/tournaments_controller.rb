class TournamentsController < ApplicationController
  before_action :set_tournament, only: [ :show, :edit, :update, :destroy ]

  def index
    @tournaments = Tournament.order(start_date: :desc)
  end

  def show
    @divisions = @tournament.divisions.order(:name)
  end

  def new
    @tournament = Tournament.new
  end

  def create
    @tournament = Tournament.new(tournament_params)
    if @tournament.save
      redirect_to @tournament
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @tournament.update(tournament_params)
      redirect_to @tournament
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tournament.destroy
    redirect_to tournaments_path
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:name, :location, :description, :start_date, :end_date, :status)
  end
end
