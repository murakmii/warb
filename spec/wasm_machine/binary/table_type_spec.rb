RSpec.describe WasmMachine::Binary::TableType do
  describe "#initialize" do
    subject { described_class.new(reader) }

    let(:reader) { WasmMachine::Binary::Reader.new(binary) }
    let(:binary) { "\x70\x01\x0E\x0F" }

    it "initializes element" do
      expect(subject.element).to eq 0x70
    end

    it "initializes limit" do
      expect(subject.limit.minimum).to eq 0x0E
      expect(subject.limit.maximum).to eq 0x0F
    end

    it "initializes limit with valid range" do
      allow(WasmMachine::Binary::Limit).to receive(:new).and_call_original
      subject
      expect(WasmMachine::Binary::Limit).to have_received(:new).with(anything, range: 2**32)
    end

    context "with invalid element" do
      let(:binary) { "\x71\x01\x0E\x0F" }

      it { expect { subject }.to raise_error(WasmMachine::BinaryError, "Unsupport table element: 0x71") }
    end
  end
end
