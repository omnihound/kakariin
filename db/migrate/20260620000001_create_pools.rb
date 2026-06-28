class CreatePools < ActiveRecord::Migration[8.1]
  def change
    create_table :pools do |t|
      t.references :division, null: false, foreign_key: true

      t.string  :name,             null: false  # "Pool A", "Pool B", etc.
      t.integer :advancing_count,  null: false, default: 1  # qualifiers per pool
      # "pending" | "in_progress" | "completed"
      t.string  :status,           null: false, default: "pending"

      t.timestamps
    end

    add_index :pools, [ :division_id, :name ], unique: true
  end
end
