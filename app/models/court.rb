class Court < ApplicationRecord
  belongs_to :tournament

  has_many :matches, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :tournament_id }
end
