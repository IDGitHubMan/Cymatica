import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

PGraphics actual;
ArrayList<BezierTrail> bts = new ArrayList<BezierTrail>();
ArrayList<LaserLine> las = new ArrayList<LaserLine>();
ArrayList<HorizLine> hTrails = new ArrayList<HorizLine>();
int timeSinceLastB = 0;
int timeSinceLastL = 0;
int timeSinceLastH = 0;
Minim minim;
AudioPlayer s;
FFT fftl, fftr, fftm;
AudioMetaData meta;

void setup() {
  textSize(1000);
  fullScreen(P3D);
  minim = new Minim(this);
  actual = createGraphics(width,height);
  s = minim.loadFile("1-02 Massif.mp3", 4096);
  fftl = new FFT( s.bufferSize(), s.sampleRate() );
  fftr = new FFT( s.bufferSize(), s.sampleRate() );
  fftm = new FFT( s.bufferSize(), s.sampleRate() );
  fftm.noAverages();
  fftl.noAverages();
  fftr.noAverages();
  meta = s.getMetaData();
  println(meta.length());
  s.play();
  s.setGain(-40);
}

void draw() {
  if (!s.isPlaying()){
    s.play(0);
  }
  fill(0);
  noStroke();
  rect(0,0,width,height);
  actual.beginDraw();
  actual.strokeWeight(1);
  actual.background(0);
  //line(0,height/2+50,width,height/2+50);
  actual.stroke(255);
  fftl.forward(s.left);
  fftr.forward(s.right);
  fftm.forward(s.mix);
  
  for (int i = 0; i < s.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, s.bufferSize(), 0, width );
    float x2 = map( i+1, 0, s.bufferSize(), 0, width );
    actual.stroke(0, 255,  255);
    actual.line( x1, height/9 + s.left.get(i)*50, x2, height/9 + s.left.get(i+1)*50 );
    actual.stroke(255, 0, 0);
    actual.line( x1, height/9 + s.right.get(i)*50, x2, height/9 + s.right.get(i+1)*50 );
    actual.stroke(255);
    actual.line( x1, height/9 + s.mix.get(i)*50, x2, height/9 + s.mix.get(i+1)*50 );
  }
  for (int i = 0; i < width; i++)
  {
    actual.stroke(0, 255,  255);
    actual.line( i, height/2+fftl.getBand(i) * (float) Math.log(i+2)/9, i, height/2-fftl.getBand(i) * (float) Math.log(i+2)/9 );
    actual.stroke(255, 0, 0);
    actual.line( i, height/2+fftr.getBand(i) * (float) Math.log(i+2)/9, i, height/2-fftr.getBand(i) * (float) Math.log(i+2)/9 );
    actual.stroke(255);
    actual.line( i, height/2+fftm.getBand(i) * (float) Math.log(i+2)/9, i, height/2-fftm.getBand(i) * (float) Math.log(i+2)/9 );
  }

  actual.noFill();
  actual.stroke(0, 255,  255);
  actual.ellipse(width/2, height/2, map(s.left.level(), 0, 1, 0, height), map(s.left.level(), 0, 1, 0, height));
  actual.stroke(255, 0, 0);
  actual.ellipse(width/2, height/2, map(s.right.level(), 0, 1, 0, height), map(s.right.level(), 0, 1, 0, height));
  actual.stroke(255);
  actual.ellipse(width/2, height/2, map(s.mix.level(), 0, 1, 0, height), map(s.mix.level(), 0, 1, 0, height));

  actual.stroke(0,255,255);
  actual.ellipse(width/2, height/9*8, map(s.left.level(), 0, 1, 0, height), map(s.left.level(), 0, 1, 0, height));
  actual.ellipse(width/2, height/9, map(s.left.level(), 0, 1, 0, height), map(s.left.level(), 0, 1, 0, height));
  actual.ellipse(width/4, height/2, map(s.left.level(), 0, 1, 0, height), map(s.left.level(), 0, 1, 0, height));
  actual.ellipse(width/4*3, height/2, map(s.left.level(), 0, 1, 0, height), map(s.left.level(), 0, 1, 0, height));

  actual.stroke(255, 0, 0);
  actual.ellipse(width/4, height/9*8, map(s.right.level(), 0, 1, 0, height), map(s.right.level(), 0, 1, 0, height));
  actual.ellipse(width/4*3, height/9, map(s.right.level(), 0, 1, 0, height), map(s.right.level(), 0, 1, 0, height));
  actual.ellipse(width/4, height/9, map(s.right.level(), 0, 1, 0, height), map(s.right.level(), 0, 1, 0, height));
  actual.ellipse(width/4*3, height/9*8, map(s.right.level(), 0, 1, 0, height), map(s.right.level(), 0, 1, 0, height));
  
  actual.endDraw();
  //if (millis()-timeSinceLastB>50) {
  //  timeSinceLastB = millis();
  //  for (int i = 200; i < width/2; i++) {
  //    if (fftm.getBand(i)*(float)Math.log(i+2)/9>=15) {
  //      BezierTrail bez = new BezierTrail(actual);
  //      bts.add(bez);
  //      break;
  //    }
  //  }
  //}
  //for (int i = 0; i < bts.size();i++) {
  //  if ((bts.get(i).counter>height+150)) {
  //    bts.remove(i);
  //  }
  //}
  //for (BezierTrail b:bts){
  //  b.follow();
  //}
  
  if (millis()-timeSinceLastL>375) {
    timeSinceLastL = millis();
    int count = 0;
    for (int i = 0; i < 10; i++) {
      if (count >= 5){
        break;
      }
      if (fftm.getBand(i)*(float)Math.log(i+2)/9>40) {
        LaserLine l = new LaserLine(actual);
        las.add(l);
        count ++;
      }
    }
  }
  
  for (int i = 0; i <las.size();i++){
    if (las.get(i).timer >= 14){
      las.remove(i);
    }
  }
  
  for (LaserLine laser:las){
    laser.beam();
  }
  
  //if (millis()-timeSinceLastH>50) {
  //  timeSinceLastH = millis();
  //  for (int i = width/2-100; i < width/2+200; i++) {
  //    if (fftm.getBand(i)*(float)Math.log(i+2)/9>=15) {
  //      HorizLine bez = new HorizLine(actual);
  //      hTrails.add(bez);
  //      break;
  //    }
  //  }
  //}
  //for (int i = 0; i < hTrails.size();i++) {
  //  if ((hTrails.get(i).xPos>width)) {
  //    hTrails.remove(i);
  //  }
  //}
  //for (HorizLine b:hTrails){
  //  b.drawLine();
  //}
  image(actual,0,0);
  float reach = map(s.mix.level(),0,1,1,1000);
  float weight = map(s.mix.level(),0,1,1,10);
  for (int ix = 0; ix < width;ix+=10){
    for (int iy = 0; iy < height; iy+=10){
      color p = actual.get(ix,iy);
      strokeCap(ROUND);
      stroke(p);
      if (ix <= 400 && iy >= height - 50){
        continue;
      }
      strokeWeight(weight);
      //Spikes
      //line(ix-random(-reach,reach),iy-random(-reach,reach),ix+random(-reach,reach),iy+random(-reach,reach));
      
      //Crosses
      //line(ix,iy,ix+random(-reach,reach),iy);
      //line(ix,iy,ix,iy+random(-reach,reach));
      
      //Slopes
      //line(ix-map(noise(ix,iy,(float)millis()/1000),0,1,-reach,reach),iy-map(noise(ix,iy,(float)millis()/1000),0,1,-reach,reach),ix+map(noise(ix,iy,(float)millis()/1000),0,1,-reach,reach),iy+map(noise(ix,iy,(float)millis()/1000),0,1,-reach,reach));
      
      //Noise Glitch
      line(ix,iy-map(noise(ix,iy,ix+(float)millis()/1000),0,1,0,reach),ix,iy+map(noise(ix,iy,(float)millis()/1000),0,1,0,reach));
      line(ix-map(noise(ix,iy,ix+(float)millis()/1000),0,1,0,reach),iy,ix+map(noise(ix,iy,ix+(float)millis()/1000),0,1,0,reach),iy);
      
      //line(ix,iy,ix+reach,iy+reach);
      
      //Bubbles
      //ellipse(ix,iy,random(-reach,reach),random(-reach,reach));
      
      //Points
      //strokeWeight(10);
      //point(ix + random(-reach,reach),iy + random(-reach,reach));
    }
  }
  //fill(255);
  //textSize(map(s.mix.level(),0,1,1,1000));
  //textAlign(CENTER);
  //text(meta.title(),width/2,height/2);
  //fill(0,255);
  fill(255);
  textSize(50);
  textAlign(LEFT,BOTTOM);
  text(floor(s.position()/1000/60) + ":" + s.position()/1000%60 + " of " + floor(meta.length()/1000/60) + ":" + meta.length()/1000%60,0,height);
}

void keyPressed() {
  if (s.isPlaying() && key == ' ') {
    s.pause();
    noLoop();
  } else {
    s.play();
    loop();
  }
  
  if (keyCode == UP){
    println(s.getGain());
    s.setGain(s.getGain()+1);
  }
  
  if (keyCode == DOWN){
    println(s.getGain());
    s.setGain(s.getGain()-1);
  }

  if (keyCode == RIGHT) {
    s.play(s.position()+5000);
  }

  if (keyCode == LEFT) {
    s.play(s.position()-5000);
  }
}
