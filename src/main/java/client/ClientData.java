package client;

import com.corundumstudio.socketio.SocketIOClient;
import entities.UserEntity;

public class ClientData {
    private SocketIOClient socket;
    private UserEntity userData;

    public ClientData(SocketIOClient socket) {
        this.socket = socket;
    }
    public ClientData(SocketIOClient socket, UserEntity userData) {
        this.socket = socket;
        this.userData = userData;
    }

    public SocketIOClient getSocket() {
        return socket;
    }

    public void setSocket(SocketIOClient socket) {
        this.socket = socket;
    }

    public UserEntity getUserData() {
        return userData;
    }

    public void setUserData(UserEntity userData) {
        this.userData = userData;
    }
}
