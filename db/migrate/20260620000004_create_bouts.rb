class CreateBouts < ActiveRecord::Migration[8.1]
  def change
    # An individual taisen (bout) within a team match — e.g. senpo, chuken,
    # taisho. The parent Match's winner/score are derived from these.
    create_table :bouts do |t|
      t.references :match, null: false, foreign_key: true

      t.integer :position, null: false  # 0-indexed: senpo=0, chuken=1, taisho=2 for a 3-position lineup, etc.

      t.references :home_competitor, null: false, foreign_key: { to_table: :competitors }
      t.references :away_competitor, null: true, foreign_key: { to_table: :competitors }  # nil = forfeit/no-show
      t.references :winner, null: true, foreign_key: { to_table: :competitors }  # nil = pending or hikiwake (draw)

      t.integer :home_score, null: false, default: 0
      t.integer :away_score, null: false, default: 0
      # "pending" | "in_progress" | "completed"
      t.string  :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :bouts, [ :match_id, :position ], unique: true
  end
end
