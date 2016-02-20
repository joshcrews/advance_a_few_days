require "advance_a_few_days/version"
require 'active_support'
require 'active_support/core_ext/numeric/time'

module AdvanceAFewDays

  def self.create_days(window_rules, start_rules, start_datetime = Time.now)
    schedule = create_days_on_earliest_send_time(window_rules, start_rules, start_datetime = Time.now)

    randomize_times(window_rules, schedule)
  end

  def self.randomize_times(window_rules, schedule)
    schedule.map do |datetime|
      new_randomized_time_in_range = new_randomized_time_in_range(window_rules)
      combine_date_and_time(datetime.to_date, new_randomized_time_in_range)
    end
  end

  def self.new_randomized_time_in_range(window_rules)
    early_time, late_time = extra_time_range_from_rules(window_rules)

    range = late_time - early_time

    early_time + rand * range.to_f
  end
  
  def self.create_days_on_earliest_send_time(window_rules, start_rules, start_datetime = Time.now)

    start_rules.reduce([]) do |acc, rule| 
      value = if acc == []
        find_next_occurence(window_rules, rule, start_datetime)
      else
        find_next_occurence(window_rules, rule, acc.last)
      end

      acc << (value)
    end
  end

  def self.find_next_occurence(window_rules, rule, start_datetime)
    if rule =~ /start/
      handle_start_rule(window_rules, start_datetime)
    elsif rule =~ /advance \d+ day/i
      handle_advance_days(window_rules, rule, start_datetime)
    elsif rule =~ /advance \d+ week/i
      handle_advance_weeks(window_rules, rule, start_datetime)
    else
      raise "expected rule #{rule} to be parsed but wasn't"
    end
  end

  def self.handle_advance_weeks(window_rules, rule, start_datetime)
    day_number = rule.scan(/\d+/).first
    start_datetime = start_datetime + (day_number.to_i * 7)
    handle_start_rule(window_rules, start_datetime)    
  end

  def self.handle_advance_days(window_rules, rule, start_datetime)
    day_number = rule.scan(/\d+/).first
    start_datetime = start_datetime + day_number.to_i
    handle_start_rule(window_rules, start_datetime)    
  end

  def self.handle_start_rule(window_rules, start_datetime)
    if in_window?(window_rules, start_datetime)
      start_datetime
    else
      next_datetime_in_window(window_rules, start_datetime)
    end
  end

  def self.in_window?(window_rules, start_datetime)
    on_a_good_day?(window_rules, start_datetime.to_date) && at_a_good_time?(window_rules, start_datetime)
  end

  def self.next_datetime_in_window(window_rules, start_datetime)
    next_good_day = next_date_in_window(window_rules, start_datetime.to_date)
    next_good_time = next_time_in_window(window_rules, start_datetime)
    combine_date_and_time(next_good_day, next_good_time)
  end

  def self.combine_date_and_time(date, time)
    string = date.strftime("%F") + " " + time.strftime("%H:%M")
    DateTime.strptime(string, "%F %H:%M")
  end

  def self.next_time_in_window(window_rules, datetime)
    early_time, late_time = extra_time_range_from_rules(window_rules)

    early_time
  end

  def self.next_date_in_window(window_rules, date)
    try_date = date
    next_good_day = nil
    while(next_good_day == nil) do
      if on_a_good_day?(window_rules, try_date)
        next_good_day = try_date
      else
        try_date = try_date + 1
      end
    end  

    next_good_day
  end

  

  def self.extract_date(start_datetime)
    start_datetime.to_date
  end

  def self.on_a_good_day?(window_rules, start_datetime)
    parse_days_of_week(window_rules).include?(start_datetime.wday)
  end

  def self.day_names_to_numbers(day_names)
    day_names.map{|day_name| day_name_to_number(day_name)}
  end

  def self.day_name_to_number(day_name)
    case day_name
    when /sunday/i
      0
    when /monday/i
      1
    when /tuesday/i
      2
    when /wednesday/i
      3
    when /thursday/i
      4
    when /friday/i
      5
    when /satursday/i
      6
    else
      raise "expected `#{day_name}` to be like Sunday, Monday... but wasn't"
    end
  end

  def self.parse_days_of_week(window_rules)
    just_day_names = just_day_names(window_rules)

    just_day_names
      .split(",")
      .map(&:strip)
      .map{|day_text| parse_day_text_as_if_range(day_text)}
      .flatten
  end

  def self.parse_day_text_as_if_range(day_text)
    if day_text =~ /-/
      parse_day_names_range(day_text)
    else
      day_names_to_numbers(extract_day_names(day_text))
    end
  end

  def self.just_day_names(window_rules)
    window_rules.split(/\d+am|pm/i).first.strip
  end

  def self.parse_day_names_range(just_day_names)
    range_first, range_last = just_day_names.split(/-+/, 2).map(&:strip)

    range_first_number = day_name_to_number(range_first)
    range_last_number = day_name_to_number(range_last)
    (range_first_number..range_last_number).to_a
  end

  def self.extract_day_names(just_day_names)
    just_day_names.split(",").map(&:strip)
  end

  def self.at_a_good_time?(window_rules, start_datetime)
    early_time, late_time = extra_time_range_from_rules(window_rules)

    (extract_time(start_datetime) >= early_time) && (extract_time(start_datetime) <= late_time)
  end

  def self.extract_time(datetime)
    hours_and_minutes = datetime.strftime('%H:%M')
    DateTime.strptime(hours_and_minutes, '%H:%M')
  end

  def self.extra_time_range_from_rules(window_rules)
    window_rules.gsub(" ", "").scan(/\d+.m/i)
      .map{|time| DateTime.strptime(time, '%H%p')}
  end

end
