RSpec.describe WasmMachine::Binary::GlobalType do
  describe "#initialize" do
    subject { described_class.new(reader) }

    let(:reader) { WasmMachine::Binary::Reader.new(binary) }
    let(:binary) { "\x7E\x00" }

    it "initializes #value_type" do
      expect(subject.value_type).to be WasmMachine::Binary::ValueType.i64
    end

    it "initializes #mutable?" do
      expect(subject.mutable?).to eq false
    end

    context "if mmutable" do
      let(:binary) { "\x7E\x01" }

      it "initializes #mutable?" do
        expect(subject.mutable?).to eq true
      end
    end

    context "with invalid mutable flag" do
      let(:binary) { "\x7E\x02" }

      it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
    end
  end
end
