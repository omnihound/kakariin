require "tournament_system"

module Divisions
  class BracketController < ApplicationController
    before_action :set_division

    def create
      if pending_matches?
        redirect_to @division, alert: "Complete all pending matches before generating the next round." and return
      end

      case @division.format
      when "single_elimination"
        TournamentSystem::SingleElimination.generate(TournamentDriver.new(@division))
      when "round_robin"
        TournamentSystem::RoundRobin.generate(TournamentDriver.new(@division))
      when "pools_then_elimination"
        generate_pools_then_elimination
      end

      redirect_to @division, notice: "Next round generated."
    rescue => e
      redirect_to @division, alert: "Could not generate bracket: #{e.message}"
    end

    private

    def set_division
      @division = Division.find(params[:division_id])
    end

    def pending_matches?
      @division.matches.where(status: %w[pending in_progress]).exists?
    end

    # While any pool still has rounds left to play, advance each pool that's
    # ready. Once every pool has completed its full round-robin, seed and
    # generate the single-elimination playoff bracket from pool standings.
    def generate_pools_then_elimination
      if pool_stage_complete?
        TournamentSystem::SingleElimination.generate(TournamentDriver.new(@division))
      else
        @division.pools.each do |pool|
          next if pool_complete?(pool)
          TournamentSystem::RoundRobin.generate(PoolDriver.new(pool))
        end
      end
    end

    def pool_stage_complete?
      @division.pools.any? && @division.pools.all? { |pool| pool_complete?(pool) }
    end

    def pool_complete?(pool)
      rounds_played = pool.pool_matches.maximum(:round) || 0
      rounds_played >= TournamentSystem::RoundRobin.total_rounds(PoolDriver.new(pool))
    end
  end
end