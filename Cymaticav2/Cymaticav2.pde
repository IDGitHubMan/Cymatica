import g4p_controls.*;
import beads.*;

Player p;
String path;
JSONObject cymatica;

void settings() {
    size(1000, 800, P2D);
}

void setup() {
    path = sketchPath() + "/Library/Cymatica.json";
    File f = new File(path);
    if (!f.isFile()) {
        createOutput(path);
        
        //Basic, empty JSON stuff
        cymatica = new JSONObject();
        JSONArray playlists = new JSONArray();
        JSONArray songs = new JSONArray();
        cymatica.put("songs",songs);
        cymatica.put("playlists",playlists);
        
        //General settings
        cymatica.put("colorMode","constant");
        cymatica.put("leftColor",color(0,255,255));
        cymatica.put("rightColor",color(255,0,0));
        cymatica.put("visualizer","corona");
        cymatica.put("overlayEffect","none");
        cymatica.put("overlayType","sample");
        
        //Corona visualizer settings
        cymatica.put("coronaType","fft");
        cymatica.put("coronaReflection",false);
        cymatica.put("coronaSpin",false);
        cymatica.put("coronaMinRadius",50);
        cymatica.put("coronaMaxRadius",height);
        cymatica.put("coronaDrawMode","line");
        cymatica.put("coronaOffset",2);
        
        //Cymatics visualizer settings
        cymatica.put("cymaticsFFTMode","bar");
        cymatica.put("cymaticsLeftEllipses",true);
        cymatica.put("cymaticsRightEllipses",true);
        cymatica.put("cymaticsWaveform",true);
        cymatica.put("cymaticsWaveformCap",100);
        cymatica.put("cymaticsEllipseCap",200);
        
        //Array visualizer settings
        cymatica.put("arraySource","fft");
        
        saveJSONObject(cymatica,path);
    }
    else {
        cymatica = loadJSONObject(path);
    }
    surface.setResizable(true);
    surface.setTitle("Cymatica");
    p = new Player(this,cymatica);
}

void draw() {
    background(0);
    noFill();
    p.display();
}

public void handleButtonEvents(GButton button, GEvent event) {
    println(button);
    if (button == p.addLocal) {
        String fname = G4P.selectInput("Select Audio", "mp3,wav,aiff,mid", "Sound files");
        println(fname);
    }
    if (button == p.addFolder) {
        String fname = G4P.selectFolder("Select a folder to scan");
        println(fname);
    }
    if (button == p.newPlaylist) {
        if (p.playlistTitle.getText().trim() == "" || p.playlistTitle.getText() == null) {
            G4P.showMessage(this,"You need to name the playlist.","Null Warning",G4P.WARN_MESSAGE);
        }
        else {
            JSONObject playlist = new JSONObject();
            JSONArray playlistSongs = new JSONArray();
            playlist.put("songs",playlistSongs);
            playlist.put("title",p.playlistTitle.getText().trim());
            cymatica.getJSONArray("playlists").append(playlist);
            p.playlistSelected = true;
            
        }
    }
    if (button == p.newPlaylistFromDir) {
        String fname = G4P.selectFolder("Select a folder to scan");
        if (fname == "" || fname == null) {
            G4P.showMessage(this, "No selection was made.", "Action Canceled", G4P.WARN_MESSAGE);
        }
        else if (p.playlistTitle.getText().trim() == "" || p.playlistTitle.getText() == null) {
            G4P.showMessage(this,"You need to name the playlist.","Null Warning",G4P.WARN_MESSAGE);
        }
        else{
            JSONObject playlist = new JSONObject();
            JSONArray playlistSongs = new JSONArray();
            File f = new File(fname);
            File[]matchingFiles = f.listFiles();
            for (File song : matchingFiles) {
                if (song.getName().toLowerCase().contains(".mp3") || song.getName().toLowerCase().contains(".wav") || song.getName().toLowerCase().contains(".aif") || song.getName().toLowerCase().contains(".aiff") || song.getName().toLowerCase().contains(".mid")) {
                    String path = sketchPath() + "/Library/Songs/" + song.getName();
                    File localSong = new File(path);
                    playlistSongs.append(path);
                    if (!localSong.isFile()) {
                        saveBytes(sketchPath() + "/Library/Songs/" + song.getName(),loadBytes(song.getAbsolutePath()));
                        JSONObject s = new JSONObject();
                        s.put("originalPath",song.getAbsolutePath());
                        s.put("localPath",sketchPath() + "/Library/Songs/" + song.getName());
                        s.put("title",song.getName().substring(0,song.getName().lastIndexOf(".")));
                        s.put("artists","");
                        s.put("album","");
                        s.put("laserMin",0);
                        s.put("laserMax",30);
                        s.put("laserThreshold",30);
                        s.put("coronaFFTMin",0);
                        s.put("coronaFFTMax",86);
                        s.put("coronaRepetitions",6);
                        cymatica.getJSONArray("songs").append(s);
                    }
                }
            }
            playlist.put("title",p.playlistTitle.getText().trim());
            playlist.put("songs",playlistSongs);
            cymatica.getJSONArray("playlists").append(playlist);
            saveJSONObject(cymatica,sketchPath() + "/Library/Cymatica.json");
            p.selectedList = cymatica.getJSONArray("playlists").size() - 1;
            p.playlistSelected = true;
        }
    }
}
