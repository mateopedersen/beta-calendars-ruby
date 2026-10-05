# frozen_string_literal: true

module BetaCalendars
  class Error < StandardError; end

  class InvalidWeekStartError < ArgumentError
    def initialize(value)
      super("week_start must be :monday or :sunday (got #{value.inspect})")
    end
  end

  class InvalidCalendarDateError < ArgumentError; end
  class InvalidGridSizeError < ArgumentError; end
end
