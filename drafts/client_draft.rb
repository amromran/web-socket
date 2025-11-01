require 'socket'
require 'date'

PORT = 8080
SERVER = "localhost"
ADDR = ( SERVER, PORT=8080 )
FORMAT = "utf-8"
DISCONNECT_MESSAGE = "DISCONNECT!"

def connect
	#client = TCPSocket.new(hostname, port)
	client = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM)
	client.connect( ADDR )
	return client
end

def send
	response = get.chomp("Connect? (yes/no)")
	if answer.lower != 'yes'
		return
		
	connection = connect
	while true
		msg = get.chomp("Press (q to quit): ")
		
		if msg == 'q'
			break
			
		send(connection, msg)
		
	send(connection, msg)
	time.sleep(2)
	print('DISCONNECTED')
end