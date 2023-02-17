class BezierTrail {
  PVector start;
  PVector end;
  PVector control1;
  PVector control2;
  color col;
  int counter;
  PGraphics p;
  BezierTrail(PGraphics img) {
    p = img;
    start = new PVector(random(width), height);
    end = new PVector(random(width), 0);
    control1 = new PVector(random(width), random(height));
    control2 = new PVector(random(width), random(height));
    col = color(random(128, 255), random(128), random(128));
  }

  void follow() {
    p.beginDraw();
    p.noFill();
    p.strokeCap(ROUND);
    int length = int(map(noise(counter/1000),0,1,50,150));
    for (int i = 0; i < length; i++) {
      color l1 = lerpColor(color(255),col,0.5);
      p.stroke(lerpColor(l1,col,map(i,0,length,0,1)));
      p.strokeWeight(map(i,0,length,5,1));
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
}
