package engine;

import java.io.Serializable;

public class Card implements Serializable {
    int value;
    boolean visible;

    public Card(int value, boolean visible) {
        this.value = value;
        this.visible = visible;
    }
}
