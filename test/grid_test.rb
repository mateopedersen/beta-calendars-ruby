# frozen_string_literal: true

require_relative "test_helper"

class GridTest < Minitest::Test
  def test_blank_six_row_sunday_grid
    grid = BetaCalendars.blank_grid(rows: 6, week_start: :sunday)
    assert_equal 6, grid.weeks.length
    assert grid.weeks.all? { |week| week.length == 7 }
    assert_equal "Sunday", grid.weekdays.first
    assert_equal "Saturday", grid.weekdays.last
    assert_equal 42, grid.weeks.flatten.length
    assert_equal "Sunday", grid.weeks.first.first.weekday
    assert_equal 0, grid.weeks.first.first.row
    assert_equal 6, grid.weeks.last.last.column
  end

  def test_blank_monday_grid_and_json
    grid = BetaCalendars.blank_grid(rows: 2, week_start: :monday)
    assert_equal "Monday", grid.weekdays.first
    assert_equal "Sunday", grid.weekdays.last
    assert_equal 2, grid.to_h.fetch(:weeks).length
    parsed = JSON.parse(grid.to_json)
    assert_equal 2, parsed.fetch("rows")
    assert_equal 7, parsed.fetch("columns")
    assert_equal "Monday", parsed.fetch("weeks").first.first.fetch("weekday")
  end

  def test_blank_grid_validates_dimensions_and_week_start
    assert_raises(BetaCalendars::InvalidGridSizeError) { BetaCalendars.blank_grid(rows: 0) }
    assert_raises(BetaCalendars::InvalidGridSizeError) { BetaCalendars.blank_grid(rows: 61) }
    assert_raises(BetaCalendars::InvalidGridSizeError) { BetaCalendars.blank_grid(rows: 2.5) }
    assert_raises(BetaCalendars::InvalidWeekStartError) { BetaCalendars.blank_grid(week_start: :friday) }
  end
end
