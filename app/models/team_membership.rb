class TeamMembership < ApplicationRecord
  belongs_to :team_entry
  belongs_to :competitor

  validates :competitor_id, uniqueness: { scope: :team_entry_id }
end
