module VenuesHelper
  def favorite_venue?(venue)
    return false unless logged_in?

    @favorite_venue_ids ||= current_user.favorites.pluck(:venue_id).to_set
    @favorite_venue_ids.include?(venue.id)
  end

  def venue_photo(venue)
    case venue.name.to_s.downcase
    when /конференц/ then "venue-conference.jpg"
    when /переговор/ then "venue-meeting.jpg"
    when /семинар|лекторий|аудитория|мастерская/ then "venue-seminar.jpg"
    else "hero-background.jpg"
    end
  end

  def venue_capacity(venue)
    venue.capacity ? "До #{venue.capacity} чел." : "Вместимость не указана"
  end

  def venue_hourly_rate(venue)
    return "Уточняется" unless venue.hourly_rate

    number_to_currency(venue.hourly_rate, unit: "₽", format: "%n %u/час", separator: ",", delimiter: " ")
  end

  def venue_time_interval(date, start_at, end_at)
    end_label = end_at.to_date > date ? "24:00" : end_at.strftime("%H:%M")
    "#{start_at.strftime('%H:%M')}–#{end_label}"
  end
end
