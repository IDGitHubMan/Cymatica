import g4p_controls.*;
import beads.*;

Player p;
String path;

void settings() {
  size(700, 700, P2D);
}

void setup() {
  p = new Player(this);
  path = sketchPath() +"/Library/Cymatica.json";
  File f = new File(path);
  if (!f.isFile()){
    createOutput("path");
  }
  surface.setResizable(true);
  surface.setTitle("Cymatica");
}

void draw() {
  background(0);
  noFill();
  p.display();
  //for (int counts = 0; counts < outs; counts++) {
  //  stroke(counts*180, 100, 100);
  //  beginShape();
  //  for (int i = 0; i < width; i++) {
  //    //for each pixel work out where in the current audio buffer we are
  //    int buffIndex = i * ac.getBufferSize() / width;
  //    //then work out the pixel height of the audio data at that point
  //    int vOffset = (int)((1 + ac.out.getValue(counts, buffIndex)) * height / 2);
  //    //draw into Processing's convenient 1-D array of pixels
  //    vOffset = min(vOffset, height);
  //    vertex(i, vOffset);
  //  }
  //  endShape();
  //}
}

public void handleButtonEvents(GButton button, GEvent event){
    println(button);
    if (button == p.addLocal){
      String fname = G4P.selectInput("Select Audio", "mp3,wav,aiff,mid", "Sound files");
      println(fname);
    }
    if (button == p.addFolder){
      String fname = G4P.selectFolder("Select a folder to scan");
      println(fname);
    }
    if (button == p.newPlaylist){
      p.playlistSelected = true;
      
    }
    if (button == p.newPlaylistFromDir){
      p.playlistSelected = true;
      String fname = G4P.selectFolder("Select a folder to scan");
      p.sm.group(p.playlistTitle.getText(),fname);
      p.selectedList = p.playlistTitle.getText();
      println(p.sm.groupsAsList());
    }
  }
