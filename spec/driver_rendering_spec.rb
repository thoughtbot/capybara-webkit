require 'spec_helper'
require 'capybara/webkit/driver'
require 'mini_magick'

describe Capybara::Webkit::Driver, "rendering an image" do
  include AppRunner

  let(:driver) do
    driver_for_html(<<-HTML)
      <html>
        <body>
          <h1>Hello World</h1>
        </body>
      </html>
    HTML
  end

  before(:each) do
    # Set up the tmp directory and file name
    tmp_dir    = File.join(PROJECT_ROOT, 'tmp')
    FileUtils.mkdir_p tmp_dir
    @file_name = File.join(tmp_dir, 'render-test.png')
    driver.visit("#{AppRunner.app_host}/")
  end

  def render(options)
    FileUtils.rm_f @file_name
    driver.save_screenshot @file_name, options

    @image = MiniMagick::Image.open @file_name
  end

  context "with default options" do
    before { render({}) }

    it "should be a PNG" do
      @image[:format].should eq "PNG"
    end

    it "width default to 1000px (with 15px less for the scrollbar)" do
      @image[:width].should be < 1001
      @image[:width].should be > 1000-17
    end

    it "height should be at least 10px" do
      @image[:height].should be >= 10
    end
  end

  context "with dimensions set larger than necessary" do
    before { render(:width => 500, :height => 400) }

    it "width should match the width given" do
      @image[:width].should eq 500
    end

    it "height should match the height given" do
      @image[:height].should eq 400
    end

    it "should reset window dimensions to their default value" do
      driver.evaluate_script('window.innerWidth').should eq 1680
      driver.evaluate_script('window.innerHeight').should eq 1050
    end
  end

  context "with dimensions set smaller than the document's default" do
    before { render(:width => 50, :height => 10) }

    it "width should be greater than the width given" do
      @image[:width].should be > 50
    end

    it "height should be greater than the height given" do
      @image[:height].should be > 10
    end

    it "should restore viewport dimensions after rendering" do
      driver.evaluate_script('window.innerWidth').should eq 1680
      driver.evaluate_script('window.innerHeight').should eq 1050
    end
  end

  context "with a custom viewport size" do
    before { driver.resize_window(800, 600) }

    it "should restore viewport dimensions after rendering" do
      render({})
      driver.evaluate_script('window.innerWidth').should eq 800
      driver.evaluate_script('window.innerHeight').should eq 600
    end
  end

  context "with invalid filepath" do
    before do
      @file_name = File.dirname(@file_name)
    end

    it "raises an InvalidResponseError" do
      expect { render({}) }.to raise_error(Capybara::Webkit::InvalidResponseError)
    end
  end

  context "with AWS configured to store screenshots" do
    let(:s3_object) { double("S3 object", write: true) }

    let(:s3_bucket) do
      double(
        "S3 bucket",
        objects: { "render-test.png" => s3_object }
      )
    end

    let(:s3_connection) do
      double( "AWS-S3 connection", buckets: { "my-capybara-bucket" => s3_bucket })
    end

    before do
      ENV["CAPYBARA_WEBKIT_S3_SCREENSHOTS_BUCKET"] = "my-capybara-bucket"
      ENV["CAPYBARA_WEBKIT_S3_ACCESS_KEY_ID"] = "my-access-key-id"
      ENV["CAPYBARA_WEBKIT_S3_SECRET_ACCESS_KEY"] = "my-secret-access-key"
      allow(AWS::S3).to receive(:new) { s3_connection }

      render({})
    end

    it "connects to AWS with proper credentials" do
      expect(AWS::S3).to have_received(:new).with(
        access_key_id: 'my-access-key-id',
        secret_access_key: 'my-secret-access-key'
      )
    end

    it "writes the screenshot to the specified S3 bucket" do
      expect(s3_object).to have_received(:write)
    end

    after do
      [
        "CAPYBARA_WEBKIT_S3_SCREENSHOTS_BUCKET",
        "CAPYBARA_WEBKIT_S3_ACCESS_KEY_ID",
        "CAPYBARA_WEBKIT_S3_SECRET_ACCESS_KEY"
      ].each do |aws_variable|
        ENV.delete(aws_variable)
      end
    end
  end
end
