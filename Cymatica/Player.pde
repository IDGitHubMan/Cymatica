public class Player {
  ControlP5 cp5;
  Minim minim;
  String n;
  ArrayList<AudioPlayer> audio = new ArrayList();
  ArrayList<FFT> ffts = new ArrayList();
  boolean paused = false;
  boolean loopSingle = false;
  boolean shuffle;
  JSONObject playlistObj;
  JSONArray songList;
  boolean incompatible = false;
  int messageTimer = 0;
  
  Player(ControlP5 controller, Minim m, String name, JSONObject p){
    playlistObj = p;
    n = name;
    minim = m;
    cp5 = controller;
    ScrollableList l = cp5.get(ScrollableList.class,"list").show().plugTo(this);
    songList = (JSONArray) playlistObj.getJSONArray("songs");
    for (int i = 0; i < songList.size();i++){
      JSONObject s = (JSONObject) songList.get(i);
      l.addItem(s.getString("title"),i);
      AudioPlayer a = minim.loadFile(s.getString("path"));
      audio.add(minim.loadFile(s.getString("path")));
      ffts.add(new FFT(a.bufferSize(),a.sampleRate()));
    }
    cp5.addBang("addSong").setPosition(0,100).plugTo(this);
  }
  
  void songAppend(File f){
    AudioPlayer a;
    println("Tried to add " + f.getAbsolutePath());
    try{
      a = minim.loadFile(f.getAbsolutePath());
      ffts.add(new FFT(a.bufferSize(),a.sampleRate()));
      audio.add(a);
      AudioMetaData meta = a.getMetaData();
      JSONObject song = new JSONObject();
      if (meta.title() != ""){
        song.put("title",meta.title());
      }
      else {
        song.put("title",meta.fileName());
      }
      song.put("author",meta.author());
      song.put("album",meta.album());
      songList.append(song);
    }
    
    catch (NullPointerException e){
      incompatible = true;
    }
  }
  
  void addSong(){
    selectInput("Select a WAV, MP3, or AIFF file.","songAppend",null,this);
  }
  
  
  void checkFolder(){}
  
  void display(){
    stroke(255);
    fill(255);
    textAlign(CENTER,TOP);
    text(n,width/2,0);
    if (messageTimer > 50){
      incompatible = false;
    }
    if (incompatible){
      messageTimer ++;
      textAlign(CENTER,BOTTOM);
      fill(255);
      text("The file wasn't compatible. Try another!",width/2,height-20);
    }
  }
}
