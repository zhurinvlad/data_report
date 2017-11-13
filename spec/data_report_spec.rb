require "spec_helper"

RSpec.describe DataReport do
  it "has a version number" do
    expect(DataReport::VERSION).not_to be nil
  end
  describe "--Utils dir--" do

    context "working without date" do
      dir_path = DataReport.create_dir

      it "creating" do
        expect(dir_path.exist?).to eq(true)
      end

      it "removing" do
        DataReport.remove_dir
        expect(dir_path.exist?).to eq(false)
      end
    end

    context "working with date" do
      date_dir = '2000-05-05'
      dir_path = DataReport.create_dir(date_dir)
      it "creating" do
        expect(dir_path.exist?).to eq(true)
      end

      it "removing" do
        DataReport.remove_dir(date_dir)
        expect(dir_path.exist?).to eq(false)
      end
    end

  end

end
