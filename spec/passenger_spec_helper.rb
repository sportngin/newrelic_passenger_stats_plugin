module PassengerSpecHelper
  def self.v3_response 
    response =<<EOF 
----------- General information -----------
max      = 4
count    = 4
active   = 0
inactive = 4
Waiting on global queue: 0

----------- Application groups -----------
/srv/www/ngin/current:
  App root: /srv/www/ngin/current
  * PID: 18198   Sessions: 0    Processed: 127     Uptime: 3m 51s
  * PID: 18189   Sessions: 0    Processed: 152     Uptime: 3m 51s
  * PID: 18206   Sessions: 0    Processed: 97      Uptime: 3m 51s
  * PID: 18181   Sessions: 0    Processed: 67      Uptime: 4m 34s
EOF
  end

  def self.v5_response 
    response =<<EOF 
Version : 5.0.7
Date    : 2015-05-07 11:32:16 -0700
Instance: qHjiiRNe (nginx/1.8.0 Phusion_Passenger/5.0.7)

----------- General information -----------
Max pool size : 2
Processes     : 2
Requests in top-level queue : 0

----------- Application groups -----------
/srv/www/stat_ngin/current/public (staging)#default:
  App root: /srv/www/stat_ngin/current
  Requests in queue: 3
  * PID: 11169   Sessions: 0       Processed: 74      Uptime: 1m 18s
    CPU: 2%      Memory  : 71M     Last used: 0s ago
  * PID: 11460   Sessions: 1       Processed: 0       Uptime: 11s
    CPU: 0%      Memory  : 14M     Last used: 11s ago
EOF
  end

  def self.plugin_yaml
    response =<<EOF
newrelic:
  #
  # Update with your New Relic account license key:
  #
  license_key: 'YOUR_LICENSE_KEY_HERE'
  #
  # Set to '1' for verbose output, remove for normal output.
  # All output goes to stdout/stderr.
  #
  # verbose: 1
#
# Agent Configuration:
#
agents:
  passenger_stats:
    app_name: my_app
    ssh_command: ssh -l username
    passenger_status_command: passenger-status
    # the hostnames for your app instances
    # - the agent will ssh into these to run `passenger-status` and `passenger-memory-stats`
    app_hostnames:
      - foo1.bar.com
      - foo2.bar.com
EOF
  end
end
