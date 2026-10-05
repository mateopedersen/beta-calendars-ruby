# Contributing

Bug reports, focused feature proposals, and pull requests are welcome. Please
include a small example that shows the expected calendar dates and week-start
policy when reporting a calculation issue.

## Development

The library targets Ruby 3.1 and newer and has no runtime gem dependencies.

```sh
bundle install
bundle exec rake test
gem build beta_calendars.gemspec
```

Keep changes deterministic, use Ruby's proleptic Gregorian `Date` calculations,
and add meaningful tests for boundary dates. Do not add network access to the
calendar computation path.
