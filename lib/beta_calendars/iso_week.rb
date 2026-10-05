# frozen_string_literal: true

module BetaCalendars
  # ISO-8601 week number and the week-based year that owns it.
  class ISOWeek
    include Serializable

    attr_reader :week, :year
    alias iso_year year

    def initialize(week:, year:)
      @week = week
      @year = year
      freeze
    end

    def to_h
      { week: week, year: year }
    end
  end
end
