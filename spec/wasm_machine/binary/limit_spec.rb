RSpec.describe WasmMachine::Binary::Limit do
  describe "#initialize" do
    subject { described_class.new(reader, range: range) }

    let(:reader) { WasmMachine::Binary::Reader.new(binary) }
    let(:range) { 2**16 }

    context "without maximum" do
      let(:binary) { "\x00\x0F" }

      it "sets minimum" do
        expect(subject.minimum).to eq 0x0F
      end

      it "doesn't set maximum" do
        expect(subject.maximum).to be_nil
      end

      context "minimum is greater than range" do
        let(:range) { 0x0E }

        it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
      end
    end

    context "with maximum" do
      let(:binary) { "\x01\x0F\x30" }

      it "sets minimum" do
        expect(subject.minimum).to eq 0x0F
      end

      it "sets maximum" do
        expect(subject.maximum).to eq 0x30
      end

      context "maximum is greater than range" do
        let(:range) { 0x10 }

        it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
      end

      context "maximum is smaller than minimum" do
        let(:binary) { "\x01\x0F\x0E" }

        it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
      end
    end

    context "maximum flag is not neither 0 or 1" do
      let(:binary) { "\x02\x0F" }

      it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
    end
  end
end
