require 'socket'
require 'set'
require 'thread'

class Server
  attr_reader :server, :clients, :clients_lock

  PORT = 8080
  SERVER = 'localhost'
  DISCONNECT_MESSAGE = "DISCONNECT"

  def initialize( host = SERVER, port = PORT )
    @server = TCPServer.new(host, port)
    @clients = Set.new
    @clients_lock = Mutex.new
  end

  def with_lock( lock )
    lock.synchronize { yield }
  end

  def client( conn, addr )
    puts "#{addr} connected"
    begin
      loop do
        msg = conn.gets&.chomp
        break if msg.nil? || msg == DISCONNECT_MESSAGE

        puts "#{addr}: #{msg}"

        # Broadcast to all connected clients
        with_lock( @clients_lock ) do
          @clients.each do |client_conn|
            next if client_conn == conn
            client_conn.puts("#{addr}: #{msg}")
          end
        end
      end
    rescue => e
      puts "Error with #{addr}: #{e.message}"
    ensure
      with_lock(@clients_lock) { @clients.delete(conn) }
      conn.close
      puts "#{addr} disconnected"
    end
  end

  def start
    puts "Server started on #{@server.addr[2]}:#{@server.addr[1]}"
    loop do
      conn = @server.accept
      addr = conn.peeraddr[2] rescue "unknown"
      with_lock( @clients_lock ) { @clients << conn }

      Thread.new do
        client(conn, addr)
      end
    end
  end
end

Server.new.start