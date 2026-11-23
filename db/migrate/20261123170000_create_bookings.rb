class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :venue, null: false, foreign_key: true
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_check_constraint :bookings, "end_at > start_at", name: "bookings_time_order"
    add_check_constraint :bookings, "status IN (0, 1, 2, 3)", name: "bookings_valid_status"
    add_reference :reviews, :booking, foreign_key: true, index: { unique: true }
  end
end
