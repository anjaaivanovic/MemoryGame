package entities;

import jakarta.persistence.*;

@Entity
@Table(name = "users", schema = "memorygame")
public class UserEntity {
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Id
    @Column(name = "id")
    private int id;
    @Basic
    @Column(name = "username")
    private String username;
    @Basic
    @Column(name = "password")
    private String password;
    @Basic
    @Column(name = "passwordSalt")
    private String passwordSalt;
    @Basic
    @Column(name = "gamesPlayed")
    private int gamesPlayed;
    @Basic
    @Column(name = "gamesWon")
    private int gamesWon;
    @Basic
    @Column(name = "roleId")
    private int roleId;
    @Basic
    @Column(name = "playerRank")
    private String rank;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getPasswordSalt() { return passwordSalt; }

    public void setPasswordSalt(String passwordSalt) { this.passwordSalt = passwordSalt; }

    public int getGamesPlayed() {
        return gamesPlayed;
    }

    public void setGamesPlayed(int gamesPlayed) {
        this.gamesPlayed = gamesPlayed;
    }

    public int getGamesWon() {
        return gamesWon;
    }

    public void setGamesWon(int gamesWon) {
        this.gamesWon = gamesWon;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getRank() {
        return rank;
    }

    public void setRank(String rank) {
        this.rank = rank;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        UserEntity that = (UserEntity) o;

        if (id != that.id) return false;
        if (gamesPlayed != that.gamesPlayed) return false;
        if (gamesWon != that.gamesWon) return false;
        if (roleId != that.roleId) return false;
        if (username != null ? !username.equals(that.username) : that.username != null) return false;
        if (password != null ? !password.equals(that.password) : that.password != null) return false;
        if (rank != null ? !rank.equals(that.rank) : that.rank != null) return false;

        return true;
    }

    @Override
    public int hashCode() {
        int result = id;
        result = 31 * result + (username != null ? username.hashCode() : 0);
        result = 31 * result + (password != null ? password.hashCode() : 0);
        result = 31 * result + gamesPlayed;
        result = 31 * result + gamesWon;
        result = 31 * result + roleId;
        result = 31 * result + (rank != null ? rank.hashCode() : 0);
        return result;
    }
}
