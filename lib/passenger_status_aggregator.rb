require 'timeout'
require_relative 'passenger_status_parser'

class PassengerStatusAggregator

  attr_accessor :stats

  def initialize(options)
    @stats = {}
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
        parse_output(hostname,output)
      end
    rescue StandardError
      # continue on if we get an error
    end
  end
  
  def parse_output(hostname,output)
    @stats[hostname] = PassengerStatusParser.new(output).to_hash
  end

  def capacity
    if max > 0
      active.to_f / max.to_f * 100
    else
      0
    end
  end

  def max
    stats.map{|host,stats| stats[:max]}.reduce(:+) 
  end

  def active
    stats.map{|host,stats| stats[:active]}.reduce(:+)
  end

  def booted
    stats.map{|host,stats| stats[:booted]}.reduce(:+)
  end

  def queued
    stats.map{|host,stats| stats[:queued]}.reduce(:+)
  end

  def cpu
    stats.map{|host,stats| stats[:cpu]}.reduce(:+) / stats.keys.count
  end

  def memory
    stats.map{|host,stats| stats[:memory]}.reduce(:+) / stats.keys.count
  end
end
