begin
  connected = true
  while connected
    data_bytes = conn.read(1024)
    msg = data_bytes.force_encoding("UTF-8")
    unless msg
      break

      if msg == DISCONNECT_MESSAGE
        connected = false

        puts "#{addr} #{msg}"

        with_connection do |c|
          for c in clients
            c.write( "#{addr} #{msg}" )
            rescue =>
              with_connection(clients_lock)