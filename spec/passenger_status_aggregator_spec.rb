require 'passenger_status_aggregator'
require 'spec_helper'

describe PassengerStatusAggregator do 
  let(:v5_response) {PassengerSpecHelper.v5_response}
  let(:v3_response) {PassengerSpecHelper.v3_response} 
  let(:plugin_yaml) {PassengerSpecHelper.plugin_yaml}
  let(:options) do 
    {
      :ssh_command => "ssh command", 
      :app_hostnames => ["foo1.bar.com","foo2.bar.com"], 
      :passenger_status_command => "passenger status"
    }
  end
  let(:stats) do
    {
      :max => 0,
      :booted => 0,
      :active => 0,
      :inactive => 0,
      :queued => 0,
    }
  end

  subject {PassengerStatusAggregator.new(options)}

  context "#initialize" do
    it "should set instance variables properly" do
      expect(subject.stats).to eq (stats)
      expect(subject.instance_variable_get(:@ssh_command)).to eq("ssh command")
      expect(subject.instance_variable_get(:@app_hostnames)).to eq(["foo1.bar.com","foo2.bar.com"])
      expect(subject.instance_variable_get(:@passenger_status_command)).to eq("passenger status")
    end
  end

  context "#app_hostnames" do
    it "should return the correct hostnames from YAML" do
      yaml = YAML.load(plugin_yaml)
      filepath = "config/newrelic_plugin.yml"
      allow(YAML).to receive(:load_file).with(filepath).and_return(yaml)
      expect(subject.app_hostnames).to eq(options[:app_hostnames])
    end
  end

  context "#run" do
    it "call #collect_stats on each hostname" do
      allow(subject).to receive(:app_hostnames).and_return(options[:app_hostnames])
      expect(subject).to receive(:collect_stats).with("foo1.bar.com")
      expect(subject).to receive(:collect_stats).with("foo2.bar.com")
      subject.run
    end
  end

  context "#capacity" do
    subject {PassengerStatusAggregator.new(options)}

    it "returns a percentage" do
      subject.stats[:max] = 10
      subject.stats[:active] = 4
      expect(subject.capacity).to eq(40.0)
    end
  end

  context "parse_output" do
    let(:parser) {double()}
    before do
      allow(parser).to receive(:active) {2}
      allow(parser).to receive(:inactive) {4}
      allow(parser).to receive(:max) {6}
      allow(parser).to receive(:booted) {8}
      allow(parser).to receive(:queued) {10}
    end

    it "calls PassengerStatusParser.new" do
      expect(PassengerStatusParser).to receive(:new).with(v5_response).and_return(parser)
      subject.parse_output(v5_response)
    end

    it "increments active, inactive, max, booted, queued" do
      allow(PassengerStatusParser).to receive(:new).with(v5_response).and_return(parser)
      expect(parser).to receive(:active)
      expect(parser).to receive(:inactive)
      expect(parser).to receive(:max)
      expect(parser).to receive(:booted)
      expect(parser).to receive(:queued)
      subject.parse_output(v5_response)
    end
  end

end
