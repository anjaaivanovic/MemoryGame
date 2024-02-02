package rmi;

import com.example.projekat.Database;
import entities.UserEntity;
import jakarta.persistence.EntityManager;

import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;
import java.util.List;

public class LeaderboardRMI extends UnicastRemoteObject implements ILeaderboardRMI {

    protected LeaderboardRMI() throws RemoteException {
        super();
    }

    @Override
    public String getLeaderboard() {
        EntityManager em = Database.getConnection();
        String sql = "select * from users where roleId <> 2 order by (CAST(gamesPlayed AS DECIMAL(10, 2)) / NULLIF(CAST(gamesWon AS DECIMAL(10, 2)), 0)) limit 10";
        List<UserEntity> leaderboard = em.createNativeQuery(sql, UserEntity.class).getResultList();

        String leaderboardStr = "<table class='table'>" +
                "<thead class='thead-dark'>" +
                "<tr>" +
                "<th scope='col'>Place</th>" +
                "<th scope='col'>Username</th>" +
                "<th scope='col'>Rank</th>" +
                "<th scope='col'>Stats</th>" +
                "</tr></thead>" +
                "<tbody>";

        int i = 1;
        for (UserEntity u: leaderboard){
            String urank = "-";
            if (u.getRank() != null) urank = u.getRank();
            leaderboardStr += "<tr>" +
                    "<td>"+ i + ".</td>" +
                    "<td>"+ u.getUsername() + "</td>" +
                    "<td>"+ urank + "</td>" +
                    "<td>"+ u.getGamesWon()+ " / " + u.getGamesPlayed() + "</td>" +
                    "</tr>";
            i++;
        }

        leaderboardStr += "</tbody></table>";
        return leaderboardStr;
    }
}
