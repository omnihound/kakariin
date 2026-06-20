class CreateTournaments < ActiveRecord::Migration[8.1]
  def change
    create_table :tournaments do |t|
      t.string   :name,       null: false
      t.string   :location
      t.text     :description
      t.date     :start_date, null: false
      t.date     :end_date
      # "draft" | "registration_open" | "in_progress" | "completed" | "cancelled"
      t.string   :status,     null: false, default: "draft"

      t.timestamps
    end

    add_index :tournaments, :start_date
    add_index :tournaments, :status
  end
end