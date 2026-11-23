class ConvertAvailabilityBlocksToTimeIntervals < ActiveRecord::Migration[8.1]
  def up
    add_column :availability_blocks, :start_at, :datetime
    add_column :availability_blocks, :end_at, :datetime

    # Старые даты закрывали сутки целиком, включая дату окончания.
    execute <<~SQL
      UPDATE availability_blocks
      SET start_at = starts_on::timestamp AT TIME ZONE 'Europe/Moscow' AT TIME ZONE 'UTC',
          end_at = (ends_on + 1)::timestamp AT TIME ZONE 'Europe/Moscow' AT TIME ZONE 'UTC'
    SQL

    change_column_null :availability_blocks, :start_at, false
    change_column_null :availability_blocks, :end_at, false
    add_check_constraint :availability_blocks, "end_at > start_at", name: "availability_blocks_time_order"
    remove_check_constraint :availability_blocks, name: "availability_blocks_date_order"
    remove_columns :availability_blocks, :starts_on, :ends_on
  end

  def down
    add_column :availability_blocks, :starts_on, :date
    add_column :availability_blocks, :ends_on, :date

    execute <<~SQL
      UPDATE availability_blocks
      SET starts_on = (start_at AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Moscow')::date,
          ends_on = ((end_at - interval '1 microsecond') AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Moscow')::date
    SQL

    change_column_null :availability_blocks, :starts_on, false
    change_column_null :availability_blocks, :ends_on, false
    add_check_constraint :availability_blocks, "ends_on >= starts_on", name: "availability_blocks_date_order"
    remove_check_constraint :availability_blocks, name: "availability_blocks_time_order"
    remove_columns :availability_blocks, :start_at, :end_at
  end
end
