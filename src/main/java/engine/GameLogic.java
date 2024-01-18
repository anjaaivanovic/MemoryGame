package engine;

import java.util.ArrayList;
import java.util.Random;

public class GameLogic {

    private int rows = 5;
    private int columns = 6;
    private Card[][] board;

    private int player = 1;
    private int score1 = 0;
    private int score2 = 0;

    private Card first;
    private Card second;

    public void GenerateBoard(){
        board = new Card[rows][columns];
        Random rand = new Random();
        ArrayList<Integer> list = new ArrayList<>();

        for (int i = 0; i < rows * columns / 2; i++){
            list.add(i);
            list.add(i);
        }

        for (int i = 0; i < rows; i++){
            for (int j = 0; j < columns; j++){
                int randomizedIndex = rand.nextInt(list.size());
                board[i][j] = new Card(list.remove(randomizedIndex), false);
            }
        }
    }

    public int checkWinner(){
        if (score1 + score2 == 15){
            if (score1 > score2) return 1;
            return 2;
        }
        return 0;
    }
    public boolean playMove(int x, int y){
        if (board[x][y].visible){
            board[x][y].visible = true;

            if (first != null && second != null){
                if (first.value != second.value){
                    first.visible = false;
                    second.visible = false;
                }
                else{
                    if (player == 1) score1++;
                    else score2++;
                }

                first = board[x][y];
                second = null;
            }
            else if (first == null){
                first = board[x][y];
            }
            else{
                second = board[x][y];
                if (player == 1 && score1 == 14) score1 = 15;
                else if (player == 2 && score2 == 14) score2 = 15;
            }

            return true;
        }
        return false;
    }
}
