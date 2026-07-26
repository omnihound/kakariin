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
  # naturally fall after scheduled ones here. Stays within the division the
  # court is currently working through (or most recently finished) as long
  # as that division still has pending matches queued here, only crossing
  # into another division once it's exhausted on this court.
  def next_match
    matches.pending.where(division_id: sticky_division_id).order(:scheduled_at, :round, :id).first ||
      matches.pending.order(:scheduled_at, :round, :id).first
  end

  private

  def sticky_division_id
    current_match&.division_id ||
      matches.where(status: [ "completed", "bye" ]).order(updated_at: :desc).first&.division_id
  end
end
