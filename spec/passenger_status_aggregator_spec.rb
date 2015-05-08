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

  subject {PassengerStatusAggregator.new(options)}

  context "#initialize" do
    it "should set instance variables properly" do
      expect(subject.stats).to eq ({})
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
      subject.stats[:"foo1.bar.com"] = {
        :max => 10,
        :active => 4
      }
      expect(subject.capacity).to eq(40.0)
    end
  end

  context "parse_output" do
    let(:parser) {double()}

    it "calls PassengerStatusParser.new and to_hash" do
      expect(PassengerStatusParser).to receive(:new).with(v5_response).and_return(parser)
      expect(parser).to receive(:to_hash)
      subject.parse_output("bar",v5_response)
    end
  end

  context "results" do
    subject {PassengerStatusAggregator.new(options)}
    before do
      subject.stats["foo1.bar.com"] = {
        :max => 10,
        :active => 4,
        :booted => 6,
        :queued => 0,
        :cpu => 4.0,
        :memory => 100
      }
      subject.stats["foo2.bar.com"] = {
        :max => 10,
        :active => 4,
        :booted => 6,
        :queued => 10,
        :cpu => 1.0,
        :memory => 40
      }
    end

    context "#max" do
      it "gets the correct result" do
        expect(subject.max).to eq(20)
      end
    end
    context "#active" do
      it "gets the correct result" do
        expect(subject.active).to eq(8)
      end
    end
    context "#queued" do
      it "gets the correct result" do
        expect(subject.queued).to eq(10)
      end
    end
    context "#cpu" do
      it "gets the correct result" do
        expect(subject.cpu).to eq(2.5)
      end
    end
    context "#memory" do
      it "gets the correct result" do
        expect(subject.memory).to eq(70)
      end
    end
  end

end
