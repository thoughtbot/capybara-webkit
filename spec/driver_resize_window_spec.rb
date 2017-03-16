require 'spec_helper'
require 'capybara/webkit/driver'

describe Capybara::Webkit::Driver, "#resize_window(width, height)" do
  include AppRunner

  let(:driver) do
    driver_for_html(<<-HTML)
      <html>
        <body>
          <h1 id="dimentions">UNKNOWN</h1>

          <script>
            window.onload = window.onresize = function(){
              document.getElementById("dimentions").innerHTML = "[" + window.innerWidth + "x" + window.innerHeight + "]";
            };
          </script>

        </body>
      </html>
    HTML
  end

  DEFAULT_DIMENTIONS = "[1680x1050]"

  it "resizes the window to the specified size" do
    driver.visit("#{AppRunner.app_host}/")

    driver.resize_window(800, 600)
    expect(driver.html).to include("[800x600]")

    driver.resize_window(300, 100)
    expect(driver.html).to include("[300x100]")
  end

  it "resizes the window to the specified size even before the document has loaded" do
    driver.resize_window(800, 600)
    driver.visit("#{AppRunner.app_host}/")
    expect(driver.html).to include("[800x600]")
  end

  it "resets the window to the default size when the driver is reset" do
    driver.resize_window(800, 600)
    driver.reset!
    driver.visit("#{AppRunner.app_host}/")
    expect(driver.html).to include(DEFAULT_DIMENTIONS)
  end

  it "resizes windows by handle" do
    driver.visit("#{AppRunner.app_host}/")
    driver.open_new_window
    driver.visit("#{AppRunner.app_host}/")

    driver.resize_window_to(driver.window_handles.first, 800, 600)
    driver.resize_window_to(driver.window_handles.last, 400, 300)

    expect(driver.window_size(driver.window_handles.first)).to eq [800, 600]
    expect(driver.window_size(driver.window_handles.last)).to eq [400, 300]
  end

  it "maximizes a window" do
    driver.visit("#{AppRunner.app_host}/")
    driver.resize_window(400, 300)
    driver.maximize_window(driver.current_window_handle)
    width, height = *driver.window_size(driver.current_window_handle)

    expect(width).to be > 400
    expect(height).to  be > 300
  end
end
