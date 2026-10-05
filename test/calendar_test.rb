# frozen_string_literal: true

require_relative "test_helper"

class CalendarTest < Minitest::Test
  def test_gregorian_leap_year_rules
    assert BetaCalendars.leap_year?(2024)
    assert BetaCalendars.leap_year?(2000)
    refute BetaCalendars.leap_year?(1900)
    refute BetaCalendars.leap_year?(2027)
    assert_raises(BetaCalendars::InvalidCalendarDateError) { BetaCalendars.leap_year?(0) }
  end

  def test_month_lengths
    assert_equal 29, BetaCalendars.days_in_month(2024, 2)
    assert_equal 28, BetaCalendars.days_in_month(2027, 2)
    assert_equal 31, BetaCalendars.days_in_month(2027, 1)
    assert_equal 30, BetaCalendars.days_in_month(2027, 4)
    assert_equal 29, BetaCalendars.days_in_month(2000, 2)
    assert_equal 28, BetaCalendars.days_in_month(1900, 2)
  end

  def test_december_to_january_transition_is_deterministic
    december = BetaCalendars.month(year: 2026, month: 12, week_start: :monday)
    january = BetaCalendars.month(year: 2027, month: 1, week_start: :monday)
    assert_equal Date.new(2026, 12, 31), december.days.last.date
    assert_equal Date.new(2027, 1, 1), january.days.first.date
    assert_equal Date.new(2027, 1, 3), december.weeks.last.last.date
    assert_equal Date.new(2026, 12, 28), january.weeks.first.first.date
  end

  def test_dates_use_proleptic_gregorian_arithmetic
    october = BetaCalendars.month(year: 1582, month: 10, week_start: :monday)
    assert_equal 31, october.days_in_month
    assert_equal Date::GREGORIAN, october.days.first.date.start
    assert_equal Date.new(1582, 10, 15, Date::GREGORIAN) - 1,
                 Date.new(1582, 10, 14, Date::GREGORIAN)
  end
end
