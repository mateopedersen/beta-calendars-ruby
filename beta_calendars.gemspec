# frozen_string_literal: true

require_relative "lib/beta_calendars/version"

Gem::Specification.new do |spec|
  spec.name = "beta_calendars"
  spec.version = BetaCalendars::VERSION
  spec.authors = ["Mateo Pedersen"]
  spec.email = []

  spec.summary = "Deterministic Ruby calendar grids for monthly, yearly and printable calendar applications."
  spec.description = <<~DESCRIPTION
    Beta Calendars Ruby generates Gregorian month and year calendar structures,
    including configurable Sunday or Monday week starts, adjacent-month cells,
    ISO week metadata, fixed six-week print grids, blank planning grids, JSON
    serialization, and a small command-line interface. All calculations run
    locally using Ruby's standard Date library.
  DESCRIPTION
  spec.homepage = "https://www.betacalendars.com/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/mateopedersen/beta-calendars-ruby",
    "documentation_uri" => "https://github.com/mateopedersen/beta-calendars-ruby#readme",
    "changelog_uri" => "https://github.com/mateopedersen/beta-calendars-ruby/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/mateopedersen/beta-calendars-ruby/issues",
    "rubygems_mfa_required" => "true"
  }

  # An explicit allowlist keeps local credentials, build products, and unrelated
  # project files out of the published gem.
  spec.files = %w[
    CHANGELOG.md
    CODE_OF_CONDUCT.md
    CONTRIBUTING.md
    LICENSE.txt
    README.md
    Rakefile
    beta_calendars.gemspec
    exe/beta-calendars
    lib/beta_calendars.rb
    lib/beta_calendars/blank_grid.rb
    lib/beta_calendars/cli.rb
    lib/beta_calendars/day_cell.rb
    lib/beta_calendars/errors.rb
    lib/beta_calendars/iso_week.rb
    lib/beta_calendars/month.rb
    lib/beta_calendars/serializable.rb
    lib/beta_calendars/version.rb
    lib/beta_calendars/year.rb
  ]
  spec.bindir = "exe"
  spec.executables = ["beta-calendars"]
  spec.require_paths = ["lib"]
  spec.add_development_dependency "minitest", ">= 5.0", "< 6"
  spec.add_development_dependency "rake", ">= 12.3", "< 14"
end
