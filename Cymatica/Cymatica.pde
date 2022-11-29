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
boolean paused = false;
Minim minim;
ControlP5 cp5;
int startupSteps = 0;
boolean initial = true;
boolean playlistSelected = false;

void settings() {
  fullScreen();
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
  cp5.addScrollableList("playlistSelector").setSize(200, 50).setPosition(width/2-100, height/2+100);
  cp5.addGroup("otherPlayers").setPosition(width-300,height/2).setSize(200,20);
  cp5.addScrollableList("list").setPosition(0,10).setWidth(200).hide();
}

void draw() {
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
  println("Triggered by: " + event.getName());
  if (event.getName() == "playlistSelector") {
    JSONObject ob =  (JSONObject) json.getJSONArray("playlists").get((int)cp5.get(ScrollableList.class,"playlistSelector").getValue());
    String title = ob.getString("name");
    print(title);
    p = new Player(cp5, minim, title, ob);
    playlistSelected = true;
    moveThings();
  } else if (event.getName() == "makePlaylist" || event.getName() == "playlistName") {
    String name = cp5.get(Textfield.class, "playlistName").getText();
    JSONObject newPlaylist = new JSONObject();
    JSONArray songPaths = new JSONArray();
    JSONArray visSettings = new JSONArray();
    newPlaylist.put("name", name);
    newPlaylist.put("songs", songPaths);
    newPlaylist.put("settings", visSettings);
    json.getJSONArray("playlists").append(newPlaylist);
    saveJSONObject(json, "playlists.json");
    p = new Player(cp5, minim, name, newPlaylist);
    playlistSelected = true;
    moveThings();
  }
}

void moveThings(){
  cp5.get(Textfield.class,"playlistName").setGroup("otherPlayers").setPosition(0,35);
  cp5.get(ScrollableList.class,"playlistSelector").setGroup("otherPlayers").setPosition(0,120);
}
