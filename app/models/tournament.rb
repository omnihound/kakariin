class Tournament < ApplicationRecord
  has_many :divisions, dependent: :destroy

  STATUSES = %w[draft registration_open in_progress completed cancelled].freeze

  enum :status, {
    draft: "draft",
    registration_open: "registration_open",
    in_progress: "in_progress",
    completed: "completed",
    cancelled: "cancelled"
  }

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, comparison: { greater_than_or_equal_to: :start_date }, allow_nil: true
end
