# frozen_string_literal: true

require_relative "test_helper"

class ISOWeekTest < Minitest::Test
  def test_iso_week_year_boundary
    result = BetaCalendars.iso_week(Date.new(2021, 1, 1))
    assert_equal 53, result.week
    assert_equal 2020, result.year
    assert_equal 2020, result.iso_year
    assert_equal({ week: 53, year: 2020 }, result.to_h)
    assert_equal({ "week" => 53, "year" => 2020 }, JSON.parse(result.to_json))
  end

  def test_iso_week_for_date_components
    result = BetaCalendars.iso_week(2027, 1, 4)
    assert_equal 1, result.week
    assert_equal 2027, result.year
    assert_raises(ArgumentError) { BetaCalendars.iso_week("2027-01-04") }
    assert_raises(BetaCalendars::InvalidCalendarDateError) { BetaCalendars.iso_week(2027, 2, 30) }
    assert_raises(BetaCalendars::InvalidCalendarDateError) { BetaCalendars.iso_week(2027, 13, 1) }
  end
end
