public class Player {
  ControlP5 cp5;
  Minim minim;
  String n;
  ArrayList<AudioPlayer> audio = new ArrayList();
  ArrayList<AudioPlayer> shuffled;
  AudioPlayer playing;
  AudioMetaData meta;
  ArrayList<FFT> ffts = new ArrayList();
  FFT fft;
  boolean paused = false;
  boolean loopSingle = false;
  boolean shuffle;
  JSONObject data;
  JSONObject playlistObj;
  JSONArray songList;
  boolean incompatible = false;
  int messageTimer = 0;
  int number;
  int songNumber = 0;
  Group l;
  PGraphics actual;

  Player(ControlP5 controller, Minim m, String name, JSONObject p, int num) {
    data = p;
    n = name;
    minim = m;
    number = num;
    cp5 = controller;
    l = cp5.addGroup("list").setPosition(0,20).setWidth(200);
    playlistObj = (JSONObject) data.getJSONArray("playlists").getJSONObject(num);
    songList = (JSONArray) playlistObj.get("songs");
    actual = createGraphics(width,height);
    for (int i = 0; i < songList.size(); i++) {
      JSONObject s = (JSONObject) songList.get(i);
      AudioPlayer a = minim.loadFile(s.getString("path"));
      try {
        audio.add(minim.loadFile(s.getString("path")));
        ffts.add(new FFT(a.bufferSize(), a.sampleRate()));
      }
      catch (NullPointerException e){
        incompatible = true;
        continue;
      }
      cp5.addGroup(String.valueOf(i+1)).setGroup("list").setPosition(0,20 + i*60).setWidth(200);
      cp5.addTextlabel("title" + String.valueOf(i)).setGroup(String.valueOf(i+1)).setText(s.getString("title")).setPosition(0,5);
      //cp5.addButton("remove"+ String.valueOf(i)).setPosition(0,20).setGroup(String.valueOf(i+1)).setLabel("Remove").plugTo(this);
      cp5.addButton("play"+String.valueOf(i)).setPosition(0,20).setGroup(String.valueOf(i+1)).setLabel("play").plugTo(this);
    }
    cp5.addBang("addSong").setPosition(0, height-40).plugTo(this).setLabel("Add song");
    //cp5.addBang("addFolder").setPosition(60, height-40).plugTo(this).setLabel("Add folder");
    if (audio.size()!=0) {
      playing = audio.get(0);
      playing.play(0);
      fft = ffts.get(0);
      shuffled = (ArrayList<AudioPlayer>)audio.clone();
      Collections.shuffle(shuffled);
    }
  }

  void songAppend(File f) {
    AudioPlayer a;
    try {
      a = minim.loadFile(f.getAbsolutePath());
      ffts.add(new FFT(a.bufferSize(), a.sampleRate()));
      audio.add(a);
      AudioMetaData meta = a.getMetaData();
      JSONObject song = new JSONObject();
      if (meta.title() != "") {
        song.put("title", meta.title());
        cp5.addGroup(String.valueOf(songList.size()+1)).setGroup("list").setPosition(0,20 + (songList.size())*60).setWidth(200);
        cp5.addTextlabel("title" + String.valueOf(songList.size()+1)).setGroup(String.valueOf(songList.size()+1)).setText(meta.title()).setPosition(0,5);
        cp5.addButton("remove"+ String.valueOf(songList.size()+1)).setPosition(0,20).setGroup(String.valueOf(songList.size()+1)).setLabel("Remove").plugTo(this);
        cp5.addButton("play"+String.valueOf(songList.size()+1)).setPosition(70,20).setGroup(String.valueOf(songList.size()+1)).setLabel("play").plugTo(this);
      } else {
        song.put("title", meta.fileName());
        cp5.addGroup(String.valueOf(songList.size()+1)).setGroup("list").setPosition(0,20 + (songList.size())*60).setWidth(200);
        cp5.addTextlabel("title" + String.valueOf(songList.size()+1)).setGroup(String.valueOf(songList.size()+1)).setText(meta.fileName()).setPosition(0,5);
        cp5.addButton("remove"+ String.valueOf(songList.size()+1)).setPosition(0,20).setGroup(String.valueOf(songList.size()+1)).setLabel("Remove").plugTo(this);
        cp5.addButton("play"+String.valueOf(songList.size()+1)).setPosition(70,20).setGroup(String.valueOf(songList.size()+1)).setLabel("play").plugTo(this);
      }
      song.put("author", meta.author());
      song.put("album", meta.album());
      song.put("path", f.getAbsolutePath());
      songList.append(song);
      playlistObj.put("songs", songList);
      data.getJSONArray("playlists").setJSONObject(number, playlistObj);
      saveJSONObject(data, "playlists.json");
      if (playing != null){
        playing.pause();
        playing = a;
        playing.play(0);
        fft = ffts.get(0);
      }
    }

    catch (NullPointerException e) {
      incompatible = true;
    }
  }

  void addSong() {
    selectInput("Select a WAV, MP3, or AIFF file.", "songAppend", null, this);
  }
  
  void addFolder(){
    selectFolder("Select a folder to add multiple music files.","checkFolder",null,this);
  }

  void controlEvent(ControlEvent e) {
    if (e.getName().contains("play")){
      if (playing != null){
        playing.pause();
      }
      playing = audio.get(Integer.parseInt(e.getName().substring(e.getName().length()-1)));
      playing.play(0);
      fft = ffts.get(0);
    }
    else if (e.getName().contains("remove")){
      if ( playing == audio.get(Integer.parseInt(e.getName().substring(e.getName().length()-1)))){
        playing.pause();
      }
      audio.remove(Integer.parseInt(e.getName().substring(e.getName().length()-1)));
      songList.remove(Integer.parseInt(e.getName().substring(e.getName().length()-1)));
      playlistObj.put("songs",songList);
      data.getJSONArray("playlists").setJSONObject(number,playlistObj);
      saveJSONObject(data,"playlists.json");
      cp5.remove(String.valueOf(Integer.parseInt(e.getName().substring(e.getName().length()-1))+1));
    }
  }


  void checkFolder() {
  }

  void display() {
    actual.beginDraw();
    actual.background(0);
    actual.noFill();
    actual.stroke(0, 255,  255);
    actual.ellipse(width/2, height/2, map(playing.left.level(), 0, 1, 0, height), map(playing.left.level(), 0, 1, 0, height));
    actual.stroke(255, 0, 0);
    actual.ellipse(width/2, height/2, map(playing.right.level(), 0, 1, 0, height), map(playing.right.level(), 0, 1, 0, height));
    actual.stroke(255);
    actual.ellipse(width/2, height/2, map(playing.mix.level(), 0, 1, 0, height), map(playing.mix.level(), 0, 1, 0, height));

    actual.stroke(0,255,255);
    actual.ellipse(width/2, height/9*8, map(playing.left.level(), 0, 1, 0, height), map(playing.left.level(), 0, 1, 0, height));
    actual.ellipse(width/2, height/9, map(playing.left.level(), 0, 1, 0, height), map(playing.left.level(), 0, 1, 0, height));
    actual.ellipse(width/4, height/2, map(playing.left.level(), 0, 1, 0, height), map(playing.left.level(), 0, 1, 0, height));
    actual.ellipse(width/4*3, height/2, map(playing.left.level(), 0, 1, 0, height), map(playing.left.level(), 0, 1, 0, height));

    actual.stroke(255, 0, 0);
    actual.ellipse(width/4, height/9*8, map(playing.right.level(), 0, 1, 0, height), map(playing.right.level(), 0, 1, 0, height));
    actual.ellipse(width/4*3, height/9, map(playing.right.level(), 0, 1, 0, height), map(playing.right.level(), 0, 1, 0, height));
    actual.ellipse(width/4, height/9, map(playing.right.level(), 0, 1, 0, height), map(playing.right.level(), 0, 1, 0, height));
    actual.ellipse(width/4*3, height/9*8, map(playing.right.level(), 0, 1, 0, height), map(playing.right.level(), 0, 1, 0, height));
    for(int i = 0; i < playing.bufferSize() - 1; i++){
      float x1 = map( i, 0, playing.bufferSize(), 0, width );
      float x2 = map( i+1, 0, playing.bufferSize(), 0, width );
      actual.stroke(0,255,255);
      actual.line( x1, height/2 + map(playing.left.get(i),-1,1,-100,100), x2, height/2 + map(playing.left.get(i+1),-1,1,-100,100));
      actual.stroke(255,0,0);
      actual.line( x1, height/2 + map(playing.right.get(i),-1,1,-100,100), x2, height/2 + map(playing.right.get(i+1),-1,1,-100,100) );
      actual.stroke(255);
      actual.line( x1, height/2 + map(playing.mix.get(i),-1,1,-100,100), x2, height/2 + map(playing.mix.get(i+1),-1,1,-100,100) );
    }
    if (songList.size() != 0) {
      if (playing != null && !playing.isPlaying() && !paused){
        if (!loopSingle){
          songNumber += 1;
        }
        if (number>=audio.size()){
          songNumber = 0;
        }
        if (shuffle){
          playing = shuffled.get(songNumber);
        }
        else{
          playing = audio.get(songNumber);
        }
        playing = audio.get(songNumber);
        playing.cue(0);
        fft = ffts.get(songNumber);
        playing.play();
        if (songNumber >= audio.size()){
          songNumber = 0;
        }
        meta = playing.getMetaData();
      }
    }
    actual.endDraw();
    image(actual,0,0);
    stroke(255);
    fill(255);
    textAlign(LEFT, TOP);
    text(n, width - 200, 0);
    if (messageTimer > 50) {
      incompatible = false;
    }
    if (incompatible) {
      messageTimer ++;
      textAlign(CENTER, BOTTOM);
      fill(255);
      text("The file wasn't compatible. Try another!", width/2, height-20);
    }
  }
}
