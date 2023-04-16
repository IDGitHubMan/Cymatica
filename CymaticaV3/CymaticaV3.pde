import beads.*;
import java.util.Arrays; 
import java.util.Collections;
Player p;
void setup() {
    size(500,500,P3D);
    p = new Player(this);
    surface.setResizable(true);
}

void draw() {
    background(0);
    p.run();
}