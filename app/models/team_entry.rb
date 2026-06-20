class TeamEntry < ApplicationRecord
  belongs_to :division

  has_many :team_memberships, dependent: :destroy
  has_many :competitors, through: :team_memberships

  enum :status, { pending: "pending", confirmed: "confirmed", withdrawn: "withdrawn" }

  validates :name, presence: true, uniqueness: { scope: :division_id }
  validates :seed, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end