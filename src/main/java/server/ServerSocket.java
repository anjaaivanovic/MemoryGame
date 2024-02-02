package server;

import com.corundumstudio.socketio.AckRequest;
import com.corundumstudio.socketio.Configuration;
import com.corundumstudio.socketio.SocketIOClient;
import com.corundumstudio.socketio.SocketIOServer;
import com.corundumstudio.socketio.listener.ConnectListener;
import com.corundumstudio.socketio.listener.DataListener;
import com.corundumstudio.socketio.listener.DisconnectListener;
import engine.GameEngine;

import java.util.*;


public class ServerSocket {
    private static Configuration config;
    private static SocketIOServer server;
    private static ServerSocket myServer;
    private HashMap<Integer, SocketIOClient> activePlayers;
    private HashMap<Integer, SocketIOClient> playerQueue;
    private HashMap<UUID, GameEngine> activeGames;

    private void configure(){
        config = new Configuration();
        config.setHostname("localhost");
        config.setPort(5678);
    }

    private ServerSocket(){
        configure();
        server = new SocketIOServer(config);
        activePlayers = new HashMap<>();
        playerQueue = new HashMap<>();
        activeGames = new HashMap<>();
        setConnectListener();
        setDisconnectListener();
        setQueueListener();
        setGetBoardListener();
        setSaveIdListener();
        setPlayMoveListener();
        setSendMessageListener();
        setActiveAndQueuedListener();
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

    private void broadcastPlayerState(String event, int activePlayers, int queuedPlayers)
    {
        var clients = this.activePlayers.values();
        for (var client: clients) {
            client.sendEvent(event, activePlayers, queuedPlayers);
        }
    }
    private void setId(SocketIOClient socket, int userId){
        activePlayers.put(userId, socket);
        System.out.println("saved id " + userId);
        broadcastPlayerState("receiveActiveAndQueued", activePlayers.size(), playerQueue.size());
    }

    private void setDisconnectListener(){
        server.addDisconnectListener(new DisconnectListener() {
            @Override
            public void onDisconnect(SocketIOClient socketIOClient) {
                activePlayers.entrySet().removeIf(player -> player.getValue().getSessionId().equals(socketIOClient.getSessionId()));
                playerQueue.entrySet().removeIf(player -> player.getValue().getSessionId().equals(socketIOClient.getSessionId()));
                broadcastPlayerState("receiveActiveAndQueued", activePlayers.size(), playerQueue.size());
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
        //reset the socketId
        activePlayers.put(userId, client);

        playerQueue.put(userId, client);
        client.sendEvent("queueStatus", "You joined the queue. Waiting for an opponent...");
        broadcastPlayerState("receiveActiveAndQueued", activePlayers.size(), playerQueue.size());
        tryMatchPlayers();
    }


    private void tryMatchPlayers() {
        if (playerQueue.size() >= 2) {
            Iterator<Map.Entry<Integer, SocketIOClient>> iterator = activePlayers.entrySet().iterator();
            Map.Entry<Integer, SocketIOClient> p1 = iterator.next();
            Map.Entry<Integer, SocketIOClient> p2 = iterator.next();

            Integer id1 = p1.getKey();
            Integer id2 = p2.getKey();
            SocketIOClient player1 = p1.getValue();
            SocketIOClient player2 = p2.getValue();
            startGame(player1, player2, id1, id2);
        }
    }

    private void startGame(SocketIOClient player1, SocketIOClient player2, Integer id1, Integer id2){
        UUID gameId = UUID.randomUUID();
        player1.sendEvent("startGame", gameId);
        player2.sendEvent("startGame", gameId);

        System.out.println("Game " + gameId + " starting between players: " + player1.getSessionId()  + " and " + player2.getSessionId());

        GameEngine engine = new GameEngine(gameId, id1, id2);
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
        activePlayers.put(userId, client);

        GameEngine engine = activeGames.get(gameId);
        String boardJson = engine.getBoardAsJSONString();
        Integer turn = engine.getTurn();
        int score1 = engine.getScore1();
        int score2 = engine.getScore2();
        Integer win = engine.checkWinner();

        if (win != 0)
        {
            activeGames.remove(gameId);
            System.out.println("Game #" + gameId + " finished! Ongoing games:");
            for (var game:activeGames.keySet()) { System.out.println(game);}
        }
        SocketIOClient socket1 = activePlayers.get(engine.getPlayer1());
        SocketIOClient socket2 = activePlayers.get(engine.getPlayer2());
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
        activePlayers.put(userId, client);

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
        SocketIOClient socket1 = activePlayers.get(engine.getPlayer1());
        SocketIOClient socket2 = activePlayers.get(engine.getPlayer2());
        socket1.sendEvent("appendMessage", msg);
        socket2.sendEvent("appendMessage", msg);
    }

    private void setActiveAndQueuedListener(){
        server.addEventListener("getActiveAndQueued", Object.class, new DataListener<>() {
            @Override
            public void onData(SocketIOClient socketIOClient, Object o, AckRequest ackRequest) throws Exception {
                socketIOClient.sendEvent("receiveActiveAndQueued", activePlayers.size(), playerQueue.size());
            }
        });
    }
}
