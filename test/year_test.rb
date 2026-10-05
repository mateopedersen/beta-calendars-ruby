# frozen_string_literal: true

require_relative "test_helper"

class YearTest < Minitest::Test
  def test_year_contains_twelve_one_based_months
    year = BetaCalendars.year(year: 2027, week_start: :monday)
    assert_equal 2027, year.year
    assert_equal 12, year.months.length
    assert_equal 1, year[1].month
    assert_equal 12, year[12].month
    assert_equal "January", year[1].month_name
    assert_equal "December", year[12].month_name
    assert_equal :monday, year[6].week_start
    assert year.months.frozen?
  end

  def test_year_applies_grid_options_to_each_month
    year = BetaCalendars.year(year: 2024, week_start: :sunday, fixed_six_weeks: true, adjacent_dates: false)
    assert_equal true, year[2].fixed_six_weeks
    assert_equal false, year[2].adjacent_dates
    assert_equal 6, year[2].weeks.length
    assert_equal "Sunday", year[1].weekdays.first
  end

  def test_year_serializes_all_months
    year_hash = BetaCalendars.year(year: 2027).to_h
    assert_equal 2027, year_hash.fetch(:year)
    assert_equal 12, year_hash.fetch(:months).length
    assert_equal "January", year_hash.fetch(:months).first.fetch(:month_name)
    assert_equal "December", year_hash.fetch(:months).last.fetch(:month_name)
  end

  def test_year_rejects_invalid_lookup_and_year
    year = BetaCalendars.year(year: 2027)
    assert_raises(IndexError) { year[0] }
    assert_raises(IndexError) { year[13] }
    assert_raises(BetaCalendars::InvalidCalendarDateError) { BetaCalendars.year(year: 10_000) }
  end
end
