RSpec::Matchers.define :include_response do |expected_response|
  read_timeout = 2
  read_bytes = 4096
  response = ""

  match do |read_io|
    found_response = false

    while !found_response && IO.select([read_io], nil, nil, read_timeout) do
      response += read_io.read_nonblock(read_bytes)
      found_response = if expected_response.is_a? Regexp
        response.match(expected_response)
      else
        response.include?(expected_response)
      end
    end

    found_response
  end

  send(respond_to?(:failure_message) ? :failure_message : :failure_message_for_should) do |actual|
    "expected #{response} to include #{expected_response}"
  end

  send(respond_to?(:failure_message_when_negated) ? :failure_message_when_negated : :failure_message_for_should_not) do |actual|
    "expected #{response} to not include #{expected_response}"
  end
end
