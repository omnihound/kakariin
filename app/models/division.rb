class Division < ApplicationRecord
  belongs_to :tournament

  has_many :tournament_registrations, dependent: :destroy
  has_many :competitors, through: :tournament_registrations
  has_many :team_entries, dependent: :destroy
  has_many :pools, dependent: :destroy
  has_many :matches, dependent: :destroy

  enum :competition_type, { individual: "individual", team: "team" }
  enum :format, { single_elimination: "single_elimination", round_robin: "round_robin", pools_then_elimination: "pools_then_elimination" }
  enum :status, { pending: "pending", in_progress: "in_progress", completed: "completed" }

  validates :name, presence: true, uniqueness: { scope: :tournament_id }
end