class PoolRegistration < ApplicationRecord
  belongs_to :pool
  belongs_to :competitor

  validates :competitor_id, uniqueness: { scope: :pool_id }
  validates :seed, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end