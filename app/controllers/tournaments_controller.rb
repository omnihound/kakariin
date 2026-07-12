class TournamentsController < ApplicationController
  allow_unauthenticated_access only: :live

  before_action :set_tournament, only: [ :show, :live, :edit, :update, :destroy ]

  def index
    @tournaments = Tournament.order(start_date: :desc)
  end

  def show
    @divisions = @tournament.divisions.order(:name)
    @courts = @tournament.courts.order(:name)
  end

  # Public, no-login scoreboard for spectators/venue screens — read-only,
  # updates live via the same Turbo Streams the court board broadcasts to.
  def live
    @courts = @tournament.courts.order(:name)
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
