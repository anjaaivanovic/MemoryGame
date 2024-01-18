package rmi;

import java.rmi.Remote;
import java.rmi.RemoteException;

public interface ILeaderboardRMI extends Remote {
    public String  getLeaderboard() throws RemoteException;
}
