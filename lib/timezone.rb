require "tzinfo"
require "time"
require "yaml"

module Timezone
  TimezoneChange = Struct.new(:start_date, :end_date, :timezone_name, keyword_init: true)

  DEFAULT_TIMEZONE = "America/Chicago"

  TIMEZONE_CHANGES_FILEPATH = "config/timzeone_changes.yml"
  UNCOMPLETED_TIMEZONE_CHANGES, COMPLETED_TIMEZONE_CHANGES =
    if File.exist?(TIMEZONE_CHANGES_FILEPATH)
      YAML.load(File.read(TIMEZONE_CHANGES_FILEPATH), permitted_classes: [Time])
        .fetch("timezone_changes", [])
        .map { |tzc| TimezoneChange.new(start_date: tzc["start_date"], end_date: tzc["end_date"], timezone_name: tzc["timezone_name"]) }
        .sort_by(&:start_date) # sorting allows us to exit after the first matching timezone_change
        .partition { |tzc| tzc.end_date.nil? }
    else
      [[], []]
    end

  def self.validate_timezone_changes_config
    # loading this module will parse the config file and raise parsing errors automatically,
    # so if we made it this far the config is probably not entirely broken 👍🏻
    raise "More than 1 currently active timezones" unless UNCOMPLETED_TIMEZONE_CHANGES.size < 2

    timezone_start_dates = []
    timezone_end_dates = []
    overlapping_timezone_changes = []
    COMPLETED_TIMEZONE_CHANGES.each do |timezone_change|
      if timezone_start_dates.include?(timezone_change.start_date)
        overlapping_timezone_changes << timezone_change
      end
      timezone_start_dates << timezone_change.start_date

      if timezone_end_dates.include?(timezone_change.end_date)
        overlapping_timezone_changes << timezone_change
      end
      timezone_end_dates << timezone_change.end_date
    end
    raise "Overlapping timezone changes" unless overlapping_timezone_changes.none?

    puts "Using the default timezone of #{DEFAULT_TIMEZONE} 🕓" if (COMPLETED_TIMEZONE_CHANGES + UNCOMPLETED_TIMEZONE_CHANGES).none?
  end

  # `timestamp` is a 10-digit integer for seconds since unix epoch
  def self.for_seconds_timestamp(timestamp)
    time_from_timestamp = Time.at(timestamp)

    timezone_name = nil
    COMPLETED_TIMEZONE_CHANGES.each do |timezone_change|
      if time_from_timestamp > timezone_change.start_date && time_from_timestamp < timezone_change.end_date
        # timestamp falls in the middle of a completed timezone_change
        timezone_name = timezone_change.timezone_name
        break
      end
    end

    # if timezone_name is still nil, that means it does not fall in the middle of a completed timezone change
    # so we want to try and see if there is an uncompleted timezone change that might apply
    if timezone_name.nil?
      UNCOMPLETED_TIMEZONE_CHANGES.each do |timezone_change|
        if time_from_timestamp > timezone_change.start_date
          # timestamp falls inside an uncompleted / currently active timezone_change
          timezone_name = timezone_change.timezone_name
          break
        end
      end
    end

    TZInfo::Timezone.get(timezone_name || DEFAULT_TIMEZONE) # use the default if we still haven't found a matching timezone in the config
  end
end
