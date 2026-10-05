# frozen_string_literal: true

require_relative "test_helper"

class SerializationTest < Minitest::Test
  def test_month_hash_has_json_safe_date_metadata
    month = BetaCalendars.month(year: 2027, month: 1, week_start: :monday)
    data = month.to_h
    assert_equal "2027-01-01", data.fetch(:weeks).first[4].fetch(:date)
    assert_equal true, data.fetch(:weeks).first[4].fetch(:in_current_month)
    assert_equal 53, data.fetch(:weeks).first[4].fetch(:iso_week)
    assert_equal 2026, data.fetch(:weeks).first[4].fetch(:iso_week_year)
    parsed = JSON.parse(month.to_json)
    assert_equal "2027-01-01", parsed.fetch("weeks").first[4].fetch("date")
    assert_equal 2026, parsed.fetch("weeks").first[4].fetch("iso_week_year")
  end

  def test_json_serialization_is_repeatable
    month = BetaCalendars.month(year: 2027, month: 1)
    assert_equal month.to_json, month.to_json
    assert_equal "January", JSON.parse(month.to_json).fetch("month_name")
    assert_equal 7, JSON.parse(month.to_json).fetch("weekdays").length
  end
end
