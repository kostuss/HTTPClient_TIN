require_relative 'HTTPClient'

if __FILE__ == $0
  client=HTTPClient.new
  client.startClient
end