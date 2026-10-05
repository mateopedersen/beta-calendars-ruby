# frozen_string_literal: true

module BetaCalendars
  # Calendar grid and date metadata for one Gregorian month.
  class Month
    include Serializable

    WEEKDAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze

    attr_reader :year, :month, :week_start, :adjacent_dates, :fixed_six_weeks,
                :days_in_month, :weeks, :weekdays

    def initialize(year:, month:, week_start:, adjacent_dates:, fixed_six_weeks:)
      CalendarValidation.validate_year!(year)
      CalendarValidation.validate_month!(month)
      @year = year
      @month = month
      @week_start = CalendarValidation.normalize_week_start(week_start)
      @adjacent_dates = !!adjacent_dates
      @fixed_six_weeks = !!fixed_six_weeks
      @days_in_month = Date.new(year, month, -1, Date::GREGORIAN).day
      @weekdays = ordered_weekday_names.freeze
      @weeks = build_weeks.freeze
      freeze
    end

    def month_name
      Date::MONTHNAMES.fetch(month)
    end

    # Returns one immutable cell for each day in this month, excluding adjacent dates.
    def days
      (1..days_in_month).map do |day|
        DayCell.new(date: Date.new(year, month, day, Date::GREGORIAN), current_year: year, current_month: month)
      end.freeze
    end

    alias matrix weeks

    def to_h
      {
        year: year,
        month: month,
        month_name: month_name,
        week_start: week_start,
        adjacent_dates: adjacent_dates,
        fixed_six_weeks: fixed_six_weeks,
        weekdays: weekdays,
        weeks: weeks.map { |week| week.map { |cell| cell&.to_h }.freeze }.freeze
      }
    end

    private

    def ordered_weekday_names
      start = (week_start == :sunday ? 0 : 1)
      7.times.map { |offset| WEEKDAY_NAMES[(start + offset) % 7] }
    end

    def build_weeks
      first_date = Date.new(year, month, 1, Date::GREGORIAN)
      start_weekday = week_start == :sunday ? 0 : 1
      leading = (first_date.wday - start_weekday) % 7
      row_count = fixed_six_weeks ? 6 : ((leading + days_in_month + 6) / 7)
      grid_start = first_date - leading

      row_count.times.map do |row|
        7.times.map do |column|
          date = grid_start + (row * 7) + column
          if adjacent_dates || (date.year == year && date.month == month)
            DayCell.new(date: date, current_year: year, current_month: month)
          end
        end.freeze
      end
    end
  end
end
