class LaserLine {
  int timer;
  PVector p1;
  PVector p2;
  PGraphics p;
  LaserLine(PGraphics img) {
    p = img;
    timer = 0;
    float lineType = random(2);
    if (lineType<1) {
      p1 = new PVector(random(width), 0);
      p2 = new PVector(random(width), height);
    } else if (lineType<2) {
      p1 = new PVector(0, random(height));
      p2 = new PVector(width, random(height));
    }
  }

  void beam() {
    p.beginDraw();
    float m = (p1.y-p2.y)/(p1.x-p2.x);
    p.strokeCap(ROUND);
    p.strokeWeight(constrain(map(timer,0,15,50,0),0,50));
    p.stroke(255, 0, 128,constrain(map(timer,0,15,255,0),0,255));
    p.line(p1.x, p1.y, p2.x, p2.y);
    p.endDraw();
    timer+=1;
  }
}
