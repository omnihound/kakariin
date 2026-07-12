class CourtsController < ApplicationController
  allow_unauthenticated_access only: :live

  before_action :set_tournament, only: [ :index, :new, :create ]
  before_action :set_court, only: [ :show, :live, :edit, :update, :destroy ]

  def index
    @courts = @tournament.courts.order(:name)
  end

  def show; end

  # Public, no-login single-court scoreboard for a venue screen at that
  # ring — same read-only board as tournaments#live, just scoped to one court.
  def live; end

  def new
    @court = @tournament.courts.build
  end

  def create
    @court = @tournament.courts.build(court_params)
    if @court.save
      redirect_to @court.tournament
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @court.update(court_params)
      redirect_to @court.tournament
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    tournament = @court.tournament
    @court.destroy
    redirect_to tournament
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def set_court
    @court = Court.find(params[:id])
  end

  def court_params
    params.require(:court).permit(:name)
  end
end
