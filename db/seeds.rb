# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
Venue.find_or_create_by!(name: "Конференц-зал") do |venue|
  venue.address = "Москва, ул. Центральная, 10"
  venue.capacity = 100
end

Venue.find_or_create_by!(name: "Переговорная") do |venue|
  venue.address = "Нижний Новгород, ул. Техническая, 15"
  venue.capacity = 20
end

Venue.find_or_create_by!(name: "Зал для семинаров") do |venue|
  venue.address = "Нижний Новгород, ул. Техническая, 15"
  venue.capacity = 50
end