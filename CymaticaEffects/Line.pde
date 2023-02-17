class HorizLine{
  float yPos = height;
  float xPos = random(width);
  color col;
  float speed = random(5,50);
  PGraphics p;
  HorizLine(PGraphics img){
    p = img;
    yPos = height;
    xPos = random(width);
    col = color(random(128, 255), random(128), random(128));
  }
  void drawLine(){
    p.beginDraw();
    int length = int(map(speed,5,50,50,150));
    for (int i = 0; i < length; i++) {
      color l1 = lerpColor(color(255),col,0.5);
      p.stroke(lerpColor(l1,col,map(i,0,length,0,1)));
      p.strokeWeight(map(i,0,length,10,1));
      p.point(xPos, yPos+i);
    }
    yPos -= speed;
    p.endDraw();
  }
}
