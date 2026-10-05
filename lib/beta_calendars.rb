# frozen_string_literal: true

require "date"
require "json"

require_relative "beta_calendars/version"
require_relative "beta_calendars/errors"
require_relative "beta_calendars/serializable"

module BetaCalendars
  module CalendarValidation
    module_function

    def validate_year!(year)
      unless year.is_a?(Integer) && year.between?(1, 9999)
        raise InvalidCalendarDateError, "year must be an integer from 1 to 9999"
      end
    end

    def validate_month!(month)
      unless month.is_a?(Integer) && month.between?(1, 12)
        raise InvalidCalendarDateError, "month must be an integer from 1 to 12"
      end
    end

    def normalize_week_start(value)
      normalized = value.respond_to?(:to_sym) ? value.to_sym : value
      return normalized if %i[monday sunday].include?(normalized)

      raise InvalidWeekStartError, value
    end
  end
end

require_relative "beta_calendars/day_cell"
require_relative "beta_calendars/month"
require_relative "beta_calendars/year"
require_relative "beta_calendars/blank_grid"
require_relative "beta_calendars/iso_week"
require_relative "beta_calendars/cli"

module BetaCalendars
  class << self
    # Build a local Gregorian month grid. Out-of-month cells contain adjacent
    # dates by default; pass adjacent_dates: false to use nil cells instead.
    # @param year [Integer] Gregorian year from 1 through 9999
    # @param month [Integer] month number from 1 through 12
    # @param week_start [Symbol, String] :monday or :sunday
    # @param adjacent_dates [Boolean] populate cells from neighboring months
    # @param fixed_six_weeks [Boolean] always create six rows
    # @return [BetaCalendars::Month]
    def month(year:, month:, week_start: :sunday, adjacent_dates: true, fixed_six_weeks: false)
      Month.new(
        year: year,
        month: month,
        week_start: week_start,
        adjacent_dates: adjacent_dates,
        fixed_six_weeks: fixed_six_weeks
      )
    end

    # Build twelve monthly calendars for the selected Gregorian year.
    # @param year [Integer] Gregorian year from 1 through 9999
    # @param week_start [Symbol, String] :monday or :sunday
    # @param adjacent_dates [Boolean] populate cells from neighboring months
    # @param fixed_six_weeks [Boolean] always create six rows per month
    # @return [BetaCalendars::Year]
    def year(year:, week_start: :sunday, adjacent_dates: true, fixed_six_weeks: false)
      Year.new(
        year: year,
        week_start: week_start,
        adjacent_dates: adjacent_dates,
        fixed_six_weeks: fixed_six_weeks
      )
    end

    # Build an empty printable planning grid with seven weekday columns.
    # @param rows [Integer] row count from 1 through 60
    # @param week_start [Symbol, String] :monday or :sunday
    # @return [BetaCalendars::BlankGrid]
    def blank_grid(rows: 6, week_start: :sunday)
      BlankGrid.new(rows: rows, week_start: week_start)
    end

    # Return whether a Gregorian year has 366 days.
    # @param year [Integer] Gregorian year from 1 through 9999
    # @return [Boolean]
    def leap_year?(year)
      CalendarValidation.validate_year!(year)
      (year % 400).zero? || ((year % 4).zero? && !(year % 100).zero?)
    end

    # Return the number of days in a Gregorian month.
    # @param year [Integer] Gregorian year from 1 through 9999
    # @param month [Integer] month number from 1 through 12
    # @return [Integer]
    def days_in_month(year, month)
      CalendarValidation.validate_year!(year)
      CalendarValidation.validate_month!(month)
      Date.new(year, month, -1, Date::GREGORIAN).day
    end

    # Return the ISO week and ISO week-year for a Date, or for year/month/day.
    # @param date_or_year [Date, Integer] a Date or Gregorian year
    # @param month [Integer, nil] month number when a year is supplied
    # @param day [Integer, nil] day of month when a year is supplied
    # @return [BetaCalendars::ISOWeek]
    def iso_week(date_or_year, month = nil, day = nil)
      date = if date_or_year.is_a?(Date) && month.nil? && day.nil?
               date_or_year
             elsif date_or_year.is_a?(Integer) && month.is_a?(Integer) && day.is_a?(Integer)
               CalendarValidation.validate_year!(date_or_year)
               CalendarValidation.validate_month!(month)
               unless Date.valid_date?(date_or_year, month, day, Date::GREGORIAN)
                 raise InvalidCalendarDateError, "day must be valid for the selected year and month"
               end
               Date.new(date_or_year, month, day, Date::GREGORIAN)
             else
               raise ArgumentError, "provide a Date or integer year, month, and day"
             end
      ISOWeek.new(week: date.cweek, year: date.cwyear)
    end

    # Return the same metadata-rich two-dimensional grid exposed by Month#weeks.
    # @return [Array<Array<BetaCalendars::DayCell, nil>>]
    def month_matrix(year:, month:, week_start: :sunday, adjacent_dates: true, fixed_six_weeks: false)
      self.month(
        year: year,
        month: month,
        week_start: week_start,
        adjacent_dates: adjacent_dates,
        fixed_six_weeks: fixed_six_weeks
      ).weeks
    end
  end
end
