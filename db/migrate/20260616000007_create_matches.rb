class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.references :division, null: false, foreign_key: true

      t.integer :round, null: false

      # Polymorphic participants — Competitor for individual divisions,
      # TeamEntry for team divisions. away is null for byes.
      t.string  :home_type, null: false
      t.bigint  :home_id,   null: false
      t.string  :away_type
      t.bigint  :away_id

      # Set once the match is complete
      t.string  :winner_type
      t.bigint  :winner_id

      # Cached ippon totals — derived from match_ippons but stored for fast querying
      t.integer :home_score, null: false, default: 0
      t.integer :away_score, null: false, default: 0

      # "pending" | "in_progress" | "completed" | "bye"
      t.string  :status, null: false, default: "pending"

      t.integer  :mat_number
      t.datetime :scheduled_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :matches, [ :home_type, :home_id ]
    add_index :matches, [ :away_type, :away_id ]
    add_index :matches, [ :winner_type, :winner_id ]
    add_index :matches, [ :division_id, :round ]
  end
end
