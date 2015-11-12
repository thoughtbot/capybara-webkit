module Capybara
  module Webkit
    module RspecMatchers
      RSpec::Matchers.define :have_errors do |expected|
        match do |actual|
          actual = resolve(actual)
          actual.error_messages.any?
        end

        # Check that RSpec is < 2.99
        if !respond_to?(:failure_message) &&
           respond_to?(:failure_message_for_should)
          alias :failure_message :failure_message_for_should
        end

        if !respond_to?(:failure_message_when_negated) &&
           respond_to?(:failure_message_for_should_not)
          alias :failure_message_when_negated :failure_message_for_should_not
        end

        failure_message do |_actual|
          "Expected Javascript errors, but there were none."
        end

        failure_message_when_negated do |actual|
          actual = resolve(actual)
          "Expected no Javascript errors, got:\n#{error_messages_for(actual)}"
        end

        def error_messages_for(obj)
          obj.error_messages.map do |m|
            "  - #{m[:message]}"
          end.join("\n")
        end

        def resolve(actual)
          if actual.respond_to? :page
            actual.page.driver
          elsif actual.respond_to? :driver
            actual.driver
          else
            actual
          end
        end
      end
    end
  end
end
