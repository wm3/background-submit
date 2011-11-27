require 'rack'

class MockServer

  def call(env)
    req = Rack::Request.new(env)

    case env['PATH_INFO']
    when '/'
      [200, {'Content-Type' => 'text/html'}, [MockServer.html]]
    when '/script.js'
      [200, {'content-type' => 'text/javascript'}, [MockServer.script]]
    when '/submit'
      data = req.params.to_hash
      MockServer.listener.submit(data) if MockServer.listener

      [200, {'content-type' => 'text/plain'}, [data.to_json]]
    else
      raise "Unrecognized option: #{env}"
    end
  end

end

class << MockServer
  attr_accessor :script, :head, :body, :listener

  def listener=(listener)
    @listener = listener
  end

  def html
    "<!doctype html><html><head>#{script_tag}#{head}</head><body>#{body}</body></html>"
  end

  def script_tag
    script ? '<script src="script.js"></script>' : ''
  end
end

# vim: set shiftwidth=2 expandtab :
