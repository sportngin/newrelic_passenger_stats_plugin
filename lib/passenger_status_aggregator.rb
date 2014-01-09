require 'timeout'

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
    run
  end

  def percent_capacity
    if @stats[:max] > 0
      @stats[:active] / @stats[:max] * 100
    else
      0
    end
  end

  private

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

  # Example output from passenger-status:
  # ----------- General information -----------
  # max      = 8
  # count    = 6
  # active   = 4
  # inactive = 2
  # Waiting on global queue: 5
  def parse_output(output)
    @stats[:max] += output.match(/max\s+=\s+(\d+)/)[1].to_i
    @stats[:booted] += output.match(/count\s+=\s+(\d+)/)[1].to_i
    @stats[:active] += output.match(/active\s+=\s+(\d+)/)[1].to_i
    @stats[:inactive] += output.match(/inactive\s+=\s+(\d+)/)[1].to_i
    @stats[:queued] += output.match(/Waiting on global queue:\s+(\d+)/)[1].to_i
  end

end