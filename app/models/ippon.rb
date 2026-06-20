class Ippon < ApplicationRecord
  # scoreable is a Match (individual division) or a Bout (within a team match)
  belongs_to :scoreable, polymorphic: true
  belongs_to :competitor

  # "dou" is used instead of "do" (Ruby reserved word); stored as "dou" in the DB
  enum :technique, { men: "men", kote: "kote", dou: "dou", tsuki: "tsuki", hansoku: "hansoku" }

  validates :elapsed_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :competitor_is_a_participant

  private

  def competitor_is_a_participant
    return unless scoreable && competitor

    participants =
      if scoreable.is_a?(Match)
        [ scoreable.home, scoreable.away ].select { |p| p.is_a?(Competitor) }
      else # Bout
        [ scoreable.home_competitor, scoreable.away_competitor ]
      end

    errors.add(:competitor, "must be a participant in this match") unless participants.include?(competitor)
  end
end