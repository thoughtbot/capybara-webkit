class FormsBenchmark
  def app
    Class.new(Sinatra::Base) do
      get '/' do
        fields = (1..100).map { |index|
          <<-HTML
            <label for="field#{index}">Field #{index} Label</label>
            <input type="text" name="field#{index}" id="field#{index}" />
          HTML
        }.join

        <<-HTML
          <form action="/" method="post">
            #{fields}
            <input type="submit" value="Submit" />
          </form>
        HTML
      end

      post '/' do
        redirect '/'
      end
    end
  end

  def run(session)
    (1..100).each do |index|
      session.fill_in "Field #{index} Label", with: "Value #{index}"
    end
    session.click_on "Submit"
  end
end
