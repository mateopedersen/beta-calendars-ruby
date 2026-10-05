# frozen_string_literal: true

require "optparse"

module BetaCalendars
  # Small standard-library command-line interface.
  module CLI
    module_function

    def run(arguments, out: $stdout, err: $stderr)
      args = arguments.dup
      command = args.shift
      return help(out) if command.nil? || %w[help --help -h].include?(command)

      options = { week_start: :sunday, adjacent_dates: true, fixed_six_weeks: false, json: false, rows: 6 }
      parser = option_parser(options)
      parser.parse!(args)

      case command
      when "month"
        run_month(args, options, out)
      when "year"
        run_year(args, options, out)
      when "blank"
        run_blank(args, options, out)
      when "info"
        run_info(args, options, out)
      else
        raise OptionParser::InvalidArgument, "unknown command #{command.inspect}"
      end
      0
    rescue OptionParser::ParseError, ArgumentError, BetaCalendars::Error => error
      err.puts("beta-calendars: #{error.message}")
      2
    end

    def option_parser(options)
      OptionParser.new do |parser|
        parser.banner = "Usage: beta-calendars COMMAND [arguments] [options]"
        parser.on("--week-start START", "Week start: monday or sunday") { |value| options[:week_start] = value.to_sym }
        parser.on("--fixed-six-weeks", "Force monthly grids to six rows") { options[:fixed_six_weeks] = true }
        parser.on("--no-adjacent-dates", "Leave out-of-month cells empty") { options[:adjacent_dates] = false }
        parser.on("--rows COUNT", Integer, "Blank grid rows (1-60)") { |value| options[:rows] = value }
        parser.on("--json", "Print JSON") { options[:json] = true }
        parser.on("-h", "--help", "Show this help") { raise OptionParser::InvalidArgument, parser.to_s }
      end
    end

    def run_month(args, options, out)
      require_count!(args, 2, "month YEAR MONTH")
      calendar = BetaCalendars.month(
        year: integer!(args[0], "year"),
        month: integer!(args[1], "month"),
        week_start: options[:week_start],
        adjacent_dates: options[:adjacent_dates],
        fixed_six_weeks: options[:fixed_six_weeks]
      )
      options[:json] ? out.puts(calendar.to_json) : print_month(calendar, out)
    end

    def run_year(args, options, out)
      require_count!(args, 1, "year YEAR")
      calendar = BetaCalendars.year(
        year: integer!(args[0], "year"),
        week_start: options[:week_start],
        adjacent_dates: options[:adjacent_dates],
        fixed_six_weeks: options[:fixed_six_weeks]
      )
      if options[:json]
        out.puts(calendar.to_json)
      else
        out.puts("#{calendar.year} Calendar (weeks start #{calendar.week_start})")
        calendar.months.each { |month| print_month(month, out) }
      end
    end

    def run_blank(args, options, out)
      require_count!(args, 0, "blank")
      grid = BetaCalendars.blank_grid(rows: options[:rows], week_start: options[:week_start])
      if options[:json]
        out.puts(grid.to_json)
      else
        out.puts(grid.weekdays.map { |name| name[0, 2] }.join(" "))
        grid.weeks.each { out.puts(Array.new(7, "  ").join(" ")) }
      end
    end

    def run_info(args, options, out)
      require_count!(args, 1, "info YEAR")
      year = integer!(args[0], "year")
      info = {
        year: year,
        leap_year: BetaCalendars.leap_year?(year),
        months: (1..12).map do |month_number|
          { month: month_number, name: Date::MONTHNAMES[month_number], days: BetaCalendars.days_in_month(year, month_number) }
        end
      }
      options[:json] ? out.puts(JSON.generate(info)) : print_info(info, out)
    end

    def print_month(calendar, out)
      out.puts("#{calendar.month_name} #{calendar.year}")
      out.puts(calendar.weekdays.map { |name| name[0, 2] }.join(" "))
      calendar.weeks.each do |week|
        out.puts(week.map { |cell| cell ? format("%2d", cell.day) : "  " }.join(" "))
      end
      out.puts
    end

    def print_info(info, out)
      out.puts("#{info[:year]}: #{info[:leap_year] ? 'leap year' : 'common year'}")
      info[:months].each { |month| out.puts(format("%-9s %2d days", month[:name], month[:days])) }
    end

    def integer!(value, label)
      Integer(value, 10)
    rescue ArgumentError
      raise OptionParser::InvalidArgument, "#{label} must be an integer"
    end

    def require_count!(args, expected, usage)
      return if args.length == expected

      raise OptionParser::InvalidArgument, "expected #{usage}"
    end

    def help(out)
      out.puts <<~HELP
        Usage: beta-calendars COMMAND [arguments] [options]

        Commands:
          month YEAR MONTH   Print one month grid
          year YEAR          Print all twelve months
          blank              Print a blank planning grid
          info YEAR          Show leap-year and month-length information

        Options:
          --week-start monday|sunday
          --fixed-six-weeks
          --no-adjacent-dates
          --rows COUNT        Blank grid rows (1-60)
          --json
      HELP
      0
    end
  end
end
