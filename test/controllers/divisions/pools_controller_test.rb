require "test_helper"

module Divisions
  class PoolsControllerTest < ActionDispatch::IntegrationTest
    setup { sign_in_as(users(:one)) }

    test "generate creates pools and distributes confirmed registrations" do
      division = Division.create!(tournament: tournaments(:states), name: "Fresh Pools",
                                   competition_type: "individual", format: "pools_then_elimination")
      [ :hiroshi, :sarah, :james, :yuki ].each_with_index do |key, i|
        TournamentRegistration.create!(competitor: competitors(key), division: division, seed: i + 1, status: "confirmed")
      end

      post generate_division_pools_path(division), params: { pool_count: 2, advancing_count: 1 }

      assert_redirected_to division
      assert_equal 2, division.pools.count
      assert_equal 4, division.pools.sum { |p| p.pool_registrations.count }
    end

    test "generate redirects with an alert when the division already has pools" do
      post generate_division_pools_path(divisions(:pools)), params: { pool_count: 2, advancing_count: 1 }

      assert_redirected_to divisions(:pools)
      assert_equal "division already has pools", flash[:alert]
    end
  end
end