class PassengerStatusParser

  attr_accessor :output

  def initialize(output)
    @output = output
  end

  def active
    if active = output.match(/active\s+=\s+(\d+)/)
      active[1].to_i
    elsif active = output.scan(/Sessions:\s+(\d+)/).flatten.map(&:to_i).reduce(:+)
      active
    else
      0
    end
  end

  def inactive
    if inactive = output.match(/inactive\s+=\s+(\d+)/)
      inactive[1].to_i
    else
      booted - active
    end
  end

  def max
    max = output.match(/max\s+=\s+(\d+)/) || output.match(/Max pool size\s+:\s+(\d+)/)
    max ? max[1].to_i : 0 
  end

  def booted
    booted = output.match(/count\s+=\s+(\d+)/) || output.match(/Processes\s+:\s+(\d+)/)
    booted ? booted[1].to_i : 0
  end

  def queued
    queued = output.match(/Waiting on global queue:\s+(\d+)/) || output.match(/Requests in queue:\s+(\d+)/)
    queued ? queued[1].to_i : 0
  end

  def memory
    if memory = output.scan(/Memory\s\s:\s+(\d+)/).flatten.map(&:to_i).reduce(:+)
      memory.to_f/booted.to_f
    else
      0.0
    end
  end

  def cpu
    if cpu = output.scan(/CPU:\s+(\d+)/).flatten.map(&:to_i).reduce(:+)
      cpu.to_f/booted.to_f
    else
      0.0
    end
  end

  def to_hash
    parsed = {
      :active => active, :inactive => inactive,
      :max => max, :booted => booted, :queued => queued,
      :memory => memory, :cpu => cpu
    }
  end

end
