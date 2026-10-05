# frozen_string_literal: true

module BetaCalendars
  # Twelve month value objects for one Gregorian calendar year.
  class Year
    include Serializable

    attr_reader :year, :week_start, :adjacent_dates, :fixed_six_weeks, :months

    def initialize(year:, week_start:, adjacent_dates:, fixed_six_weeks:)
      CalendarValidation.validate_year!(year)
      @year = year
      @week_start = CalendarValidation.normalize_week_start(week_start)
      @adjacent_dates = !!adjacent_dates
      @fixed_six_weeks = !!fixed_six_weeks
      @months = (1..12).map do |month_number|
        Month.new(
          year: year,
          month: month_number,
          week_start: @week_start,
          adjacent_dates: @adjacent_dates,
          fixed_six_weeks: @fixed_six_weeks
        )
      end.freeze
      freeze
    end

    # Month numbers are one-based: year[1] is January and year[12] is December.
    def [](month_number)
      unless month_number.is_a?(Integer) && month_number.between?(1, 12)
        raise IndexError, "month number must be between 1 and 12"
      end

      months.fetch(month_number - 1)
    end

    def to_h
      {
        year: year,
        week_start: week_start,
        adjacent_dates: adjacent_dates,
        fixed_six_weeks: fixed_six_weeks,
        months: months.map(&:to_h).freeze
      }
    end
  end
end
