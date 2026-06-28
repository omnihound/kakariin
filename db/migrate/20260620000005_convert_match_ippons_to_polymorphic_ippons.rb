class ConvertMatchIpponsToPolymorphicIppons < ActiveRecord::Migration[8.1]
  def up
    remove_foreign_key :match_ippons, :matches
    rename_table :match_ippons, :ippons
    rename_column :ippons, :match_id, :scoreable_id
    add_column :ippons, :scoreable_type, :string
    execute "UPDATE ippons SET scoreable_type = 'Match'"
    change_column_null :ippons, :scoreable_type, false
    add_index :ippons, [ :scoreable_type, :scoreable_id ]
  end

  def down
    remove_index :ippons, [ :scoreable_type, :scoreable_id ]
    remove_column :ippons, :scoreable_type
    rename_column :ippons, :scoreable_id, :match_id
    rename_table :ippons, :match_ippons
    add_foreign_key :match_ippons, :matches
  end
end
