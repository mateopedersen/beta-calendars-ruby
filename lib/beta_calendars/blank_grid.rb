# frozen_string_literal: true

module BetaCalendars
  # A position in a date-free planning grid.
  class BlankCell
    include Serializable

    attr_reader :row, :column, :weekday

    def initialize(row:, column:, weekday:)
      @row = row
      @column = column
      @weekday = weekday
      freeze
    end

    def to_h
      { row: row, column: column, weekday: weekday }
    end
  end

  # A blank rows-by-seven structure ready for a planner or printable renderer.
  class BlankGrid
    include Serializable

    attr_reader :rows, :week_start, :weekdays, :weeks

    def initialize(rows:, week_start:)
      unless rows.is_a?(Integer) && rows.between?(1, 60)
        raise InvalidGridSizeError, "rows must be an integer from 1 to 60"
      end

      @rows = rows
      @week_start = CalendarValidation.normalize_week_start(week_start)
      @weekdays = Month::WEEKDAY_NAMES.rotate(week_start == :sunday ? 0 : 1).freeze
      @weeks = rows.times.map do |row|
        7.times.map do |column|
          BlankCell.new(row: row, column: column, weekday: weekdays[column])
        end.freeze
      end.freeze
      freeze
    end

    alias grid weeks

    def to_h
      {
        rows: rows,
        columns: 7,
        week_start: week_start,
        weekdays: weekdays,
        weeks: weeks.map { |week| week.map(&:to_h).freeze }.freeze
      }
    end
  end
end
