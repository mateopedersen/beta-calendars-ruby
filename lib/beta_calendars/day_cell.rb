# frozen_string_literal: true

module BetaCalendars
  # Immutable metadata for one real Gregorian date in a month grid.
  class DayCell
    include Serializable

    attr_reader :date, :day, :year, :month, :weekday, :iso_weekday,
                :iso_week, :iso_week_year, :in_current_month, :weekend

    def initialize(date:, current_year:, current_month:)
      @date = date
      @day = date.day
      @year = date.year
      @month = date.month
      @weekday = date.wday # Sunday = 0, matching Ruby Date#wday.
      @iso_weekday = date.cwday # Monday = 1 through Sunday = 7.
      @iso_week = date.cweek
      @iso_week_year = date.cwyear
      @in_current_month = (date.year == current_year && date.month == current_month)
      @weekend = (date.wday == 0 || date.wday == 6)
      freeze
    end

    def to_h
      {
        date: date.iso8601,
        day: day,
        year: year,
        month: month,
        weekday: weekday,
        iso_weekday: iso_weekday,
        iso_week: iso_week,
        iso_week_year: iso_week_year,
        in_current_month: in_current_month,
        weekend: weekend
      }
    end
  end
end
