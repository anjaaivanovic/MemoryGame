package server;

import client.ClientData;
import com.corundumstudio.socketio.AckRequest;
import com.corundumstudio.socketio.Configuration;
import com.corundumstudio.socketio.SocketIOClient;
import com.corundumstudio.socketio.SocketIOServer;
import com.corundumstudio.socketio.listener.ConnectListener;
import com.corundumstudio.socketio.listener.DataListener;
import com.corundumstudio.socketio.listener.DisconnectListener;

import java.util.EventListener;
import java.util.Queue;
import java.util.UUID;
import java.util.concurrent.ConcurrentLinkedQueue;

public class ServerSocket {
    private static Configuration config;
    private static SocketIOServer server;
    private static ServerSocket myServer;
    private Queue<ClientData> playerQueue = new ConcurrentLinkedQueue<>();

    private void configure(){
        config = new Configuration();
        config.setHostname("localhost");
        config.setPort(5678);
    }

    private ServerSocket(){
        configure();
        server = new SocketIOServer(config);
        setConnectListener();
        setDisconnectListener();
        setQueueListener();
        server.start();
        System.out.println("Server started on http://localhost:5678");
    }

    private static final Object lock = new Object();
    public static void startServer(){
        if(server == null) {
            synchronized (lock){
                if(server == null)
                    myServer = new ServerSocket();
            }
        }
    }

    private void setConnectListener(){
        server.addConnectListener(new ConnectListener() {

            @Override
            public void onConnect(SocketIOClient socketIOClient) {
                System.out.println("Client connected: " + socketIOClient.getSessionId());
            }
        });
    }

    private void setDisconnectListener(){
        server.addDisconnectListener(new DisconnectListener() {
            @Override
            public void onDisconnect(SocketIOClient socketIOClient) {
                System.out.println("Client disconnected: " + socketIOClient.getSessionId());
            }
        });
    }

    private void setQueueListener(){
        server.addEventListener("joinQueue", UUID.class, new DataListener<UUID>() {
            @Override
            public void onData(SocketIOClient socketIOClient, UUID uuid, AckRequest ackRequest) throws Exception {
                joinQueue(socketIOClient);
            }
        });
    }

    private void joinQueue(SocketIOClient client) {
        playerQueue.add(new ClientData(client));
        client.sendEvent("queueStatus", "You are in the queue. Waiting for an opponent.");
        tryMatchPlayers();
    }

    private void tryMatchPlayers() {
        if (playerQueue.size() >= 2) {
            ClientData player1 = playerQueue.poll();
            ClientData player2 = playerQueue.poll();

            UUID gameId = UUID.randomUUID();
            startGame(gameId, player1, player2);
        }
    }

    private void startGame(UUID gameId, ClientData player1, ClientData player2){
        player1.getSocket().sendEvent("startGame", gameId);
        player2.getSocket().sendEvent("startGame", gameId);

        System.out.println("Game " + gameId + " starting between players: " + player1.getSocket().getSessionId()  + " and " + player2.getSocket().getSessionId());
    }
}
