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
String path;

void settings() {
  fullScreen(P3D);
}

void setup() {
  textFont = loadFont("ArialUnicodeMS-48.vlw");
  symFont = loadFont("Webdings-48.vlw");
  minim = new Minim(this);
  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);
  path = sketchPath() + "/data/playlists.json";
  File f = new File(path);
  if (!f.isFile()) {
    createOutput(path);
    JSONObject playlists = new JSONObject();
    JSONArray array = new JSONArray();
    playlists.put("playlists", array);
    saveJSONObject(playlists, path);
  }
  json = loadJSONObject(path);
  cp5.addTextfield("playlistName")
    .setSize(200, 50)
    .setPosition(width / 2 - 100, height / 2)
    .setValue("Awesome Sauce")
    .getCaptionLabel()
    .align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE);
  cp5.addScrollableList("playlistSelector").setSize(200, 50).setPosition(width / 2 - 100, height / 2 + 100).setHeight(height / 2 - 200).setItemHeight(50);
  cp5.addGroup("otherPlayers").setPosition(width - 200, 85).setLabel("Other Players").setSize(200, 20).hide().setBackgroundColor(0);
}

void draw() {
  if (lastKey == LEFT || lastKey == RIGHT) {
    doubleCount ++;
  }
  if (doubleCount > frameRate / 3) {
    lastKey = 0;
    doubleCount = 0;
  }
  background(0);
  if (!playlistSelected) {
    if (json.getJSONArray("playlists").size() == 0) {
      textAlign(CENTER, CENTER);
      textSize(30);
      text("Looks like you don't have any playlists set up yet. Let's do that!", width / 2, height / 2 - 50);
    } else {
      textAlign(CENTER, CENTER);
      textSize(30);
      text("Pick a playlist to get started, or make a new one!", width / 2, height / 2 - 50);
      if (cp5.get(ScrollableList.class, "playlistSelector").getItems().size() != json.getJSONArray("playlists").size()) {
        for (int i = 0; i < cp5.get(ScrollableList.class, "playlistSelector").getItems().size(); i++) {
          HashMap h = (HashMap) cp5.get(ScrollableList.class, "playlistSelector").getItems().get(i);
          String n = (String) h.get("name");
          cp5.get(ScrollableList.class, "playlistSelector").removeItem(n);
        }
        for (int i = 0; i < json.getJSONArray("playlists").size(); i++) {
          JSONObject ob = (JSONObject) json.getJSONArray("playlists").get(i);
          cp5.get(ScrollableList.class, "playlistSelector").addItem(ob.getString("name"), i);
        }
      }
    }
    cp5.draw();
  } else {
    p.display();
  }
}

void controlEvent(ControlEvent event) {
  if (event.getName() == "playlistSelector") {
    JSONObject ob = (JSONObject) json.getJSONArray("playlists").get((int)cp5.get(ScrollableList.class, "playlistSelector").getValue());
    String title = ob.getString("name");
    print(title);
    if (p != null && p.playing != null) {
      p.playing.pause();
    }
    p = new Player(cp5, minim, title, json, (int) cp5.get(ScrollableList.class, "playlistSelector").getValue());
    playlistSelected = true;
    moveThings();
    cp5.get(Group.class, "otherPlayers").show();
  } else if (event.getName() == "makePlaylist" || event.getName() == "playlistName") {
    if (p != null && p.playing != null) {
      p.playing.pause();
    }
    String name = cp5.get(Textfield.class, "playlistName").getText().trim();
    cp5.get(ScrollableList.class, "playlistSelector").addItem(name, json.getJSONArray("playlists").size());
    JSONObject newPlaylist = new JSONObject();
    JSONArray songPaths = new JSONArray();
    JSONArray visSettings = new JSONArray();
    newPlaylist.put("name", name);
    newPlaylist.put("songs", songPaths);
    newPlaylist.put("settings", visSettings);
    json.getJSONArray("playlists").append(newPlaylist);
    saveJSONObject(json, path);
    if (p != null && p.playing != null) {
      p.playing.pause();
    }
    p = new Player(cp5, minim, name, json, json.getJSONArray("playlists").size()-1);
    playlistSelected = true;
    moveThings();
    cp5.get(Group.class, "otherPlayers").show();
  }
}

void moveThings() {
  cp5.get(Textfield.class, "playlistName").setGroup("otherPlayers").setPosition(0, 5);
  cp5.get(ScrollableList.class, "playlistSelector").setGroup("otherPlayers").setPosition(0, 70).setHeight(height - 140);
}

void keyPressed() {
  if (p != null) {
    if ( key == ' ' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      p.playPause();
    }

    if (key == 'h' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      if (cp5.isVisible()) {
        cp5.hide();
      } else {
        cp5.show();
      }
    }

    if (key == 'm' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      if (p.playing.isMuted()) {
        p.playing.unmute();
      } else {
        p.playing.mute();
      }
      cp5.get(Toggle.class,"mute").setValue(!p.playing.isMuted());
    }

    if (key == 'r' && !cp5.get(Textfield.class,"playlistName").isFocus() || key == 'l' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      p.loopSingle = !p.loopSingle;
      cp5.get(Toggle.class,"loopSingle").setValue(p.loopSingle);
    }

    if (key == 's' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      p.shuffle = !p.shuffle;
      cp5.get(Toggle.class,"shuffle").setValue(p.shuffle);
    }

    if (keyCode == UP) {
      p.gain = p.playing.getGain() + 1;
      p.playing.setGain(p.gain);
    }

    if (keyCode == DOWN) {
      p.gain = p.playing.getGain() - 1;
      p.playing.setGain(p.gain);
    }

    if (keyCode == RIGHT && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      if (lastKey != 0) {
        if (lastKey == RIGHT && doubleCount <= frameRate / 2) {
          p.songNumber ++;
          if (p.songNumber >= p.audio.size()) {
            p.songNumber = 0;
          }
          p.playing.pause();
          if (!p.shuffle){
            p.playing = p.audio.get(p.songNumber);
          }
          else{
            p.playing = p.shuffled.get(p.songNumber);
          }
          p.fft = p.ffts.get(p.songNumber);
          p.meta =p.playing.getMetaData();
          p.playing.play(0);
          p.playing.unmute();
          lastKey = 0;
          p.seekbar.setRange(0, p.meta.length());
        } else {
          p.playing.cue(p.playing.position() + 5000);
        }
      } else {
        lastKey = RIGHT;
        p.playing.cue(p.playing.position() + 5000);
      }
    }

    if (keyCode == LEFT && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      if (lastKey != 0) {
        if (lastKey == LEFT && doubleCount <= frameRate / 2) {
          if (p.playing.position() <= 3000){
            p.songNumber --;
          }  
          if (p.songNumber < 0) {
            p.songNumber = p.audio.size() - 1;
          }
          p.playing.pause();
          if (!p.shuffle){
            p.playing = p.audio.get(p.songNumber);
          }
          else{
            p.playing = p.shuffled.get(p.songNumber);
          }
          p.fft = p.ffts.get(p.songNumber);
          p.meta =p.playing.getMetaData();
          p.playing.setGain(p.gain);
          p.playing.play(0);
          p.playing.unmute();
          lastKey = 0;
          p.seekbar.setRange(0, p.meta.length());
        } else {
          p.playing.cue(p.playing.position() - 5000);
        }
      } else {
        lastKey = LEFT;
        p.playing.cue(p.playing.position() - 5000);
      }
    }
  }
}
