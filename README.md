# AdvanceAFewDays

This library takes a time window time frame like "Monday-Thursday 9am-11am", and a array of rules about advancing dates `["start now", "advance 2 days", "advance 4 days", "advance 1 week"]` and returns datetimes.

## Installation

Add this line to your application's Gemfile:

    gem 'advance_a_few_days'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install advance_a_few_days

## Usage



```ruby
advance_rules = ["start now", "advance 2 days", "advance 4 days", "advance 1 week"]

window_rules = "Monday-Thursday 9am-11am"

AdvanceAFewDays.create_days(window_rules, advance_rules)
```
OR

```ruby
startdate_time = 3.days.from_now # a Rails sugar thing

AdvanceAFewDays.create_days(window_rules, advance_rules, startdate_time)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/advance_a_few_days/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
