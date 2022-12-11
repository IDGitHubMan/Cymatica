import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import java.util.*;

PFont textFont,symFont;
boolean paused = false;
boolean loopSingle = false;
boolean shuffle = true;

Minim m;
ArrayList<AudioPlayer> audio = new ArrayList();
ArrayList<FFT> fftMixed = new ArrayList();
FFT mix;
AudioMetaData meta;
AudioPlayer playing;
ArrayList<AudioPlayer> shuffled = new ArrayList();
int number = 0;
void settings(){
  fullScreen(P3D);
  //size(1920,1080);
}

void setup(){
  textFont = loadFont("ArialUnicodeMS-48.vlw");
  symFont = loadFont("Webdings-48.vlw");
  m = new Minim(this);
  File f = new File("/Users/isaiahdesrosiers/Documents/Projects/Cymatica/SoundViz/data");
  File[] matchingFiles = f.listFiles();
  for (File song:matchingFiles){
    if (song.getName().contains(".mp3") || song.getName().contains(".wav")){
      AudioPlayer a = m.loadFile(song.getPath());
      audio.add(a);
      fftMixed.add( new FFT(a.bufferSize(),a.sampleRate()));
    }
  }
  shuffled = (ArrayList) audio.clone();
  Collections.shuffle(shuffled);
  if (shuffle){
      playing = shuffled.get(number);
    }
    else{
      playing = audio.get(number);
    }
  mix = fftMixed.get(number);
  mix.noAverages();
  meta = playing.getMetaData();
  playing.play();
  println(shuffled);
  println();
  println(audio);
}

void draw(){
  if (!playing.isPlaying() && !paused){
    background(0);
    if (!loopSingle){
      number += 1;
    }
    if (shuffle){
      playing = shuffled.get(number);
    }
    else{
      playing = audio.get(number);
    }
    if (number>=audio.size()){
      number = 0;
    }
    playing = audio.get(number);
    playing.cue(0);
    mix = fftMixed.get(number);
    playing.play();
    if (number >= audio.size()){
      number = 0;
    }
    meta = playing.getMetaData();
  }
  //background(0);
  fill(0,0,0,30);
  noStroke();
  rect(0,0,width,height);
  stroke(255);
  noFill();
  stroke(0,0,255);
  ellipse(width/2,height/2,map(playing.left.level(),0,1,0,height),map(playing.left.level(),0,1,0,height));
  stroke(255,0,0);
  ellipse(width/2,height/2,map(playing.right.level(),0,1,0,height),map(playing.right.level(),0,1,0,height));
  stroke(255);
  ellipse(width/2,height/2,map(playing.mix.level(),0,1,0,height),map(playing.mix.level(),0,1,0,height));
  for(int i = 0; i < playing.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, playing.bufferSize(), 0, width );
    float x2 = map( i+1, 0, playing.bufferSize(), 0, width );
    stroke(0,0,255);
    line( x1, height/2 + playing.left.get(i)*50, x2, height/2 + playing.left.get(i+1)*50 );
    stroke(255,0,0);
    line( x1, height/2 + playing.right.get(i)*50, x2, height/2 + playing.right.get(i+1)*50 );
    stroke(255);
    line( x1, height/2 + playing.mix.get(i)*50, x2, height/2 + playing.mix.get(i+1)*50 );
  }
  stroke(0,0,255);
  mix.forward( playing.left );
  
  for(int i = 0; i < mix.specSize(); i++)
  {
    float xPos = ceil(map(i,0,mix.specSize(),-1,width-1));
    line(xPos,height,xPos,height - mix.getBand(i)*(float)Math.log(i+2)/3);
  }
  stroke(255,0,0);
  mix.forward( playing.right );
  
  for(int i = 0; i < mix.specSize(); i++)
  {
    float xPos = ceil(map(i,0,mix.specSize(),1,width+1));
    line(xPos,height,xPos,height - mix.getBand(i)*(float)Math.log(i+2)/3);
  }
  stroke(255);
  mix.forward( playing.mix );
  for(int i = 0; i < mix.specSize(); i++)
  {
    float xPos = ceil(map(i,0,mix.specSize(),0,width));
    line(xPos,height,xPos,height - mix.getBand(i)*(float)Math.log(i+2)/3);
  }
  
  textFont(textFont);
  
  fill(0,0,255);
  textAlign(LEFT,BOTTOM);
  textSize(map(playing.mix.level(),0,1,1,100));
  text(meta.author(),-5,height);
  fill(255,0,0);
  textAlign(LEFT,BOTTOM);
  textSize(map(playing.mix.level(),0,1,1,100));
  text(meta.author(),5,height);
  fill(255);
  textAlign(LEFT,BOTTOM);
  textSize(map(playing.mix.level(),0,1,1,100));
  text(meta.author(),0,height);
  
  fill(0,0,255);
  textAlign(RIGHT,BOTTOM);
  textSize(map(playing.mix.level(),0,1,1,100));
  text(meta.title(),width-5,height);
  fill(255,0,0);
  textAlign(RIGHT,BOTTOM);
  textSize(map(playing.mix.level(),0,1,1,100));
  text(meta.title(),width+5,height);
  fill(255);
  textAlign(RIGHT,BOTTOM);
  textSize(map(playing.mix.level(),0,1,1,100));
  text(meta.title(),width,height);
  
  textFont(symFont);
  textAlign(CENTER,CENTER);
  textSize(20);
  text("974;8:",width/2,height-80);
  
}
