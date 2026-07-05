class CourtsController < ApplicationController
  before_action :set_tournament, only: [ :new, :create ]
  before_action :set_court, only: [ :edit, :update, :destroy ]

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
