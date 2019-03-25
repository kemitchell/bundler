# frozen_string_literal: true

RSpec.describe "bundle credits", :bundler => "2", :focus => true do
  before do
    install_gemfile <<-G
      source "file://#{gem_repo1}"

      gem "rack"
      gem "rspec", :group => [:test]
    G
  end

  context "with without-group and only-group option" do
    it "raises an error" do
      bundle "credits --without-group dev --only-group test"

      expect(err).to eq "The `--only-group` and `--without-group` options cannot be used together"
    end
  end

  describe "with without-group option" do
    context "when group is present" do
      it "prints the gems not in the specified group" do
        bundle! "credits --without-group test"

        expect(out).to include("rack: no one")
        expect(out).not_to include("rspec")
      end
    end

    context "when group is not found" do
      it "raises an error" do
        bundle "credits --without-group random"

        expect(err).to eq "`random` group could not be found."
      end
    end
  end

  describe "with only-group option" do
    context "when group is present" do
      it "prints the gems in the specified group" do
        bundle! "credits --only-group default"

        expect(out).to include("rack: no one")
        expect(out).not_to include("rspec")
      end
    end

    context "when group is not found" do
      it "raises an error" do
        bundle "credits --only-group random"

        expect(err).to eq "`random` group could not be found."
      end
    end
  end

  context "when no gems are in the gemfile" do
    before do
      install_gemfile <<-G
        source "file://#{gem_repo1}"
      G
    end

    it "prints message saying no gems are in the bundle" do
      bundle "credits"
      expect(out).to include("No gems in the Gemfile")
    end
  end

  it "lists gems installed in the bundle" do
    bundle "credits"
    expect(out).to include("rack: no one")
  end
end
