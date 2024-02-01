package server;

import client.ClientData;
import com.corundumstudio.socketio.AckRequest;
import com.corundumstudio.socketio.Configuration;
import com.corundumstudio.socketio.SocketIOClient;
import com.corundumstudio.socketio.SocketIOServer;
import com.corundumstudio.socketio.listener.ConnectListener;
import com.corundumstudio.socketio.listener.DataListener;
import com.corundumstudio.socketio.listener.DisconnectListener;
import engine.GameEngine;
import entities.UserEntity;

import java.io.Console;
import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;


public class ServerSocket {
    private static Configuration config;
    private static SocketIOServer server;
    private static ServerSocket myServer;
    private HashMap<Integer, ClientData> activePlayers = new HashMap<>();
    private Queue<ClientData> playerQueue = new ConcurrentLinkedQueue<>();
    private static HashMap<UUID, GameEngine> activeGames = new HashMap<>();

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
        setGetBoardListener();
        setSaveIdListener();
        setPlayMoveListener();
        setSendMessageListener();
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

    private void setSaveIdListener(){
        server.addEventListener("saveId", Integer.class, new DataListener<Integer>() {

            @Override
            public void onData(SocketIOClient socketIOClient, Integer userId, AckRequest ackRequest) throws Exception {
                setId(socketIOClient, userId);
            }
        });
    }

    private void setId(SocketIOClient socket, int userId){
        UserEntity u = new UserEntity();
        u.setId(userId);
        ClientData clientData = new ClientData(socket, u);
        activePlayers.put(userId, clientData);
        System.out.println("saved id " + userId);
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
        server.addEventListener("joinQueue", Integer.class, new DataListener<Integer>() {
            @Override
            public void onData(SocketIOClient socketIOClient, Integer userId, AckRequest ackRequest) throws Exception {
                joinQueue(socketIOClient, userId);
            }
        });
    }

    private void joinQueue(SocketIOClient client, Integer userId) {
        ClientData clientData = activePlayers.get(userId);
        //reset the socketId
        clientData.setSocket(client);
        activePlayers.put(userId, clientData);

        playerQueue.add(clientData);
        client.sendEvent("queueStatus", "You joined the queue. Waiting for an opponent...");
        tryMatchPlayers();
    }


    private void tryMatchPlayers() {
        if (playerQueue.size() >= 2) {
            ClientData player1 = playerQueue.poll();
            ClientData player2 = playerQueue.poll();
            startGame(player1, player2);
        }
    }

    private void startGame(ClientData player1, ClientData player2){
        UUID gameId = UUID.randomUUID();
        player1.getSocket().sendEvent("startGame", gameId);
        player2.getSocket().sendEvent("startGame", gameId);

        System.out.println("Game " + gameId + " starting between players: " + player1.getSocket().getSessionId()  + " and " + player2.getSocket().getSessionId());

        GameEngine engine = new GameEngine(gameId, player1.getUserData().getId(), player2.getUserData().getId());
        engine.GenerateBoard();
        activeGames.put(gameId, engine);
    }

    private void setGetBoardListener(){
        server.addEventListener("getBoard",  Object[].class, new DataListener<Object[]>() {
            @Override
            public void onData(SocketIOClient socketIOClient,  Object[] data, AckRequest ackRequest) throws Exception {
                UUID gameId = UUID.fromString((String) data[0]);
                Integer userId = Integer.parseInt((String)data[1]);
                sendBoard(socketIOClient, gameId, userId);
            }
        });
    }

    private void sendBoard(SocketIOClient client, UUID gameId, Integer userId){
        //reset the socketId
        ClientData clientData = activePlayers.get(userId);
        clientData.setSocket(client);
        activePlayers.put(userId, clientData);

        GameEngine engine = activeGames.get(gameId);
        String boardJson = engine.getBoardAsJSONString();
        Integer turn = engine.getTurn();
        int score1 = engine.getScore1();
        int score2 = engine.getScore2();
        Integer win = engine.checkWinner();

        SocketIOClient socket1 = activePlayers.get(engine.getPlayer1()).getSocket();
        SocketIOClient socket2 = activePlayers.get(engine.getPlayer2()).getSocket();
        socket1.sendEvent("receiveBoard", boardJson, turn, score1, score2, win);
        socket2.sendEvent("receiveBoard", boardJson, turn, score1, score2, win);

    }

    private void setPlayMoveListener(){
        server.addEventListener("playMove",  Object[].class, new DataListener<Object[]>() {

            @Override
            public void onData(SocketIOClient socketIOClient, Object[] data, AckRequest ackRequest) throws Exception {
                System.out.println("play move event received!");
                UUID gameId = UUID.fromString((String) data[0]);
                Integer userId = Integer.parseInt((String)data[1]);
                int x = (Integer) data[2];
                int y = (Integer) data[3];
                playMove(socketIOClient, gameId, userId, x, y);
            }
        });
    }

    private void playMove(SocketIOClient client, UUID gameId, Integer userId, int x, int y)
    {
        //reset the socketId
        ClientData clientData = activePlayers.get(userId);
        clientData.setSocket(client);
        activePlayers.put(userId, clientData);

        GameEngine engine = activeGames.get(gameId);
        engine.playMove(x, y, userId);

        sendBoard(client, gameId, userId);
    }

    private void setSendMessageListener(){
        server.addEventListener("sendMessage",  Object[].class, new DataListener<Object[]>() {

            @Override
            public void onData(SocketIOClient socketIOClient, Object[] data, AckRequest ackRequest) throws Exception {
                UUID gameId = UUID.fromString((String) data[0]);
                String msg = (String)data[1];
                sendMessage(gameId, msg);
            }
        });
    }

    private void sendMessage(UUID gameId, String msg)
    {
        GameEngine engine = activeGames.get(gameId);
        SocketIOClient socket1 = activePlayers.get(engine.getPlayer1()).getSocket();
        SocketIOClient socket2 = activePlayers.get(engine.getPlayer2()).getSocket();
        socket1.sendEvent("appendMessage", msg);
        socket2.sendEvent("appendMessage", msg);
    }
}
