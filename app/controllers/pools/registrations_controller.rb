module Pools
  class RegistrationsController < ApplicationController
    before_action :set_pool

    def index
      @registrations = @pool.pool_registrations.includes(:competitor).order(Arel.sql("seed ASC NULLS LAST"))
    end

    def create
      @registration = @pool.pool_registrations.build(registration_params)
      if @registration.save
        redirect_to @pool
      else
        redirect_to @pool, alert: @registration.errors.full_messages.to_sentence
      end
    end

    def update
      registration = @pool.pool_registrations.find(params[:id])
      if registration.update(registration_params)
        redirect_to @pool
      else
        redirect_to @pool, alert: registration.errors.full_messages.to_sentence
      end
    end

    def destroy
      @pool.pool_registrations.find(params[:id]).destroy
      redirect_to @pool
    end

    private

    def set_pool
      @pool = Pool.find(params[:pool_id])
    end

    def registration_params
      params.require(:pool_registration).permit(:competitor_id, :seed)
    end
  end
end