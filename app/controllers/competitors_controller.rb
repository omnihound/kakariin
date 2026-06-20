class CompetitorsController < ApplicationController
  before_action :set_competitor, only: [:show, :edit, :update, :destroy]

  def index
    @competitors = Competitor.order(:last_name, :first_name)
  end

  def show; end

  def new
    @competitor = Competitor.new
  end

  def create
    @competitor = Competitor.new(competitor_params)
    if @competitor.save
      redirect_to @competitor
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @competitor.update(competitor_params)
      redirect_to @competitor
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @competitor.destroy
    redirect_to competitors_path
  end

  private

  def set_competitor
    @competitor = Competitor.find(params[:id])
  end

  def competitor_params
    params.require(:competitor).permit(:first_name, :last_name, :gender, :date_of_birth, :grade_rank, :grade_type, :country)
  end
end