class TournamentRegistration < ApplicationRecord
  belongs_to :competitor
  belongs_to :division

  enum :status, { pending: "pending", confirmed: "confirmed", withdrawn: "withdrawn" }

  validates :competitor_id, uniqueness: { scope: :division_id }
  validates :seed, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
