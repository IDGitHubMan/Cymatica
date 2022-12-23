public class Player {
  int fftType = 0;
  float gain = 0.0f;
  int shufflePos = 0;
  int shuffleInc = 1;
  PImage loopSymbol;
  PImage soundSymbol;
  PImage shuffleSymbol;
  PImage ppSymbol;
  String message = "Something went wrong.";
  float mSpeakerSize = 50;
  float rSpeakerSize = 50;
  float lSpeakerSize = 50;
  ControlP5 cp5;
  Minim minim;
  String n;
  float loopCircle = 0.0;
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
  Slider seekbar;
  Toggle muter;
  Toggle shuffleToggle;
  Bang playButton;
  boolean seeking = false;
  PGraphics actual;
  int seek;
  String jPath = sketchPath() + "/data/playlists.json";
  Player(ControlP5 controller, Minim m, String name, JSONObject p, int num) {
    loopSymbol = loadImage("loop.png");
    soundSymbol = loadImage("sound.png");
    shuffleSymbol = loadImage("shuffle.png");
    shuffleSymbol.resize(40,50);
    ppSymbol = loadImage("pp.png");
    data = p;
    n = name;
    minim = m;
    number = num;
    cp5 = controller;
    l = cp5.addGroup("list").setPosition(0,20).setWidth(200).setBackgroundColor(0).setMoveable(true);
    seekbar = cp5.addSlider("seek").setPosition(200,height - 40).setWidth(width-400).setCaptionLabel("").plugTo(this);
    seekbar.getValueLabel().hide();
    cp5.addToggle("loopSingle").setPosition(width-250,height-100).setSize(50,50).setCaptionLabel("").plugTo(this).setValue(loopSingle);
    muter = cp5.addToggle("mute").setPosition(width-300,height-100).setSize(50,50).setCaptionLabel("").plugTo(this).setValue(true);
    shuffleToggle = cp5.addToggle("shuffle").setPosition(width-350,height-100).setSize(50,50).setCaptionLabel("").plugTo(this).setValue(shuffle);
    playButton = cp5.addBang("playPause").setPosition(width/2-25,height-100).setSize(50,50).setCaptionLabel("").plugTo(this);
    playlistObj = (JSONObject) data.getJSONArray("playlists").getJSONObject(num);
    songList = (JSONArray) playlistObj.get("songs");
    actual = createGraphics(width,height,P3D);
    for (int i = 0; i < songList.size(); i++) {
      JSONObject s = (JSONObject) songList.get(i);
      AudioPlayer a = minim.loadFile(s.getString("path"));
      FFT fast = new FFT(a.bufferSize(), a.sampleRate());
      fast.noAverages();
      try {
        audio.add(minim.loadFile(s.getString("path")));
        ffts.add(fast);
      }
      catch (NullPointerException e){
        try {
          audio.add(minim.loadFile(s.getString("path2")));
          ffts.add(fast);
        }
        catch (NullPointerException e2) {
          incompatible = true;
          message = "The song couldn't be found.";
          continue;
        }
      }
      cp5.addTextlabel("title" + String.valueOf(i)).setText(s.getString("title")).setPosition(0,5+37*i).setGroup(l);
      //cp5.addButton("remove"+ String.valueOf(i)).setPosition(0,20).setGroup(String.valueOf(i+1)).setLabel("Remove").plugTo(this);
      cp5.addButton("play"+String.valueOf(i)).setPosition(0,20 + i * 37).setLabel("play").plugTo(this).setGroup(l);
    }
    cp5.addBang("addSong").setPosition(width-200, 50).plugTo(this).setLabel("Add song").getCaptionLabel().align(ControlP5.CENTER,ControlP5.CENTER).setPaddingX(5);

    //cp5.addBang("addFolder").setPosition(60, height-40).plugTo(this).setLabel("Add folder");
    if (audio.size()!=0) {
      playing = audio.get(0);
      playing.setGain(gain);
      playing.play(0);
      fft = ffts.get(0);
      seekbar.setRange(0,playing.length());
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
      String path = sketchPath() + "/data/Library/" + n + "/" + f.getName();
      createOutput(path);
      saveBytes(path,loadBytes(f.getAbsolutePath()));
      AudioMetaData meta = a.getMetaData();
      JSONObject song = new JSONObject();
      if (meta.title() != "") {
        song.put("title", meta.title());
        cp5.addTextlabel("title" + String.valueOf(songList.size()+1)).setText(meta.title()).setPosition(0,5+37*songList.size()).setGroup(l);
        //cp5.addButton("remove"+ String.valueOf(songList.size()+1)).setPosition(0,20).setGroup(String.valueOf(songList.size()+1)).setLabel("Remove").plugTo(this);
        cp5.addButton("play"+String.valueOf(songList.size()+1)).setPosition(0,20 + songList.size() * 37).setGroup(l).setLabel("play").plugTo(this);
      } else {
        song.put("title", meta.fileName().substring(meta.fileName().lastIndexOf("/")+1,meta.fileName().length()-4));
        cp5.addTextlabel("title" + String.valueOf(songList.size()+1)).setGroup(l).setText(meta.fileName().substring(meta.fileName().lastIndexOf("/")+1,meta.fileName().length()-4)).setPosition(0,5+37*songList.size());
        //cp5.addButton("remove"+ String.valueOf(songList.size()+1)).setPosition(0,20).setGroup(String.valueOf(songList.size()+1)).setLabel("Remove").plugTo(this);
        cp5.addButton("play"+String.valueOf(songList.size()+1)).setPosition(0,20 + songList.size() * 37).setGroup(l).setLabel("play").plugTo(this);
      }
      song.put("author", meta.author());
      song.put("album", meta.album());
      song.put("path", path);
      song.put("path2",f.getAbsolutePath());
      songList.append(song);
      playlistObj.put("songs", songList);
      data.getJSONArray("playlists").setJSONObject(number, playlistObj);
      saveJSONObject(data, jPath);
      songNumber = songList.size()-1;
      if (playing != null){
        playing.pause();
        playing = a;
        playing.setGain(gain);
        playing.play(0);
        seekbar.setRange(0,playing.length());
        fft = ffts.get(songNumber);
      }
      else{
        playing = a;
        playing.setGain(gain);
        playing.play(0);
        seekbar.setRange(0,playing.length());
        fft = ffts.get(songNumber);
      }
      shuffled = (ArrayList<AudioPlayer>)audio.clone();
      Collections.shuffle(shuffled);
    }

    catch (NullPointerException e) {
      incompatible = true;
      message = "The file was not compatible.";
    }
  }

  void addSong() {
    selectInput("Select a WAV, MP3, or AIFF file.", "songAppend", null, this);
  }
  
  void addFolder(){
    selectFolder("Select a folder to add multiple music files.","checkFolder",null,this);
  }

  void playPause(){
    if (playing != null ){
      if ( playing.isPlaying()){
        playing.pause();
        paused = true;
      }
      else{
        playing.play();
        paused = false;
      }
    }
  }

  void controlEvent(ControlEvent e) {
    if (e.getName().contains("play") && e.getName() != "playPause"){
      if (playing != null){
        playing.pause();
      }
      playing = audio.get(Integer.parseInt(e.getName().substring(4,e.getName().length())));
      songNumber = Integer.parseInt(e.getName().substring(4,e.getName().length()));
      playing.play(0);
      playing.setGain(gain);
      seekbar.setRange(0,playing.length());
      fft = ffts.get(0);
    }
    else if (e.getName().contains("remove")){
      if ( playing == audio.get(Integer.parseInt(e.getName().substring(e.getName().length())))){
        playing.pause();
      }
      audio.remove(Integer.parseInt(e.getName().substring(e.getName().length()-1)));
      songList.remove(Integer.parseInt(e.getName().substring(e.getName().length()-1)));
      playlistObj.put("songs",songList);
      data.getJSONArray("playlists").setJSONObject(number,playlistObj);
      saveJSONObject(data,jPath);
      cp5.remove(String.valueOf(Integer.parseInt(e.getName().substring(e.getName().length()-1))+1));
    }
    else if (e.getName() == "seek" && mousePressed && e.getValue() != playing.position() && seekbar.isMouseOver()){
      playing.pause();
      playing.cue(seek);
      playing.play();
    }
    else if (e.getName() == "mute" && mousePressed && muter.isMouseOver()){
      if (p.playing.isMuted()) {
        p.playing.unmute();
      } else {
        p.playing.mute();
      }
    }
  }


  void checkFolder() {
  }

  void loopSwitch() {
    loopSingle = !loopSingle;
  }

  

  void display() {
    if (loopSingle){
      loopCircle += 0.01;
    }
    if (playing != null){
      meta = playing.getMetaData();
      seekbar.setValue(playing.position());
      actual.beginDraw();
      if (cp5.isVisible()){
        if (fftType == 0){
          fft.noAverages();
          fft.forward(playing.left);
          actual.stroke(0,255,255,255);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),198,width-202);
            actual.line(xPos,height-40,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
          fft.forward(playing.right);
          actual.stroke(255,0,0,255);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),202,width-198);
            actual.line(xPos,height-40,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
          fft.forward(playing.mix);
          actual.stroke(255,255,255,255);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),200,width-200);
            actual.line(xPos,height-40,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
        }
        else{
          actual.noFill();
          fft.forward(playing.left);
          actual.stroke(0,255,255,255);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),198,width-202);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
          actual.endShape();
          fft.forward(playing.right);
          actual.stroke(255,0,0,255);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),202,width-198);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
          actual.endShape();
          fft.forward(playing.mix);
          actual.stroke(255,255,255,255);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),200,width-200);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
          actual.endShape();
        }
      }
      else{
        if (fftType == 0){
          fft.forward(playing.left);
          actual.stroke(0,255,255);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),-2,width-2);
            actual.line(xPos,height,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
          fft.forward(playing.right);
          actual.stroke(255,0,0);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),2,width+2);
            actual.line(xPos,height,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
          fft.forward(playing.mix);
          actual.stroke(255,255,255);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),0,width);
            actual.line(xPos,height,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
        }
        else{
          fft.forward(playing.left);
          actual.stroke(0,255,255);
          actual.noFill();
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),-2,width-2);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
          actual.endShape();
          fft.forward(playing.right);
          actual.stroke(255,0,0);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),2,width+2);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
          actual.endShape();
          fft.forward(playing.mix);
          actual.stroke(255,255,255);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),0,width);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
          actual.endShape();
        }
      }
      actual.strokeWeight(1);
      actual.fill(0,50);
      actual.noStroke();
      actual.rect(0,0,actual.width,actual.height);
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
      actual.endDraw();
    }
    if (songList.size() != 0) {
      if (playing != null && !playing.isPlaying() && !paused){
        actual.background(0);
        if (!loopSingle){
          songNumber += 1;
        }
        if (songNumber>=audio.size()){
          songNumber = 0;
        }
        if (songNumber<0){
          songNumber = audio.size() - 1;
        }
        if (shuffle){
          if (loopSingle){
            playing = audio.get(songNumber);
          }
          else{
            playing = shuffled.get(songNumber);
          }
        }
        else{
          playing = audio.get(songNumber);
        }
        playing.setGain(gain);
        playing.cue(0);
        p.playing.unmute();
        fft = ffts.get(songNumber);
        playing.play();
        if (songNumber >= audio.size()){
          songNumber = 0;
        }
        meta = playing.getMetaData();
        seekbar.setRange(0,playing.length());
      }
    }
    tint(255,255);
    imageMode(CORNER);
    image(actual,0,0);
    cp5.draw();
    if (cp5.isVisible()){
      if (playing != null){
        if (playing.isMuted()){
          imageMode(CENTER);
          tint(255,128);
          image(soundSymbol,width-275,height-75,mSpeakerSize,mSpeakerSize);
        }
        else{
          mSpeakerSize = map(playing.mix.level(),0,1,30,90);
          rSpeakerSize = map(playing.right.level(),0,1,30,90);
          lSpeakerSize = map(playing.left.level(),0,1,30,90);
          imageMode(CENTER);
          tint(0,255,255,255);
          image(soundSymbol,width-277,height-75,lSpeakerSize,lSpeakerSize);
          tint(255,0,0,255);
          image(soundSymbol,width-273,height-75,rSpeakerSize,rSpeakerSize);
          tint(255,255);
          image(soundSymbol,width-275,height-75,mSpeakerSize,mSpeakerSize);
        }
        imageMode(CENTER);
        image(ppSymbol,width/2,height-75,mSpeakerSize,mSpeakerSize);
        
      }
      if (shuffle){
        shufflePos += 1;
        if (shufflePos <= 33){
          float actual = map(shufflePos,0,33,width-345,width-325);
          int tempWidth = (int) map(shufflePos,0,33,0,40);
          tint(255,255);
          imageMode(CENTER);
          image(shuffleSymbol,actual,height-75,tempWidth,50,0,0,tempWidth,50);
        }
        else if (shufflePos >= 99){
          float actual = map(shufflePos,99,132,width-325,width-305);
          int tempWidth = (int) map(shufflePos,99,132,0,40);
          tint(255,255);
          imageMode(CENTER);
          image(shuffleSymbol,actual,height-75,40 - tempWidth,50,tempWidth,0,40,50);
        }
        else{
          tint(255,255);
          image(shuffleSymbol,width-325,height-75,40,50);
        }
        if (shufflePos > 198){
          shufflePos = 0;
        }
        
      }
      else{
        tint(255,128);
        image(shuffleSymbol,width-325,height-75,40,50);
      }
      pushMatrix();
      translate(width-225,height-75);
      rotate(loopCircle);
      tint(255,loopSingle?255:128);
      imageMode(CORNER);
      image(loopSymbol,-25,-25,50,50);
      popMatrix();
      textAlign(CENTER,CENTER);
      textSize(25);
      fill(255,loopSingle?255:128);
      text("1",width-225,height-79);
      stroke(255);
      fill(255);
      textAlign(LEFT, TOP);
      textSize(30);
      text(n, width - 200, 0);
      textSize(10);
      textAlign(LEFT,BOTTOM);
      if (playing != null){
        textAlign(RIGHT,BOTTOM);
        textSize(20);
        fill(255);
        int currentMins = floor(playing.position()/1000/60);
        int currentSecs = floor((playing.position()/1000)%60);
        String formattedCurrentSecs = (String.valueOf(currentSecs).length()<2) ? nf(currentSecs,2,0) : String.valueOf(currentSecs);
        int fullMins = floor(playing.length()/1000/60);
        int fullSecs = floor((playing.length()/1000)%60);
        String formattedFullSecs = (String.valueOf(fullSecs).length()<2) ? nf(fullSecs,2,0) : String.valueOf(fullSecs);
        text( currentMins + ":" + formattedCurrentSecs + "/" + fullMins + ":"+ formattedFullSecs,width-200,height);
      }
    }
    if (messageTimer > 50) {
      incompatible = false;
    }
    if (incompatible) {
      messageTimer ++;
      textAlign(CENTER, BOTTOM);
      fill(255);
      text(message, width/2, height-20);
    }
  }
}
