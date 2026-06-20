module Divisions
  class RegistrationsController < ApplicationController
    before_action :set_division

    def index
      @registrations = @division.tournament_registrations
                                 .includes(:competitor)
                                 .order(Arel.sql("seed ASC NULLS LAST"))
      @available_competitors = Competitor.where.not(id: @division.tournament_registrations.select(:competitor_id))
                                          .order(:last_name, :first_name)
    end

    def create
      @registration = @division.tournament_registrations.build(registration_params)
      if @registration.save
        redirect_to division_registrations_path(@division)
      else
        redirect_to division_registrations_path(@division), alert: @registration.errors.full_messages.to_sentence
      end
    end

    def update
      registration = @division.tournament_registrations.find(params[:id])
      if registration.update(registration_params)
        redirect_to division_registrations_path(@division)
      else
        redirect_to division_registrations_path(@division), alert: registration.errors.full_messages.to_sentence
      end
    end

    def destroy
      @division.tournament_registrations.find(params[:id]).destroy
      redirect_to division_registrations_path(@division)
    end

    private

    def set_division
      @division = Division.find(params[:division_id])
    end

    def registration_params
      params.require(:tournament_registration).permit(:competitor_id, :seed, :status)
    end
  end
end