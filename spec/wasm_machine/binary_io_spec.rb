RSpec.describe WARB::BinaryIO do
  describe "#reamin" do
    subject { io.remain }

    let(:io) { described_class.new("\x01\x02\x03") }

    it { is_expected.to eq 3 }

    context "already read some bytes" do
      before { io.read(2) }

      it { is_expected.to eq 1 }
    end
  end

  describe "#read" do
    subject { io.read(n) }

    let(:io) { described_class.new("\x01\x02\x03") }
    let(:n) { 3 }

    it { is_expected.to eq "\x01\x02\x03" }

    context "specified size is greater than remained binary size" do
      let(:n) { 4 }

      it { expect { subject }.to raise_error(WARB::BinaryError) }
    end
  end

  describe "#readbyte" do
    subject { io.readbyte }

    let(:io) { described_class.new("\xFF") }

    it { is_expected.to eq 0xFF }

    context "reached to EOF" do
      before { io.readbyte }

      it { expect { subject }.to raise_error(WARB::BinaryError) }
    end
  end

  describe "#read_u32" do
    subject { io.read_u32 }

    let(:io) { described_class.new("\xE5\x8E\x26") }

    it { is_expected.to eq 624485 }
  end

  describe "#read_vector" do
    subject { io.read_vector {|i| i } }

    let(:io) { described_class.new("\x03") }

    it { is_expected.to eq [0, 1, 2] }
  end
end
