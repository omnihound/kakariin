class CreateMatchIppons < ActiveRecord::Migration[8.1]
  def change
    create_table :match_ippons do |t|
      t.references :match,      null: false, foreign_key: true
      t.references :competitor, null: false, foreign_key: true  # who scored (or conceded hansoku)

      # "men" | "kote" | "do" | "tsuki" | "hansoku"
      t.string  :technique, null: false
      # Seconds elapsed in the match when the point was awarded
      t.integer :elapsed_seconds

      t.timestamps
    end

    add_index :match_ippons, [ :match_id, :competitor_id ]
  end
end
