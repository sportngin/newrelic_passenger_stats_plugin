require 'passenger_status_aggregator'
require 'spec_helper'

describe PassengerStatusParser do
  let(:v5_response) {PassengerSpecHelper.v5_response}
  let(:v3_response) {PassengerSpecHelper.v3_response} 
  context "Passenger 3/4" do
    subject {PassengerStatusParser.new(v3_response)}

    context "#active" do
      it "returns the right value" do
        expect(subject.active).to eq(0)
      end
    end

    context "#inactive" do
      it "returns the right value" do
        expect(subject.inactive).to eq(4)
      end
    end

    context "#max" do
      it "returns the right value" do
        expect(subject.max).to eq(4)
      end
    end

    context "#booted" do
      it "returns the right value" do
        expect(subject.booted).to eq(4)
      end
    end

    context "#queued" do
      it "returns the right value" do
        expect(subject.queued).to eq(0)
      end
    end

    context "#cpu" do
      it "returns the right value" do
        expect(subject.cpu).to eq(0.0)
      end
    end

    context "#memory" do
      it "returns the right value" do 
        expect(subject.memory).to eq(0.0)
      end
    end

    context "#to_hash" do 
      let (:parsed) do 
        {
          :active => 0, :inactive => 4,
          :max => 4, :booted => 4, :queued => 0,
          :memory => 0.0, :cpu => 0.0
        }
      end
      it "returns the right value" do 
        expect(subject.to_hash).to eq(parsed)
      end
    end
  end

  context "Passenger 5" do
    subject {PassengerStatusParser.new(v5_response)}
    context "#active" do
      it "returns the right value" do
        expect(subject.active).to eq(1)
      end
    end

    context "#inactive" do
      it "returns the right value" do
        expect(subject.inactive).to eq(1)
      end
    end

    context "#max" do
      it "returns the right value" do
        expect(subject.max).to eq(2)
      end
    end

    context "#booted" do
      it "returns the right value" do
        expect(subject.booted).to eq(2)
      end
    end

    context "#queued" do
      it "returns the right value" do
        expect(subject.queued).to eq(3)
      end
    end

    context "#cpu" do
      it "returns the right value" do
        expect(subject.cpu).to eq(1.0)
      end
    end

    context "#memory" do
      it "returns the right value" do 
        expect(subject.memory).to eq(42.5)
      end
    end

    context "#to_hash" do 
      let (:parsed) do 
        {
          :active => 1, :inactive => 1,
          :max => 2, :booted => 2, :queued => 3,
          :memory => 42.5, :cpu => 1.0
        }
      end
      it "returns the right value" do 
        expect(subject.to_hash).to eq(parsed)
      end
    end
  end

  context "No Output" do
    subject {PassengerStatusParser.new("Foo Bar")}

    context "#active" do
      it "returns the right value" do
        expect(subject.active).to eq(0)
      end
    end

    context "#inactive" do
      it "returns the right value" do
        expect(subject.inactive).to eq(0)
      end
    end

    context "#max" do
      it "returns the right value" do
        expect(subject.max).to eq(0)
      end
    end

    context "#booted" do
      it "returns the right value" do
        expect(subject.booted).to eq(0)
      end
    end

    context "#queued" do
      it "returns the right value" do
        expect(subject.queued).to eq(0)
      end
    end
  end
end
