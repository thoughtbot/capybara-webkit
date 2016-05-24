shared_examples_for "output writer" do
  before do
    @read, @write = IO.pipe
    configure { |config| config.stderr = @write }
    fork_connection
  end

  let(:stderr) do
    @write.close
    @read.read
  end
end
