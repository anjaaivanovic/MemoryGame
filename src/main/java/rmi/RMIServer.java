package rmi;

import java.net.MalformedURLException;
import java.rmi.Naming;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;

public class RMIServer {
    public static void main(String[] args) {
        try {
            LeaderboardRMI leaderboard = new LeaderboardRMI();
            LocateRegistry.createRegistry(1111);
            System.out.println("RMI Server started on //localhost:1111/LeaderboardRMI");
            Naming.rebind("//localhost:1111/LeaderboardRMI", leaderboard);
        } catch (RemoteException | MalformedURLException e) {
            e.printStackTrace();
        }
    }
}

