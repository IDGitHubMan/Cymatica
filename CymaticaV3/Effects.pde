class BezierTrail {
  PVector start;
  PVector end;
  PVector control1;
  PVector control2;
  color col;
  int counter;
  PGraphics p;
  BezierTrail(color c1, color c2) {
    start = new PVector(random(width), height);
    end = new PVector(random(width), -100);
    control1 = new PVector(random(width), random(height));
    control2 = new PVector(random(width), random(height));
    col = lerpColor(c1, c2, random(1));
  }

  void follow(PGraphics p) {
    p.beginDraw();
    p.noFill();
    p.strokeCap(ROUND);
    int length = int(map(noise(counter/1000), 0, 1, 50, 150));
    for (int i = 0; i < length; i++) {
      color l1 = lerpColor(color(255), col, 0);
      p.stroke(lerpColor(l1, col, map(i, 0, length, 0, 1)));
      p.strokeWeight(map(i, 0, length, 5, 1));
      float t = map(counter-i, 0, height, 0, 1);
      float blend1 = pow(1-t, 3);
      float blend2 = 3*t*pow(1-t, 2);
      float blend3 = 3*pow(t, 2)*(1-t);
      float blend4 = pow(t, 3);
      float x = blend1*start.x+blend2*control1.x+blend3*control2.x+blend4*end.x;
      float y = blend1*start.y+blend2*control1.y+blend3*control2.y+blend4*end.y;
      p.point(x, y);
    }
    //bezier(start.x,start.y,control1.x,control1.y,control2.x,control2.y,end.x,end.y);
    counter += 10;
    p.endDraw();
  }

  void follow() {
    noFill();
    strokeCap(ROUND);
    int length = int(map(noise(counter/1000), 0, 1, 50, 150));
    for (int i = 0; i < length; i++) {
      color l1 = lerpColor(color(255), col, 0);
      stroke(lerpColor(l1, col, map(i, 0, length, 0, 1)));
      strokeWeight(map(i, 0, length, 5, 1));
      float t = map(counter-i, 0, height, 0, 1);
      float blend1 = pow(1-t, 3);
      float blend2 = 3*t*pow(1-t, 2);
      float blend3 = 3*pow(t, 2)*(1-t);
      float blend4 = pow(t, 3);
      float x = blend1*start.x+blend2*control1.x+blend3*control2.x+blend4*end.x;
      float y = blend1*start.y+blend2*control1.y+blend3*control2.y+blend4*end.y;
      point(x, y);
    }
    //bezier(start.x,start.y,control1.x,control1.y,control2.x,control2.y,end.x,end.y);
    counter += 10;
  }
}

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
    float m = (p1.y-p2.y)/(p1.x-p2.x);
    strokeCap(ROUND);
    strokeWeight(constrain(map(timer, 0, 15, 50, 0), 0, 50));
    stroke(255, 0, 128, constrain(map(timer, 0, 15, 255, 0), 0, 255));
    line(p1.x, p1.y, p2.x, p2.y);
    timer+=1;
  }

  void beam(PGraphics p){
    p.beginDraw();
    float m = (p1.y-p2.y)/(p1.x-p2.x);
    p.strokeCap(ROUND);
    p.strokeWeight(constrain(map(timer, 0, 15, 50, 0), 0, 50));
    p.stroke(255, 0, 128, constrain(map(timer, 0, 15, 255, 0), 0, 255));
    p.line(p1.x, p1.y, p2.x, p2.y);
    p.endDraw();
    timer+=1;
  }
}

class HorizLine {
  float yPos = height;
  float xPos = random(width);
  color col;
  float speed = random(5, 50);
  HorizLine(color c1, color c2) {
    yPos = height;
    xPos = random(width);
    col = lerpColor(c1, c2, random(1));
  }
  void drawLine() {
    int length = int(map(speed, 5, 50, 50, 150));
    for (int i = 0; i < length; i++) {
      color l1 = lerpColor(color(255), col, 0);
      stroke(lerpColor(l1, col, map(i, 0, length, 0, 1)));
      strokeWeight(map(i, 0, length, 10, 1));
      point(xPos, yPos+i);
    }
    yPos -= speed;
  }
  void drawLine(PGraphics p){
    p.beginDraw();
    int length = int(map(speed, 5, 50, 50, 150));
    for (int i = 0; i < length; i++) {
      color l1 = lerpColor(color(255), col, 0);
      p.stroke(lerpColor(l1, col, map(i, 0, length, 0, 1)));
      p.strokeWeight(map(i, 0, length, 10, 1));
      p.point(xPos, yPos+i);
    }
    yPos -= speed;
    p.endDraw();
  }
}
