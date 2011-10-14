require 'socket'
require 'thread'
require 'capybara/util/timeout'
require 'json'

class Capybara::Driver::Webkit
  class Browser
    attr :server_port

    def initialize(options = {})
      @socket_class = options[:socket_class] || TCPSocket
      @stdout       = options.has_key?(:stdout) ?
                        options[:stdout] :
                        $stdout
      @ignore_ssl_errors = options[:ignore_ssl_errors]
      start_server
      connect
    end

    def visit(url)
      command "Visit", url
    end

    def header(key, value)
      command("Header", key, value)
    end

    def find(query)
      command("Find", query).split(",")
    end

    def reset!
      command("Reset")
    end

    def body
      command("Body")
    end

    def source
      command("Source")
    end

    def status_code
      command("Status").to_i
    end

    def response_headers
      Hash[command("Headers").split("\n").map { |header| header.split(": ") }]
    end

    def url
      command("Url")
    end

    def frame_focus(frame_id_or_index=nil)
      if frame_id_or_index.is_a? Fixnum
        command("FrameFocus", "", frame_id_or_index.to_s)
      elsif frame_id_or_index
        command("FrameFocus", frame_id_or_index)
      else
        command("FrameFocus")
      end
    end

    def command(name, *args)
      @socket.puts name
      @socket.puts args.size
      args.each do |arg|
        @socket.puts arg.to_s.bytesize
        @socket.print arg.to_s
      end
      check
      read_response
    end

    def evaluate_script(script)
      json = command('Evaluate', script)
      JSON.parse("[#{json}]").first
    end

    def execute_script(script)
      command('Execute', script)
    end

    def render(path, width, height)
      command "Render", path, width, height
    end

    def set_cookie(cookie)
      command "SetCookie", cookie
    end

    def clear_cookies
      command "ClearCookies"
    end

    def get_cookies
      command("GetCookies").lines.map{ |line| line.strip }.select{ |line| !line.empty? }
    end

    def set_proxy(options = {})
      options = default_proxy_options.merge(options)
      command("SetProxy", options[:host], options[:port], options[:user], options[:pass])
    end

    def clear_proxy
      command("SetProxy")
    end

    private

    def start_server
      pipe = fork_server
      @server_port = discover_server_port(pipe)
      @stdout_thread = Thread.new do
        Thread.current.abort_on_exception = true
        forward_stdout(pipe)
      end
    end

    def fork_server
      server_path = File.expand_path("../../../../../bin/webkit_server", __FILE__)
      pipe, @pid = server_pipe_and_pid(server_path)
      register_shutdown_hook
      pipe
    end

    def register_shutdown_hook
      @owner_pid = Process.pid
      at_exit do
        if Process.pid == @owner_pid
          Process.kill("INT", @pid)
        end
      end
    end

    def server_pipe_and_pid(server_path)
      cmdline = [server_path]
      cmdline << "--ignore-ssl-errors" if @ignore_ssl_errors
      pipe = IO.popen(cmdline.join(" "))
      [pipe, pipe.pid]
    end

    def discover_server_port(read_pipe)
      return unless IO.select([read_pipe], nil, nil, 10)
      ((read_pipe.first || '').match(/listening on port: (\d+)/) || [])[1].to_i
    end

    def forward_stdout(pipe)
      while pipe_readable?(pipe)
        line = pipe.readline
        if @stdout
          @stdout.write(line)
          @stdout.flush
        end
      end
    rescue EOFError
    end

    if !defined?(RUBY_ENGINE) || (RUBY_ENGINE == "ruby" && RUBY_VERSION <= "1.8")
      # please note the use of IO::select() here, as it is used specifically to
      # preserve correct signal handling behavior in ruby 1.8.
      # https://github.com/thibaudgg/rb-fsevent/commit/d1a868bf8dc72dbca102bedbadff76c7e6c2dc21
      # https://github.com/thibaudgg/rb-fsevent/blob/1ca42b987596f350ee7b19d8f8210b7b6ae8766b/ext/fsevent/fsevent_watch.c#L171
      def pipe_readable?(pipe)
        IO.select([pipe])
      end
    else
      def pipe_readable?(pipe)
        !pipe.eof?
      end
    end

    def connect
      Capybara.timeout(5) do
        attempt_connect
        !@socket.nil?
      end
    end

    def attempt_connect
      @socket = @socket_class.open("127.0.0.1", @server_port)
    rescue Errno::ECONNREFUSED
    end

    def check
      result = @socket.gets
      result.strip! if result

      if result.nil?
        raise WebkitNoResponseError, "No response received from the server."
      elsif result != 'ok' 
        raise WebkitInvalidResponseError, read_response
      end

      result
    end

    def read_response
      response_length = @socket.gets.to_i
      response = @socket.read(response_length)
      response.force_encoding("UTF-8") if response.respond_to?(:force_encoding)
      response
    end

    def default_proxy_options
      {
        :host => "localhost",
        :port => "0",
        :user => "",
        :pass => ""
      }
    end
  end
end
