# frozen_string_literal: true

require_relative "test_helper"
require "open3"
require "rbconfig"

class CLITest < Minitest::Test
  EXE = File.expand_path("../exe/beta-calendars", __dir__)
  LIB = File.expand_path("../lib", __dir__)

  def run_cli(*arguments)
    Open3.capture3(RbConfig.ruby, "-I", LIB, EXE, *arguments)
  end

  def test_month_command_formats_readable_calendar
    stdout, stderr, status = run_cli("month", "2027", "1", "--week-start", "monday")
    assert status.success?, stderr
    assert_match(/January 2027/, stdout)
    assert_match(/Mo Tu We Th Fr Sa Su/, stdout)
    assert_match(/ 1  2  3/, stdout)
    assert_empty stderr
  end

  def test_month_json_command
    stdout, stderr, status = run_cli("month", "2027", "1", "--week-start", "monday", "--json")
    assert status.success?, stderr
    data = JSON.parse(stdout)
    assert_equal "January", data.fetch("month_name")
    assert_equal "monday", data.fetch("week_start")
    assert_equal 31, data.fetch("weeks").flatten.compact.count { |cell| cell.fetch("in_current_month") }
  end

  def test_year_blank_and_info_commands
    year_stdout, year_stderr, year_status = run_cli("year", "2027", "--json")
    assert year_status.success?, year_stderr
    assert_equal 12, JSON.parse(year_stdout).fetch("months").length

    blank_stdout, blank_stderr, blank_status = run_cli("blank", "--rows", "2", "--week-start", "monday")
    assert blank_status.success?, blank_stderr
    assert_match(/Mo Tu We Th Fr Sa Su/, blank_stdout)
    assert_equal 3, blank_stdout.lines.length

    info_stdout, info_stderr, info_status = run_cli("info", "2024", "--json")
    assert info_status.success?, info_stderr
    assert_equal true, JSON.parse(info_stdout).fetch("leap_year")
  end

  def test_invalid_input_returns_nonzero_and_explanation
    stdout, stderr, status = run_cli("month", "2027", "1", "--week-start", "friday")
    refute status.success?
    assert_empty stdout
    assert_match(/week_start must be :monday or :sunday/, stderr)
  end

  def test_help_command
    stdout, stderr, status = run_cli("help")
    assert status.success?, stderr
    assert_match(/Commands:/, stdout)
    assert_match(/blank/, stdout)
  end
end
