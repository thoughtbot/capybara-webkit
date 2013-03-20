class ClickBenchmark
  def app
    Class.new(Sinatra::Base) do
      get '/' do
        <<-HTML
          <html>
            <body>
              <div>
                <a href="#">Click Me</a>
              </div>
            </body>
          </html>
        HTML
      end
    end
  end

  def run(session)
    500.times do
      session.click_on 'Click Me'
    end
  end
end
