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
Minim minim;
ControlP5 cp5;
boolean playlistSelected = false;
int doubleCount = 0;
int lastKey;
String path;

//For now, the program automatically runs fullscreen on the second available display.
void settings() {
  fullScreen(P3D);
}

void setup() {
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
  //Logic for double press to skip.
  if (lastKey == LEFT || lastKey == RIGHT) {
    doubleCount ++;
  }
  if (doubleCount > frameRate / 3) {
    lastKey = 0;
    doubleCount = 0;
  }

  background(0);
  if (!playlistSelected) { //Displays as home, when no playlist loaded
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

    //Draws controls after everything else
    cp5.draw();
  } else { //Run the player and it's functions
    p.display();
  }
}

//Handle home screen controls
void controlEvent(ControlEvent event) {
  if (event.getName() == "playlistSelector") { //Loads an existing playlist
    JSONObject ob = (JSONObject) json.getJSONArray("playlists").get((int)cp5.get(ScrollableList.class, "playlistSelector").getValue());
    String title = ob.getString("name");
    print(title);
    if (p != null && p.playing != null) {
      p.playing.audio.pause();
    }
    p = new Player(cp5, minim, title, json, (int) cp5.get(ScrollableList.class, "playlistSelector").getValue());
    playlistSelected = true;
    cp5.get(Textfield.class, "playlistName").setGroup("otherPlayers").setPosition(0, 5);
    cp5.get(ScrollableList.class, "playlistSelector").setGroup("otherPlayers").setPosition(0, 70).setHeight(height - 140);
    cp5.get(Group.class, "otherPlayers").show();
  } else if (event.getName() == "makePlaylist" || event.getName() == "playlistName") { //Creates a new playlist
    if (p != null && p.playing != null) {
      p.playing.audio.pause();
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
      p.playing.audio.pause();
    }
    p = new Player(cp5, minim, name, json, json.getJSONArray("playlists").size()-1);
    playlistSelected = true;
    cp5.get(Textfield.class, "playlistName").setGroup("otherPlayers").setPosition(0, 5);
    cp5.get(ScrollableList.class, "playlistSelector").setGroup("otherPlayers").setPosition(0, 70).setHeight(height - 140);
    cp5.get(Group.class, "otherPlayers").show();
  }
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
      if (p.playing.audio.isMuted()) {
        p.playing.audio.unmute();
      } else {
        p.playing.audio.mute();
      }
      cp5.get(Toggle.class,"mute").setValue(!p.playing.audio.isMuted());
    }

    if (key == 'r' && !cp5.get(Textfield.class,"playlistName").isFocus() || key == 'l' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      p.loopSwitch();
    }

    if (key == 's' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      p.shuffle = !p.shuffle;
      cp5.get(Toggle.class,"shuffle").setValue(p.shuffle);
    }

    if (keyCode == UP) {
      p.gain = p.playing.audio.getGain() + 1;
      p.playing.audio.setGain(p.gain);
    }

    if (keyCode == DOWN) {
      p.gain = p.playing.audio.getGain() - 1;
      p.playing.audio.setGain(p.gain);
    }

    if (keyCode == RIGHT && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      if (lastKey != 0) {
        if (lastKey == RIGHT && doubleCount <= frameRate / 2) {
          p.songNumber ++;
          if (p.songNumber >= p.songs.size()) {
            p.songNumber = 0;
          }
          p.playing.audio.pause();
          if (!p.shuffle){
            p.playing = p.songs.get(p.songNumber);
          }
          else{
            p.playing = p.shuffles.get(p.songNumber);
          }
          p.playing.audio.play(0);
          p.playing.audio.unmute();
          lastKey = 0;
        } else {
          p.playing.audio.cue(p.playing.audio.position() + 5000);
        }
      } else {
        lastKey = RIGHT;
        p.playing.audio.cue(p.playing.audio.position() + 5000);
      }
    }

    if (keyCode == LEFT && !cp5.get(Textfield.class,"playlistName").isFocus()) {
      if (lastKey != 0) {
        if (lastKey == LEFT && doubleCount <= frameRate / 2) {
          if (p.playing.audio.position() <= 3000){
            p.songNumber --;
          }  
          if (p.songNumber < 0) {
            p.songNumber = p.songs.size() - 1;
          }
          p.playing.audio.pause();
          if (!p.shuffle){
            p.playing = p.songs.get(p.songNumber);
          }
          else{
            p.playing = p.shuffles.get(p.songNumber);
          }
          p.playing.audio.setGain(p.gain);
          p.playing.audio.play(0);
          p.playing.audio.unmute();
          lastKey = 0;
        } else {
          p.playing.audio.cue(p.playing.audio.position() - 5000);
        }
      } else {
        lastKey = LEFT;
        p.playing.audio.cue(p.playing.audio.position() - 5000);
      }
    }
  }
}
