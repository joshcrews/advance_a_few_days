require 'spec_helper'

describe AdvanceAFewDays do

  describe "create_days" do
    let(:rule1) { "start now" }
    let(:rule2) { "advance 2 days" }
    let(:rule3) { "advance 4 days" }
    let(:rule4) { "advance 1 week" }

    let(:advance_rules) { [rule1, rule2, rule3, rule4]}

    let(:time_zone_name) { 'Eastern Time (US & Canada)' }

    let(:window_rules) do
      {
        days:       "Monday:Tuesday:Wednesday:Thursday",
        start_time: "9:00",
        end_time:   "11:00",
      }
    end

    
    let(:start_datetime) { DateTime.strptime('2016-02-20 09:00:00', '%Y-%m-%d %H:%M:%S') }

    let(:time_zone_name) { 'Eastern Time (US & Canada)' }

    subject { AdvanceAFewDays.create_days(window_rules, advance_rules, start_datetime) }

    it 'should return the future advance times' do
      date1 = Date.parse('2016-02-22')
      date2 = Date.parse('2016-02-24')
      date3 = Date.parse('2016-02-29')
      date4 = Date.parse('2016-03-07')

      #
      # more of a basic than exact check
      #

      expect(subject.map(&:to_date)).to eq [date1, date2, date3, date4]
    end
  end


  describe "create_days_on_earliest_send_time" do
    let(:rule1) { "start now" }
    let(:rule2) { "advance 2 days" }
    let(:rule3) { "advance 4 days" }
    let(:rule4) { "advance 1 week" }

    let(:advance_rules) { [rule1, rule2, rule3, rule4]}

    let(:window_rules) do
      {
        days:       "Monday:Tuesday:Wednesday:Thursday",
        start_time: "9:00",
        end_time:   "11:00",
      }
    end

    

    let(:start_datetime) { DateTime.strptime('2016-02-20 09:00:00', '%Y-%m-%d %H:%M:%S') }

    let(:time_zone_name) { 'Eastern Time (US & Canada)' }

    subject { AdvanceAFewDays.create_days_on_earliest_send_time(window_rules, advance_rules, start_datetime) }

    it 'should return the future advance times', focus: true do
      date1 = DateTime.strptime('2016-02-22 09:00:00', '%Y-%m-%d %H:%M:%S')
      date2 = DateTime.strptime('2016-02-24 09:00:00', '%Y-%m-%d %H:%M:%S')
      date3 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
      date4 = DateTime.strptime('2016-03-07 09:00:00', '%Y-%m-%d %H:%M:%S')

      expect(subject).to eq [date1, date2, date3, date4]
    end

    describe "randomize_times" do
      it 'should randomize the times within the window_rules range' do

        date1 = DateTime.strptime('2016-02-22 10:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-02-24 10:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-02-29 10:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-07 10:00:00', '%Y-%m-%d %H:%M:%S')

        randomized_send_times_schedule = AdvanceAFewDays.randomize_times(window_rules, subject)

        expect(randomized_send_times_schedule[0]).to be_within(1.hours).of date1
        expect(randomized_send_times_schedule[1]).to be_within(1.hours).of date2
        expect(randomized_send_times_schedule[2]).to be_within(1.hours).of date3
        expect(randomized_send_times_schedule[3]).to be_within(1.hours).of date4

      end

      describe "move times to time zone" do
        it 'should move the times to time zone' do

          date1 = DateTime.strptime('2016-02-22 14:00:00', '%Y-%m-%d %H:%M:%S')
          date2 = DateTime.strptime('2016-02-24 14:00:00', '%Y-%m-%d %H:%M:%S')
          date3 = DateTime.strptime('2016-02-29 14:00:00', '%Y-%m-%d %H:%M:%S')
          date4 = DateTime.strptime('2016-03-07 14:00:00', '%Y-%m-%d %H:%M:%S')

          in_time_zone = AdvanceAFewDays.move_times_to_time_zone(subject, time_zone_name)

          expect(in_time_zone[0]).to eq date1
          expect(in_time_zone[1]).to eq date2
          expect(in_time_zone[2]).to eq date3
          expect(in_time_zone[3]).to eq date4

        end
      end
    end

    context "starting Sunday" do

      let(:start_datetime) { DateTime.strptime('2016-02-21 09:00:00', '%Y-%m-%d %H:%M:%S') }

      it 'should return the future advance times' do
        date1 = DateTime.strptime('2016-02-22 09:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-02-24 09:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-07 09:00:00', '%Y-%m-%d %H:%M:%S')

        expect(subject).to eq [date1, date2, date3, date4]
      end
    end

    context "starting Monday" do

      let(:start_datetime) { DateTime.strptime('2016-02-22 09:00:00', '%Y-%m-%d %H:%M:%S') }

      it 'should return the future advance times' do
        date1 = DateTime.strptime('2016-02-22 09:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-02-24 09:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-07 09:00:00', '%Y-%m-%d %H:%M:%S')

        expect(subject).to eq [date1, date2, date3, date4]
      end
    end

    context "starting Tuesday" do

      let(:start_datetime) { DateTime.strptime('2016-02-23 09:00:00', '%Y-%m-%d %H:%M:%S') }

      it 'should return the future advance times' do
        date1 = DateTime.strptime('2016-02-23 09:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-02-25 09:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-07 09:00:00', '%Y-%m-%d %H:%M:%S')

        expect(subject).to eq [date1, date2, date3, date4]
      end
    end

    context "starting Wednesday" do

      let(:start_datetime) { DateTime.strptime('2016-02-24 09:00:00', '%Y-%m-%d %H:%M:%S') }

      it 'should return the future advance times' do
        date1 = DateTime.strptime('2016-02-24 09:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-03-07 09:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-14 09:00:00', '%Y-%m-%d %H:%M:%S')

        expect(subject).to eq [date1, date2, date3, date4]
      end
    end

    context "starting Thursday" do

      let(:start_datetime) { DateTime.strptime('2016-02-25 09:00:00', '%Y-%m-%d %H:%M:%S') }

      it 'should return the future advance times' do
        date1 = DateTime.strptime('2016-02-25 09:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-03-07 09:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-14 09:00:00', '%Y-%m-%d %H:%M:%S')

        expect(subject).to eq [date1, date2, date3, date4]
      end
    end

    context "starting Friday" do

      let(:start_datetime) { DateTime.strptime('2016-02-26 09:00:00', '%Y-%m-%d %H:%M:%S') }

      it 'should return the future advance times' do
        date1 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-03-02 09:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-03-07 09:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-14 09:00:00', '%Y-%m-%d %H:%M:%S')

        expect(subject).to eq [date1, date2, date3, date4]
      end
    end

    context "Wednesday-Thursday 10am-11am" do

      let(:window_rules) do
        {
          days:       "Wednesday:Thursday",
          start_time: "10:00",
          end_time:   "11:00",
        }
      end


      it 'should return the future advance times' do
        date1 = DateTime.strptime('2016-02-24 10:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-03-02 10:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-03-09 10:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-16 10:00:00', '%Y-%m-%d %H:%M:%S')

        expect(subject).to eq [date1, date2, date3, date4]
      end

    end

    context "Monday, Wednesday, Friday 10am-11am" do

      let(:window_rules) do
        {
          days:       "Monday:Wednesday:Friday",
          start_time: "13:00",
          end_time:   "14:00",
        }
      end

      it 'should return the future advance times' do
        date1 = DateTime.strptime('2016-02-22 13:00:00', '%Y-%m-%d %H:%M:%S')
        date2 = DateTime.strptime('2016-02-24 13:00:00', '%Y-%m-%d %H:%M:%S')
        date3 = DateTime.strptime('2016-02-29 13:00:00', '%Y-%m-%d %H:%M:%S')
        date4 = DateTime.strptime('2016-03-07 13:00:00', '%Y-%m-%d %H:%M:%S')

        expect(subject).to eq [date1, date2, date3, date4]
      end

    end

  end

  describe "find_next_occurence" do

    let(:window_rules) do
      {
        days:       "Monday:Tuesday:Wednesday:Thursday",
        start_time: "9:00",
        end_time:   "11:00",
      }
    end

    let(:start_datetime) { DateTime.strptime('2016-02-20 09:00:00', '%Y-%m-%d %H:%M:%S') }
    
    subject { AdvanceAFewDays.find_next_occurence(window_rules, rule, start_datetime) }

    context "rule is start_now" do
      let(:rule) { "start now" }
    
      context "now is within time" do
        let(:start_datetime) { DateTime.strptime('2016-02-22 09:05:00', '%Y-%m-%d %H:%M:%S') }

        it 'should return now' do
          expect(subject).to eq start_datetime
        end

      end

      context "now is after time" do
        let(:start_datetime) { DateTime.strptime('2016-02-20 09:00:00', '%Y-%m-%d %H:%M:%S') }

        it "should return next time in window_rules" do
          date1 = DateTime.strptime('2016-02-22 09:00:00', '%Y-%m-%d %H:%M:%S')
          expect(subject).to eq date1
        end

        context "window rules dates is comma separated" do

          let(:window_rules) do
            {
              days:       "Wednesday:Friday",
              start_time: "9:00",
              end_time:   "11:00",
            }
          end

          it "should return next time in window_rules" do
            date1 = DateTime.strptime('2016-02-24 09:00:00', '%Y-%m-%d %H:%M:%S')
            expect(subject).to eq date1
          end
        end

        context "window rules dates are both a range and comma separated" do

          let(:window_rules) do
            {
              days:       "Monday:Wednesday:Thursday",
              start_time: "9:00",
              end_time:   "11:00",
            }
          end

          it "should return next time in window_rules" do
            date1 = DateTime.strptime('2016-02-22 09:00:00', '%Y-%m-%d %H:%M:%S')
            expect(subject).to eq date1
          end
        end
      end
      
    end



    context "rule is advance 2 days" do
      let(:rule) { "advance 2 days" }
    
      context "2 days is within time" do
        let(:start_datetime) { DateTime.strptime('2016-02-20 09:05:00', '%Y-%m-%d %H:%M:%S') }

        it 'should return 2 days from now' do
          expect(subject).to eq (start_datetime + 2)
        end

      end

      context "2 days is after time" do
        let(:start_datetime) { DateTime.strptime('2016-02-25 09:00:00', '%Y-%m-%d %H:%M:%S') }

        it "should return next time in window_rules" do
          date1 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
          expect(subject).to eq date1
        end

      end
      
    end


    context "rule is advance 1 week" do
      let(:rule) { "advance 1 week" }
    
      context "1 week is within time" do
        let(:start_datetime) { DateTime.strptime('2016-02-22 09:05:00', '%Y-%m-%d %H:%M:%S') }

        it 'should return 1 week from now' do
          expect(subject).to eq (start_datetime + 7)
        end

      end

      context "1 week is after time" do
        let(:start_datetime) { DateTime.strptime('2016-02-20 09:00:00', '%Y-%m-%d %H:%M:%S') }

        it "should return next time in window_rules" do
          date1 = DateTime.strptime('2016-02-29 09:00:00', '%Y-%m-%d %H:%M:%S')
          expect(subject).to eq date1
        end

      end
      
    end

  end

end