package client;

import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;

import java.net.URISyntaxException;

public class ClientSocket {
    private final Socket socket;

    public ClientSocket() throws URISyntaxException {
        socket = IO.socket("http://localhost:5678");

        socket.on(Socket.EVENT_CONNECT, args -> onConnect());
        socket.on(Socket.EVENT_DISCONNECT, args -> onDisconnect());

    }

    private void onConnect() { System.out.println("Connection established!"); }
    private void onDisconnect() { System.out.println("Connection ended!"); }
    public void connect() { socket.connect(); }
    public void disconnect() { socket.disconnect(); }
}
