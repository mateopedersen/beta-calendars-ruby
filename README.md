# Beta Calendars Ruby

**Deterministic Gregorian calendar grids for Ruby applications.** Generate monthly and yearly calendar data locally, with week-start policies, ISO week metadata, adjacent dates, fixed six-week layouts, blank planning grids, JSON output, and a small CLI.

## Why this exists

A calendar grid looks simple, but correct output depends on leap years, weekday offsets, Sunday or Monday week starts, ISO week-year boundaries, and the geometry chosen for printing. This library turns those rules into a predictable data model without a web service, scraping, or runtime gem dependencies.

## Installation

```sh
gem install beta_calendars
```

Or add it to a Gemfile:

```ruby
gem "beta_calendars"
```

The gem requires Ruby 3.1 or newer and uses Ruby's standard `Date` and `JSON` libraries.

## Quick Start

```ruby
require "beta_calendars"

calendar = BetaCalendars.month(year: 2027, month: 1, week_start: :monday)

calendar.year       # => 2027
calendar.month      # => 1
calendar.month_name # => "January"
calendar.days.size  # => 31
calendar.weeks      # => rows of seven DayCell values
calendar.to_h       # => developer-friendly nested hash
calendar.to_json    # => JSON with ISO-8601 date strings
```

`DayCell` instances are immutable and expose `date`, `day`, `weekday`,
`iso_week`, `iso_week_year`, `in_current_month`, and `weekend`. `weekday` follows
Ruby's convention, where Sunday is `0`; `iso_weekday` follows ISO-8601, where
Monday is `1` and Sunday is `7`.

## Monthly Calendars

`BetaCalendars.month` returns a month object. Its `days` array contains only
dates in the requested month, while `weeks` and `matrix` contain the display
grid. Each populated position is a `DayCell`, not just a day number.

```ruby
january = BetaCalendars.month(year: 2027, month: 1)
january.month_name # => "January"
january.days.first.date.iso8601 # => "2027-01-01"
january.weeks.first.first.to_h
# => {:date=>"2026-12-27", :day=>27, ...}
```

The grid uses the natural four, five, or six rows required by that month unless
`fixed_six_weeks: true` is selected.

## Monday vs Sunday Week Start

Choose the first weekday explicitly. The API accepts `:monday` and `:sunday`
(or their string forms); invalid values raise `BetaCalendars::InvalidWeekStartError`.

```ruby
sunday = BetaCalendars.month(year: 2027, month: 1, week_start: :sunday)
monday = BetaCalendars.month(year: 2027, month: 1, week_start: :monday)

sunday.weekdays # => ["Sunday", "Monday", ...]
monday.weekdays # => ["Monday", "Tuesday", ...]
```

## Adjacent Month Dates

Out-of-month cells contain the neighboring real dates by default. Set
`adjacent_dates: false` to leave those cells as `nil`; this is useful when a
renderer wants visibly empty leading and trailing cells.

```ruby
filled = BetaCalendars.month(year: 2027, month: 1, adjacent_dates: true)
empty  = BetaCalendars.month(year: 2027, month: 1, adjacent_dates: false)

filled.weeks.first.first.date.iso8601 # => "2026-12-27"
empty.weeks.first.first               # => nil
```

## Fixed Six-Week Print Layouts

For printable month pages that need identical geometry, set
`fixed_six_weeks: true`. Every month then has exactly six rows and seven
columns, including months that naturally need only four or five rows.

```ruby
print_month = BetaCalendars.month(
  year: 2027,
  month: 2,
  week_start: :monday,
  fixed_six_weeks: true
)

print_month.weeks.length # => 6
print_month.weeks.all? { |week| week.length == 7 } # => true
```

With `adjacent_dates: false`, positions outside February remain `nil` even in
the sixth row. The library supplies geometry; the application decides whether
those positions render as whitespace, lines, or another design element.

## Year Calendars

`BetaCalendars.year` contains all twelve month objects. Indexing is one-based,
so `year[1]` is January and `year[12]` is December.

```ruby
calendar_year = BetaCalendars.year(year: 2027, week_start: :monday)
calendar_year.months.length # => 12
calendar_year[1].month_name # => "January"
calendar_year[12].month_name # => "December"
calendar_year.to_h
calendar_year.to_json
```

## Blank Calendar Grids

`blank_grid` creates an empty seven-column planning structure with weekday
labels and row/column metadata. It does not assign dates to the cells.

```ruby
planning_grid = BetaCalendars.blank_grid(rows: 6, week_start: :sunday)
planning_grid.weeks.length # => 6
planning_grid.weeks.first.length # => 7
planning_grid.weeks.first.first.to_h
# => {:row=>0, :column=>0, :weekday=>"Sunday"}
```

For a printable blank calendar example, see the [Beta Calendars blank
calendar](https://www.betacalendars.com/blank-calendar). The returned grid is
generic and can be used in unrelated planning applications.

## JSON Output

All calendar value objects implement `to_h` and `to_json`. Dates serialize as
ISO-8601 strings such as `"2027-01-01"`; ISO week and week-year are separate
integer fields, so year-boundary meaning is preserved.

```ruby
require "json"

calendar = BetaCalendars.month(year: 2027, month: 1, week_start: :monday)
json = calendar.to_json
parsed = JSON.parse(json)
parsed.fetch("weeks").first
```

You can also get the plain two-dimensional cell array directly:

```ruby
matrix = BetaCalendars.month_matrix(
  year: 2027,
  month: 1,
  week_start: :monday,
  adjacent_dates: false
)
```

## CLI

The installed `beta-calendars` executable offers readable terminal output or
JSON. Options may follow the command arguments.

```sh
beta-calendars month 2027 1
beta-calendars month 2027 1 --week-start monday
beta-calendars month 2027 1 --json
beta-calendars month 2027 2 --fixed-six-weeks --no-adjacent-dates
beta-calendars year 2027 --json
beta-calendars blank --rows 6 --week-start sunday
beta-calendars info 2027
```

## Calendar Correctness

The implementation uses Ruby's `Date` with the proleptic Gregorian calendar
for month length, weekday placement, and ISO-8601 week calculations. It treats
calendar dates as date-only values: there are no time zones, daylight-saving
transitions, or remote data sources in the calculation path. Supported years
are 1 through 9999.

```ruby
BetaCalendars.leap_year?(2024) # => true
BetaCalendars.days_in_month(2027, 2) # => 28
BetaCalendars.iso_week(Date.new(2021, 1, 1)).to_h # => {:week=>53, :year=>2020}
```

## Printing and Presentation

This library produces calendar data models. Your application chooses how to
render them as HTML, PDF, images, terminal output, or another format. For
printable calendar examples and planning resources, see
[Beta Calendars](https://www.betacalendars.com/).

## Related resources

- [Monthly calendar examples](https://www.betacalendars.com/monthly-calendar) show the month-grid use case supported by `BetaCalendars.month`.
- [Monthly planner pages](https://www.betacalendars.com/monthly-planner) are a related planning use case for the library's blank grids.

## Development

```sh
bundle install
bundle exec rake test
gem build beta_calendars.gemspec
```

The test suite covers leap years, month geometry, both week starts, adjacent
dates, ISO week-year boundaries, fixed print grids, blank grids, JSON output,
and the executable.

## License

MIT. See [LICENSE.txt](LICENSE.txt).
