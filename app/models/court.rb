class Court < ApplicationRecord
  belongs_to :tournament

  has_many :matches, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :tournament_id }

  # The match currently being played on this court, if any.
  def current_match
    matches.in_progress.order(:scheduled_at, :id).first
  end

  # The next match queued for this court once the current one finishes.
  # Postgres sorts NULLs last on an ascending order, so unscheduled matches
  # naturally fall after scheduled ones here.
  def next_match
    matches.pending.order(:scheduled_at, :round, :id).first
  end
end
