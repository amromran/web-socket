require 'socket'
require 'date'

PORT = 8080
SERVER = "localhost"

DISCONNECT_MESSAGE = "DISCONNECT"

def connect
    client = TCPSocket.new(SERVER, PORT)
    return client
rescue Errno::ECONNREFUSED => e
    puts "Error: Connection refused. Ensure the server is running on #{SERVER}:#{PORT}."
    exit
end


def send_message(connection, msg)
    connection.puts msg
end


def start_client
    print("Connect? (yes/no): ")
    response = gets.chomp

    unless response.downcase == 'yes'
        puts "Shutdown."
        return
    end

    connection = connect
    puts "Connected to #{SERVER}:#{PORT}."

    while true
        print("Your message (or 'q' to quit): ")
        msg = gets.chomp

        if msg.downcase == 'q'
            send_message(connection, DISCONNECT_MESSAGE) 
            break
        end

        send_message(connection, msg)
        
        sleep(0.5) 
    end

rescue => e
    puts "An unexpected error occurred: #{e.message}"
		
ensure
    if connection
        connection.close 
        puts "DISCONNECTED"
    end
end

start_client