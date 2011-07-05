require 'spec_helper'
require 'capybara/driver/webkit'
require 'mini_magick'

describe Capybara::Driver::Webkit, "rendering an image" do

  before(:all) do
    # Set up the tmp directory and file name
    tmp_dir    = File.join(PROJECT_ROOT, 'tmp')
    FileUtils.mkdir_p tmp_dir
    @file_name = File.join(tmp_dir, 'render-test.png')

    app = lambda do |env|
      body = <<-HTML
        <html>
          <body>
            <h1>Hello World</h1>
          </body>
        </html>
      HTML
      [200,
        { 'Content-Type' => 'text/html', 'Content-Length' => body.length.to_s },
        [body]]
    end

    @driver = Capybara::Driver::Webkit.new(app, :browser => $webkit_browser)
    @driver.visit("/hello/world?success=true")
  end

  after(:all) { @driver.reset! }

  def render(options)
    FileUtils.rm_f @file_name
    @driver.render @file_name, options

    @image = MiniMagick::Image.open @file_name
  end

  context "with default options" do
    before(:all){ render({}) }

    it "should be a PNG" do
      @image[:format].should == "PNG"
    end

    it "width default to 1000px (with 15px less for the scrollbar)" do
      @image[:width].should be < 1001
      @image[:width].should be > 1000-17
    end

    it "height should be at least 10px" do
      @image[:height].should >= 10
    end
  end

  context "with dimensions set larger than necessary" do
    before(:all){ render(:width => 500, :height => 400) }

    it "width should match the width given" do
      @image[:width].should == 500
    end

    it "height should match the height given" do
      @image[:height].should > 10
    end
  end

  context "with dimensions set smaller than the document's default" do
    before(:all){ render(:width => 50, :height => 10) }

    it "width should be greater than the width given" do
      @image[:width].should > 50
    end

    it "height should be greater than the height given" do
      @image[:height].should > 10
    end
  end

end
