import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import java.util.*;
Player p;

JSONObject json;
PFont textFont, symFont;
boolean shiftPressed = false;
Minim minim;
ControlP5 cp5;
int startupSteps = 0;
boolean initial = true;
boolean playlistSelected = false;
int doubleCount = 0;
int lastKey;

void settings() {
  fullScreen(P3D);
}

void setup() {
  textFont = loadFont("ArialUnicodeMS-48.vlw");
  symFont = loadFont("Webdings-48.vlw");
  minim = new Minim(this);
  cp5 = new ControlP5(this);
  File f = new File(sketchPath() + "/playlists.json");
  if (!f.isFile()) {
    createWriter("playlists.json");
    JSONObject playlists = new JSONObject();
    JSONArray array = new JSONArray();
    playlists.put("playlists", array);
    saveJSONObject(playlists, "playlists.json");
  }
  json = loadJSONObject("playlists.json");
  cp5.addTextfield("playlistName")
    .setSize(200, 50)
    .setPosition(width/2-100, height/2)
    .setValue("Awesome Sauce")
    .getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
  cp5.addScrollableList("playlistSelector").setSize(200, 50).setPosition(width/2-100, height/2+100).setHeight(height/2 - 200).setItemHeight(50);
  cp5.addGroup("otherPlayers").setPosition(width-200,50).setLabel("Other Players").setSize(200,20).hide();
}

void draw() {
  if (lastKey == LEFT || lastKey == RIGHT){
    doubleCount ++;
  }
  if (doubleCount > frameRate/2){
    lastKey = 0;
    doubleCount = 0;
  }
  background(0);
  if (!playlistSelected) {
    if (json.getJSONArray("playlists").size() == 0) {
      textAlign(CENTER, CENTER);
      textSize(30);
      text("Looks like you don't have any playlists set up yet. Let's do that!", width/2, height/2-50);
    } else {
      textAlign(CENTER, CENTER);
      textSize(30);
      text("Pick a playlist to get started, or make a new one!", width/2, height/2-50);
      if (cp5.get(ScrollableList.class,"playlistSelector").getItems().size() != json.getJSONArray("playlists").size()){
        for (int i = 0; i < cp5.get(ScrollableList.class,"playlistSelector").getItems().size(); i++){
        HashMap h = (HashMap) cp5.get(ScrollableList.class,"playlistSelector").getItems().get(i);
        String n = (String) h.get("name");
        cp5.get(ScrollableList.class,"playlistSelector").removeItem(n);
        }
        for (int i = 0; i < json.getJSONArray("playlists").size(); i++) {
          JSONObject ob =  (JSONObject) json.getJSONArray("playlists").get(i);
          cp5.get(ScrollableList.class, "playlistSelector").addItem(ob.getString("name"), i);
        }
      }
    }
  } else {
    p.display();
  }
}

void controlEvent(ControlEvent event) {
  if (event.getName() == "playlistSelector") {
    JSONObject ob =  (JSONObject) json.getJSONArray("playlists").get((int)cp5.get(ScrollableList.class,"playlistSelector").getValue());
    String title = ob.getString("name");
    print(title);
    if (p != null && p.playing != null){
      p.playing.pause();
    }
    p = new Player(cp5, minim, title, json, (int) cp5.get(ScrollableList.class,"playlistSelector").getValue());
    playlistSelected = true;
    moveThings();
    cp5.get(Group.class,"otherPlayers").show();
  } else if (event.getName() == "makePlaylist" || event.getName() == "playlistName") {
    if (p != null && p.playing != null){
      p.playing.pause();
    }
    String name = cp5.get(Textfield.class, "playlistName").getText().trim();
    cp5.get(ScrollableList.class,"playlistSelector").addItem(name,json.getJSONArray("playlists").size());
    JSONObject newPlaylist = new JSONObject();
    JSONArray songPaths = new JSONArray();
    JSONArray visSettings = new JSONArray();
    newPlaylist.put("name", name);
    newPlaylist.put("songs", songPaths);
    newPlaylist.put("settings", visSettings);
    json.getJSONArray("playlists").append(newPlaylist);
    saveJSONObject(json, "playlists.json");
    if (p != null && p.playing != null){
      p.playing.pause();
    }
    p = new Player(cp5, minim, name, json,json.getJSONArray("playlists").size());
    playlistSelected = true;
    moveThings();
  }
}

void moveThings(){
  cp5.get(Textfield.class,"playlistName").setGroup("otherPlayers").setPosition(0,5);
  cp5.get(ScrollableList.class,"playlistSelector").setGroup("otherPlayers").setPosition(0,70).setHeight(height-140);
}

void keyPressed() {
  if (p.playing.isPlaying() && key == ' ') {
    p.playing.pause();
    p.paused = true;
  } else if (key == ' ') {
    p.playing.play();
    p.paused = false;
  }

  if (key == 'h'){
    if (cp5.isVisible()){
      cp5.hide();
    }
    else{
      cp5.show();
    }
  }

  if (key == 'm'){
    if (p.playing.isMuted()){
      p.playing.unmute();
    }
    else{
      p.playing.mute();
    }
  }

  if (key == 'r'){
    p.loopSingle = !p.loopSingle;
  }

  if (key == 's'){
    p.shuffle = !p.shuffle;
  }
  
  if (keyCode == UP){
    p.playing.setGain(p.playing.getGain()+1);
  }
  
  if (keyCode == DOWN){
    p.playing.setGain(p.playing.getGain()-1);
  }

  if (keyCode == RIGHT) {
    if (lastKey != 0){
      if (lastKey == RIGHT && doubleCount <= frameRate/2){
        p.songNumber ++;
        if (p.songNumber >= p.audio.size()){
          p.songNumber = 0;
        }
        p.playing.pause();
        p.playing = p.audio.get(p.songNumber);
        p.fft = p.ffts.get(p.songNumber);
        p.meta = p.playing.getMetaData();
        p.playing.play(0);
        lastKey = 0;
      }
      else{
        p.playing.cue(p.playing.position()+5000);
      }
    }
    else{
      lastKey = RIGHT;
      p.playing.cue(p.playing.position()+5000);
    }
  }

  if (keyCode == LEFT) {
    if (lastKey != 0){
      if (lastKey == LEFT && doubleCount <= frameRate/2){
        p.songNumber --;
        if (p.songNumber < 0){
          p.songNumber = p.audio.size()-1;
        }
        float lastGain = p.playing.getGain();
        p.playing.pause();
        p.playing = p.audio.get(p.songNumber);
        p.fft = p.ffts.get(p.songNumber);
        p.meta = p.playing.getMetaData();
        p.playing.setGain(lastGain);
        p.playing.play(0);
        lastKey = 0;
      }
      else{
        p.playing.cue(p.playing.position() - 5000);
      }
    }
    else{
      lastKey = LEFT;
      p.playing.cue(p.playing.position() - 5000);
    }
  }
}
