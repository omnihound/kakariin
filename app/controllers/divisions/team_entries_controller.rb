module Divisions
  class TeamEntriesController < ApplicationController
    before_action :set_division, only: [ :index, :new, :create ]
    before_action :set_team_entry, only: [ :show, :edit, :update, :destroy ]

    def index
      @team_entries = @division.team_entries.includes(:competitors).order(Arel.sql("seed ASC NULLS LAST"))
    end

    def show
      @available_competitors = Competitor.where.not(id: @team_entry.competitors.select(:id))
                                          .order(:last_name, :first_name)
    end

    def new
      @team_entry = @division.team_entries.build
    end

    def create
      @team_entry = @division.team_entries.build(team_entry_params)
      if @team_entry.save
        redirect_to @team_entry
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @team_entry.update(team_entry_params)
        redirect_to @team_entry
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      division = @team_entry.division
      @team_entry.destroy
      redirect_to division
    end

    private

    def set_division
      @division = Division.find(params[:division_id])
    end

    def set_team_entry
      @team_entry = TeamEntry.find(params[:id])
    end

    def team_entry_params
      params.require(:team_entry).permit(:name, :seed, :status)
    end
  end
end
