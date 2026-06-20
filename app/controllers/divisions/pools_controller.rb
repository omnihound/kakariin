module Divisions
  class PoolsController < ApplicationController
    before_action :set_division, only: [:index, :new, :create]
    before_action :set_pool, only: [:show, :edit, :update, :destroy]

    def index
      @pools = @division.pools.includes(:competitors).order(:name)
    end

    def show
      @registrations = @pool.pool_registrations.includes(:competitor).order(Arel.sql("seed ASC NULLS LAST"))
      @available_competitors = Competitor.where.not(id: @pool.competitors.select(:id))
                                          .order(:last_name, :first_name)
    end

    def new
      @pool = @division.pools.build
    end

    def create
      @pool = @division.pools.build(pool_params)
      if @pool.save
        redirect_to @pool
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @pool.update(pool_params)
        redirect_to @pool
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      division = @pool.division
      @pool.destroy
      redirect_to division
    end

    private

    def set_division
      @division = Division.find(params[:division_id])
    end

    def set_pool
      @pool = Pool.find(params[:id])
    end

    def pool_params
      params.require(:pool).permit(:name, :advancing_count, :status)
    end
  end
end