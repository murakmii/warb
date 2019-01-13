RSpec.describe WasmMachine::Binary::FunctionType do
  describe "#initialize" do
    subject { described_class.new(reader) }

    let(:reader) { WasmMachine::Binary::Reader.new(binary) }
    let(:binary) { "\x60\x01\x7F\x01\x7E" }

    it "initializes parameters" do
      expect(subject.parameters).to eq [WasmMachine::Binary::ValueType.i32]
    end

    it "initializes results" do
      expect(subject.results).to eq [WasmMachine::Binary::ValueType.i64]
    end

    context "with invalid magic bytes" do
      let(:binary) { "\x61\x01\x7F\x01\x7E" }

      it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
    end

    xcontext "with no results" do
      let(:binary) { "\x60\x01\x7F\x00" }

      it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
    end
  end
end
