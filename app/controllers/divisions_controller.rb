class DivisionsController < ApplicationController
  before_action :set_tournament, only: [:new, :create]
  before_action :set_division, only: [:show, :edit, :update, :destroy]

  def show
    if @division.pools_then_elimination?
      # Pool-stage matches are shown on each pool's own page; this page only
      # shows the playoff bracket, since round numbers reset per pool and
      # mixing them with playoff rounds under one heading is misleading.
      @pools = @division.pools.includes(competitors: {}).order(:name)
      @matches = @division.matches.where(pool_id: nil).order(:round, :id)
    else
      @matches = @division.matches.order(:round, :id)
      if @division.individual?
        @registrations = @division.tournament_registrations
                                  .includes(:competitor)
                                  .order(Arel.sql("seed ASC NULLS LAST"))
      else
        @team_entries = @division.team_entries
                                 .includes(:competitors)
                                 .order(Arel.sql("seed ASC NULLS LAST"))
      end
    end
  end

  def new
    @division = @tournament.divisions.build
  end

  def create
    @division = @tournament.divisions.build(division_params)
    if @division.save
      redirect_to @division
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @division.update(division_params)
      redirect_to @division
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    tournament = @division.tournament
    @division.destroy
    redirect_to tournament
  end

  private

  def set_tournament
    @tournament = Tournament.find(params[:tournament_id])
  end

  def set_division
    @division = Division.find(params[:id])
  end

  def division_params
    params.require(:division).permit(:name, :competition_type, :format, :status)
  end
end