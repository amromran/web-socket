# frozen_string_literal: true

# require 'thread'
require 'socket'
require 'set'
require 'thread'

class Server
  attr_reader :server, :clients, :clients_lock

  PORT = 8080
  SERVER = "localhost"
  ADDR = ( SERVER, PORT=8080 )
  FORMAT = "utf-8"
  DISCONNECT_MESSAGE = "DISCONNECT!"

  server = TCPServer.new( SERVER, PORT )
  server.bind( ADDR )
  server.listen( 10 )

  clients = Set.new
  client_lock = Mutex.new

  def with_lock( lock )
    lock.synchronize
  end

  def client( conn, addr, clients, client_lock )
    puts "#{addr} Connected"
    begin
      connected = true

      while connected
        data_bytes = conn.gets&.chomp
        break if data_bytes.nil?

        msg = data_bytes.force_encoding( "UTF-8" )

        if msg == DISCONNECT_MESSAGE
          connected = false
          next
        end

        puts "#{addr} #{msg}"

        with_connection( clients_lock ) do
          clients.each do |client_conn|
            client_conn.write("#{addr} #{msg}")
          end
        end
      end

    rescue => e
      puts "Error with #{addr}: #{e.message}"
      with_lock( clients_lock ) do
        clients.delete( conn )
      end
    ensure
      conn.close
    end
  end

  def start( server, clients, clients_lock )
    puts "Server started"
    loop do
      conn = server.accept
      addr = conn.peeraddr[2] rescue "unknown"
      with_lock( clients_lock ) { clients << conn }

      Thread.new do
        client( conn, addr, clients, clients_lock )
      end
    end
  end

  start( server, clients, clients_lock )

end
