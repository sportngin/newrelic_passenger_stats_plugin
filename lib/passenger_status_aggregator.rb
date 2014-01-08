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

  private

  def run
    app_hostnames.each do |hostname|
      collect_stats(hostname)
    end
  end

  def collect_stats(hostname)
    output = `#{@ssh_command} #{hostname} '#{@passenger_status_command}'`
    parse_output(output)
  end

  # Example output from passenger-status:
  # ----------- General information -----------
  # max      = 8
  # count    = 6
  # active   = 4
  # inactive = 2
  # Waiting on global queue: 5
  def parse_output(output)
    @stats[:max] = output.match(/max\s+=\s+(\d+)/)
    @stats[:booted] = output.match(/count\s+=\s+(\d+)/)
    @stats[:active] = output.match(/active\s+=\s+(\d+)/)
    @stats[:inactive] = output.match(/inactive\s+=\s+(\d+)/)
    @stats[:queued] = output.match(/Waiting on global queue:\s+(\d+)/)
  end

end