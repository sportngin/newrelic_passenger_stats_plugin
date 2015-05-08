require 'timeout'
require 'passenger_status_parser'

class PassengerStatusAggregator

  attr_accessor :stats

  def initialize(options)
    @stats = {
      :max => 0,
      :booted => 0,
      :active => 0,
      :inactive => 0,
      :queued => 0,
    }
    @ssh_command = options[:ssh_command]
    @app_hostnames = options[:app_hostnames]
    @passenger_status_command = options[:passenger_status_command]
  end

  def app_hostnames
    YAML.load_file("config/newrelic_plugin.yml")["agents"]["passenger_stats"]["app_hostnames"]
  end

  def run
    app_hostnames.each do |hostname|
      collect_stats(hostname)
    end
  end

  def collect_stats(hostname)
    begin
      Timeout::timeout(10) do
        output = `#{@ssh_command} #{hostname} '#{@passenger_status_command}'`
        parse_output(output)
      end
    rescue StandardError
      # continue on if we get an error
    end
  end

  def capacity
    if @stats[:max] > 0
      @stats[:active].to_f / @stats[:max].to_f * 100
    else
      0
    end
  end

  def parse_output(output)
    parsed = PassengerStatusParser.new(output)
    @stats[:active] += parsed.active
    @stats[:inactive] += parsed.inactive
    @stats[:max] += parsed.max
    @stats[:booted] += parsed.booted
    @stats[:queued] += parsed.queued
  end

end
