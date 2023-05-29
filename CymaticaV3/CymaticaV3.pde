import beads.*;
import java.util.Arrays;
import java.util.Collections;
Player p;
void setup() {
  size(500, 500, P3D);
  p = new Player();
  surface.setResizable(true);
}

void draw() {
  p.run();
}
