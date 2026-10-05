# frozen_string_literal: true

require_relative "test_helper"

class MonthTest < Minitest::Test
  def test_january_2027_monday_grid_has_correct_dates_and_dimensions
    month = BetaCalendars.month(year: 2027, month: 1, week_start: :monday)
    assert_equal "January", month.month_name
    assert_equal 31, month.days.length
    assert_equal 5, month.weeks.length
    assert_equal 7, month.weeks.first.length
    assert_equal %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday], month.weekdays
    assert_equal Date.new(2027, 1, 1), month.days.first.date
    assert_equal 5, month.days.first.iso_weekday
    assert_equal 2026, month.weeks.first.first.year
    assert_equal 12, month.weeks.first.first.month
    assert_equal 28, month.weeks.first.first.day
    assert_equal false, month.weeks.first.first.in_current_month
    assert_equal false, month.weeks.first.first.weekend
  end

  def test_sunday_grid_and_adjacent_month_cells
    month = BetaCalendars.month(year: 2027, month: 1, week_start: :sunday)
    assert_equal "Sunday", month.weekdays.first
    assert_equal Date.new(2026, 12, 27), month.weeks.first.first.date
    assert_equal Date.new(2027, 1, 2), month.weeks.first.last.date
    assert_equal 6, month.weeks.length
    assert_equal true, month.weeks.first.last.weekend
    assert_equal true, month.weeks.first.first.weekend
  end

  def test_adjacent_dates_can_be_nil
    month = BetaCalendars.month(year: 2027, month: 1, week_start: :monday, adjacent_dates: false)
    assert_nil month.weeks.first.first
    assert_nil month.weeks.first[3]
    assert_equal 1, month.weeks.first[4].day
    assert_equal 31, month.weeks.last[6].day
    refute month.weeks.last.any?(&:nil?)
    assert_equal 31, month.days.length
  end

  def test_fixed_six_week_print_grid
    month = BetaCalendars.month(year: 2027, month: 2, week_start: :monday, fixed_six_weeks: true)
    assert_equal 6, month.weeks.length
    assert month.weeks.all? { |week| week.length == 7 }
    assert_equal true, month.fixed_six_weeks
    assert_equal 28, month.days_in_month
  end

  def test_february_2024_is_a_leap_month
    month = BetaCalendars.month(year: 2024, month: 2)
    assert_equal 29, month.days_in_month
    assert_equal 29, month.days.length
    assert_equal 29, month.days.last.day
  end

  def test_cells_carry_iso_week_year_metadata_at_year_boundary
    month = BetaCalendars.month(year: 2021, month: 1, week_start: :monday)
    jan_first = month.days.first
    assert_equal 53, jan_first.iso_week
    assert_equal 2020, jan_first.iso_week_year
    assert_equal 5, jan_first.iso_weekday
    refute jan_first.weekend
    assert jan_first.frozen?
    assert_raises(NoMethodError) { jan_first.day = 2 }
    assert_raises(FrozenError) { month.weeks[0] << nil }
  end

  def test_month_matrix_returns_metadata_cells
    matrix = BetaCalendars.month_matrix(year: 2027, month: 1, week_start: :monday, adjacent_dates: false)
    assert_equal 5, matrix.length
    assert_nil matrix.first.first
    assert_instance_of BetaCalendars::DayCell, matrix.first[4]
    assert_equal "2027-01-01", matrix.first[4].to_h.fetch(:date)
  end

  def test_month_arguments_are_validated
    assert_raises(BetaCalendars::InvalidCalendarDateError) { BetaCalendars.month(year: 0, month: 1) }
    assert_raises(BetaCalendars::InvalidCalendarDateError) { BetaCalendars.month(year: 2027, month: 13) }
    error = assert_raises(BetaCalendars::InvalidWeekStartError) do
      BetaCalendars.month(year: 2027, month: 1, week_start: :tuesday)
    end
    assert_match(/monday or :sunday/, error.message)
  end
end
