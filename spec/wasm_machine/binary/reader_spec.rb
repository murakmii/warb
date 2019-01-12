RSpec.describe WasmMachine::Binary::Reader do
  describe "#reamin" do
    subject { reader.remain }

    let(:reader) { described_class.new("\x01\x02\x03") }

    it { is_expected.to eq 3 }

    context "already read some bytes" do
      before { reader.read(2) }

      it { is_expected.to eq 1 }
    end
  end

  describe "#read" do
    subject { reader.read(n) }

    let(:reader) { described_class.new("\x01\x02\x03") }
    let(:n) { 3 }

    it { is_expected.to eq "\x01\x02\x03" }

    context "specified size is greater than remained binary size" do
      let(:n) { 4 }

      it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
    end
  end

  describe "#read_byte" do
    subject { reader.read_byte }

    let(:reader) { described_class.new("\xFF") }

    it { is_expected.to eq 0xFF }

    context "reached to EOF" do
      before { reader.read_byte }

      it { expect { subject }.to raise_error(WasmMachine::BinaryError) }
    end
  end

  describe "#read_u32" do
    subject { reader.read_u32 }

    let(:reader) { described_class.new("\xE5\x8E\x26") }

    it { is_expected.to eq 624485 }
  end

  describe "#read_vector" do
    subject { reader.read_vector {|i| i } }

    let(:reader) { described_class.new("\x03") }

    it { is_expected.to eq [0, 1, 2] }
  end

  describe "#read_const_expr" do
    subject { reader.read_const_expr }

    let(:reader) { described_class.new("\x01\x02\x03\x0B") }

    it { is_expected.to eq [1, 2, 3, 11] }
  end
end
