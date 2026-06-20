class Competitor < ApplicationRecord
  belongs_to :user, optional: true

  has_many :tournament_registrations, dependent: :destroy
  has_many :pool_registrations, dependent: :destroy
  has_many :pools, through: :pool_registrations
  has_many :divisions, through: :tournament_registrations
  has_many :team_memberships, dependent: :destroy
  has_many :team_entries, through: :team_memberships
  has_many :ippons, dependent: :destroy

  GRADE_TYPES = %w[kyu dan].freeze

  validates :first_name, :last_name, presence: true
  validates :country, presence: true
  validates :gender, inclusion: { in: %w[male female other] }, allow_nil: true
  validates :grade_type, inclusion: { in: GRADE_TYPES }, allow_nil: true
  validates :grade_rank, presence: true, if: -> { grade_type.present? }
  validates :grade_type, presence: true, if: -> { grade_rank.present? }

  def full_name = "#{first_name} #{last_name}"

  # e.g. "3dan", "1kyu", nil for ungraded
  def grade_label
    return nil unless grade_type? && grade_rank?
    "#{grade_rank}#{grade_type}"
  end

  private

  def grade_type? = grade_type.present?
  def grade_rank? = grade_rank.present?
end
