public class Player {
  ControlP5 cp5;
  Minim minim;
  String n;
  ArrayList<AudioPlayer> audio = new ArrayList();
  AudioPlayer playing;
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
  ScrollableList l;

  Player(ControlP5 controller, Minim m, String name, JSONObject p, int num) {
    data = p;
    n = name;
    minim = m;
    number = num;
    cp5 = controller;
    l = cp5.addScrollableList("list");
    playlistObj = (JSONObject) data.getJSONArray("playlists").getJSONObject(num);
    songList = (JSONArray) playlistObj.get("songs");
    for (int i = 0; i < songList.size(); i++) {
      JSONObject s = (JSONObject) songList.get(i);
      AudioPlayer a = minim.loadFile(s.getString("path"));
      audio.add(minim.loadFile(s.getString("path")));
      ffts.add(new FFT(a.bufferSize(), a.sampleRate()));
      l.addItem(s.getString("title"), i);
    }
    cp5.addBang("addSong").setPosition(0, height-40).plugTo(this);
    if (audio.size()!=0) {
      playing = audio.get(0);
      playing.play();
      fft = ffts.get(0);
    }
  }

  void songAppend(File f) {
    AudioPlayer a;
    println("Tried to add " + f.getAbsolutePath());
    try {
      a = minim.loadFile(f.getAbsolutePath());
      ffts.add(new FFT(a.bufferSize(), a.sampleRate()));
      audio.add(a);
      AudioMetaData meta = a.getMetaData();
      JSONObject song = new JSONObject();
      if (meta.title() != "") {
        song.put("title", meta.title());
        l.addItem(meta.title(), songList.size());
      } else {
        song.put("title", meta.fileName());
        l.addItem(meta.fileName(), songList.size());
      }
      song.put("author", meta.author());
      song.put("album", meta.album());
      song.put("path", f.getAbsolutePath());
      songList.append(song);
      playlistObj.put("songs", songList);
      data.getJSONArray("playlists").setJSONObject(number, playlistObj);
      saveJSONObject(data, "playlists.json");
      playing.pause();
      playing = a;
      playing.play();
    }

    catch (NullPointerException e) {
      incompatible = true;
    }
  }

  void addSong() {
    selectInput("Select a WAV, MP3, or AIFF file.", "songAppend", null, this);
  }

  void controlEvent(ControlEvent event) {
    if (event.getName()=="list") {
      songNumber = (int) event.getValue();
    }
  }


  void checkFolder() {
  }

  void display() {
    if (songList.size() != 0) {
      if (playing != null) {
        if (!playing.isPlaying()) {
          songNumber += 1;
          if (songNumber > songList.size()) {
            songNumber = 0;
          }
          playing = audio.get(songNumber);
          playing.play();
        }
      }
    }
    stroke(255);
    fill(255);
    textAlign(CENTER, TOP);
    text(n, width/2, 0);
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
