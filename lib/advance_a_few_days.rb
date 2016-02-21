require "advance_a_few_days/version"
require "working_hours"

module AdvanceAFewDays
  class << self
    def create_days(window_rules, start_rules, start_datetime)
      schedule = create_days_on_earliest_send_time(window_rules, start_rules, start_datetime)
      randomize_times(window_rules, schedule)
    end

    def randomize_times(config, schedule)
      WorkingHours::Config.with_config(config) do
        schedule.map do |datetime|
          new_randomized_time_in_range(datetime)
        end
      end
    end

    def new_randomized_time_in_range(datetime)
      early_time = datetime
      late_time  = WorkingHours.advance_to_closing_time(datetime)
      range      = late_time - early_time

      early_time + rand * range.to_f
    end

    def create_days_on_earliest_send_time(window_rules, start_rules, start_datetime)
      WorkingHours::Config.with_config(window_rules) do
        start_rules.reduce([]) do |acc, rule|
          value = if acc == []
            find_next_occurence(rule, start_datetime)
          else
            find_next_occurence(rule, acc.last)
          end

          acc << (value)
        end
      end
    end

    def find_next_occurence(rule, start_datetime)
      start_datetime = get_start_time(rule, start_datetime)
      handle_start_rule(start_datetime)
    end

    def get_start_time(rule, start_datetime)
      numeral = rule.scan(/\d+/).first

      if rule =~ /start/
        start_datetime
      elsif rule =~ /\d+ day/i
        start_datetime + numeral.to_i.days
      elsif rule =~ /\d+ week/i
        start_datetime + (numeral.to_i * 7).days
      else
        raise "expected rule #{rule} to be parsed but wasn't"
      end
    end

    def handle_start_rule(start_datetime)
      if WorkingHours.in_working_hours?(start_datetime)
        start_datetime
      else
        WorkingHours.advance_to_working_time(start_datetime)
      end
    end
  end
end
