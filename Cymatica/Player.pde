public class Player {
  //Super important path builder
  String jPath = sketchPath() + "/data/playlists.json";

  //Visualizer settings
  boolean showLeft = true; //Include left vis
  boolean showRight = true; //Include right vis
  int fftType = 0; // Bar or plot FFT
  int linAvgNum = 30; //Number of bands for linear averaging
  int logAvgWidth = 22; //Logarithmic average octave width (in hertz)
  int logAvgBands = 3; //Number of bands to split each octave into

  //Internal player values
  float gain = 0.0f; //Volume of player
  boolean paused = false;
  boolean loopSingle = false;
  boolean shuffle;
  int number;
  int songNumber = 0;
  int seek;

  //Stuff for animated toggles
  PImage loopSymbol;
  PImage soundSymbol;
  PImage shuffleSymbol;
  PImage ppSymbol;
  float mSpeakerSize = 50;
  float rSpeakerSize = 50;
  float lSpeakerSize = 50;
  float loopCircle = 0.0;
  int shufflePos = 0;
  int shuffleInc = 1;

  //Error messaging
  String message = "Something went wrong.";
  boolean incompatible = false;
  int messageTimer = 0;

  //Important Objects
  JSONObject data;
  JSONObject playlistObj;
  JSONArray songList;
  ControlP5 cp5;
  Minim minim;
  String n;
  ArrayList<Song> songs = new ArrayList<Song>();
  ArrayList<Song> shuffles;
  Song playing;
  FFT fft;
  Group l;
  Slider seekbar;
  Toggle muter;
  Toggle shuffleToggle;
  Bang playButton;
  boolean seeking = false;

  //Buffer for adding overlay effects
  PGraphics actual;
  
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
      try {
        Song so = new Song(minim,s.getString("path"),s.getString("author"),s.getString("title"),s.getString("album"),s.getInt("number"),s.getInt("left"),s.getInt("right"),s.getInt("mix"));
        songs.add(so);
        fft = so.fft;
      }
      catch (NullPointerException e){
        try {
          Song so = new Song(minim,s.getString("path2"),s.getString("author"),s.getString("title"),s.getString("album"),s.getInt("number"),s.getInt("left"),s.getInt("right"),s.getInt("mix"));
          songs.add(so);
          fft = so.fft;
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
    if (songs.size()!=0) {
      playing = songs.get(0);
      playing.audio.setGain(gain);
      playing.audio.play(0);
      fft = songs.get(0).fft;
      println(songs.get(0));
      seekbar.setRange(0,playing.audio.length());
      shuffles = (ArrayList<Song>)songs.clone();
      Collections.shuffle(shuffles);
    }
  }

  //Song addition functions
  void addSong() {
    selectInput("Select a WAV, MP3, or AIFF file.", "songAppend", null, this);
  }
  
  void songAppend(File f) {
    try {
      Song s = new Song(minim,f.getAbsolutePath(),songs.size()+1);
      songs.add(s);
      println(songs.get(songs.size()-1).position);
      String path = sketchPath() + "/data/Library/" + n + "/" + f.getName();
      createOutput(path);
      saveBytes(path,loadBytes(f.getAbsolutePath()));
      JSONObject song = new JSONObject();
      song.put("title", s.title);
      cp5.addTextlabel("title" + String.valueOf(songList.size()+1)).setText(s.title).setPosition(0,5+37*songList.size()).setGroup(l);
      //cp5.addButton("remove"+ String.valueOf(songList.size()+1)).setPosition(0,20).setGroup(String.valueOf(songList.size()+1)).setLabel("Remove").plugTo(this);
      cp5.addButton("play"+String.valueOf(songList.size()+1)).setPosition(0,20 + songList.size() * 37).setGroup(l).setLabel("play").plugTo(this);
      song.put("author", s.artist);
      song.put("album", s.album);
      song.put("path", path);
      song.put("path2",f.getAbsolutePath());
      song.put("left",color(0,255,255));
      song.put("right",color(255,0,0));
      song.put("mix",color(255));
      song.put("number",songs.size());
      songList.append(song);
      playlistObj.put("songs", songList);
      data.getJSONArray("playlists").setJSONObject(number, playlistObj);
      saveJSONObject(data, jPath);
      songNumber = songList.size()-1;
      if (playing != null){
        playing.audio.pause();
        playing = s;
        playing.audio.setGain(gain);
        playing.audio.play(0);
        seekbar.setRange(0,playing.audio.length());
        fft = songs.get(songNumber).fft;
      }
      else{
        playing = s;
        playing.audio.setGain(gain);
        playing.audio.play(0);
        seekbar.setRange(0,playing.audio.length());
        fft = songs.get(songNumber).fft;
      }
      shuffles = (ArrayList<Song>)songs.clone();
      Collections.shuffle(shuffles);
    }

    catch (NullPointerException e) {
      incompatible = true;
      message = "The file was not compatible.";
    }
  }

  void addFolder(){
    selectFolder("Select a folder to add multiple music files.","checkFolder",null,this);
  }

  void checkFolder(File f) {
  }

  void urlAdd(String url){}

  //Player functions
  void playPause(){
    if (playing != null ){
      if ( playing.audio.isPlaying()){
        playing.audio.pause();
        paused = true;
      }
      else{
        playing.audio.play();
        paused = false;
      }
    }
  }

  void loopSwitch() {
    loopSingle = !loopSingle;
    cp5.get(Toggle.class,"loopSingle").setValue(p.loopSingle);
  }

  //UI Functionality
  void controlEvent(ControlEvent e) {
    if (e.getName().contains("play") && e.getName() != "playPause"){
      if (playing != null){
        playing.audio.pause();
      }
      playing = songs.get(Integer.parseInt(e.getName().substring(4,e.getName().length())));
      songNumber = Integer.parseInt(e.getName().substring(4,e.getName().length()));
      playing.audio.play(0);
      playing.audio.setGain(gain);
      seekbar.setRange(0,playing.audio.length());
      fft = songs.get(0).fft;
    }
    else if (e.getName().contains("remove")){
      if ( playing == songs.get(Integer.parseInt(e.getName().substring(e.getName().length())))){
        playing.audio.pause();
      }
      songs.remove(Integer.parseInt(e.getName().substring(e.getName().length()-1)));
      songList.remove(Integer.parseInt(e.getName().substring(e.getName().length()-1)));
      playlistObj.put("songs",songList);
      data.getJSONArray("playlists").setJSONObject(number,playlistObj);
      saveJSONObject(data,jPath);
      cp5.remove(String.valueOf(Integer.parseInt(e.getName().substring(e.getName().length()-1))+1));
    }
    else if (e.getName() == "seek" && mousePressed && e.getValue() != playing.audio.position() && seekbar.isMouseOver()){
      playing.audio.pause();
      playing.audio.cue(seek);
      playing.audio.play();
    }
    else if (e.getName() == "mute" && mousePressed && muter.isMouseOver()){
      if (playing.audio.isMuted()) {
        playing.audio.unmute();
      } else {
        playing.audio.mute();
      }
    }
  }

  //Displays the player
  void display() {
    //Rudimentary error messaging
    if (messageTimer > 50) {
      incompatible = false;
    }
    if (incompatible) {
      messageTimer ++;
      textAlign(CENTER, BOTTOM);
      fill(255);
      text(message, width/2, height-20);
    }

    //Logic for auto progression and playlist loop
    if (songList.size() != 0) {
      if (playing != null && !playing.audio.isPlaying() && !paused){
        actual.background(0);
        if (!loopSingle){
          songNumber += 1;
        }
        if (songNumber>=songs.size()){
          songNumber = 0;
        }
        if (songNumber<0){
          songNumber = songs.size() - 1;
        }
        if (shuffle){
          if (loopSingle){
            playing = songs.get(songNumber);
          }
          else{
            playing = shuffles.get(songNumber);
          }
        }
        else{
          playing = songs.get(songNumber);
        }
        playing.audio.setGain(gain);
        playing.audio.cue(0);
        playing.audio.unmute();
        fft = songs.get(songNumber).fft;
        playing.audio.play();
        if (songNumber >= songs.size()){
          songNumber = 0;
        }
        seekbar.setRange(0,playing.audio.length());
      }
    }

    //Animates loop symbol
    if (loopSingle){
      loopCircle += 0.01;
    }
    if (playing != null){
      seekbar.setValue(playing.audio.position()); //Updates seekbar
      actual.beginDraw();
      if (cp5.isVisible()){ //Display FFT over seekbar
        if (fftType == 0){ //Display FFT as bar graph
          //Left FFT
          fft.forward(playing.audio.left);
          actual.stroke(playing.leftColor);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),198,width-202);
            actual.line(xPos,height-40,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }

          //Right FFT
          fft.forward(playing.audio.right);
          actual.stroke(playing.rightColor);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),202,width-198);
            actual.line(xPos,height-40,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }

          //Mix FFT
          fft.forward(playing.audio.mix);
          actual.stroke(playing.mixColor);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),200,width-200);
            actual.line(xPos,height-40,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
        }
        else{ //Display FFT as line plot
          actual.noFill();

          //Left FFT
          fft.forward(playing.audio.left);
          actual.stroke(playing.leftColor);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),198,width-202);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
          actual.endShape();

          //Right FFT
          fft.forward(playing.audio.right);
          actual.stroke(playing.rightColor);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),202,width-198);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
          actual.endShape();

          //Mix FFT
          fft.forward(playing.audio.mix);
          actual.stroke(playing.mixColor);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),200,width-200);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/4 - 40);
          }
          actual.endShape();
        }
      }
      else{ //Display FFT on bottom of screen
        if (fftType == 0){ //Bars

          //left
          fft.forward(playing.audio.left);
          actual.stroke(playing.leftColor);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),-2,width-2);
            actual.line(xPos,height,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }

          //right
          fft.forward(playing.audio.right);
          actual.stroke(playing.rightColor);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),2,width+2);
            actual.line(xPos,height,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }

          //mix
          fft.forward(playing.audio.mix);
          actual.stroke(playing.mixColor);
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),0,width);
            actual.line(xPos,height,xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
        }
        else{ //line

          //left
          fft.forward(playing.audio.left);
          actual.stroke(playing.leftColor);
          actual.noFill();
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),-2,width-2);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
          actual.endShape();

          //right
          fft.forward(playing.audio.right);
          actual.stroke(playing.rightColor);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),2,width+2);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
          actual.endShape();

          //mix
          fft.forward(playing.audio.mix);
          actual.stroke(playing.mixColor);
          actual.beginShape();
          for(int i = 0; i < fft.specSize(); i++){
            float xPos = map(i,0,fft.specSize(),0,width);
            actual.vertex(xPos,height - fft.getBand(i)*(float)Math.log(i+5)/3);
          }
          actual.endShape();
        }
      }
      actual.strokeWeight(1);

      //To create the nice after image effect
      actual.fill(0,40);
      actual.noStroke();
      actual.rect(0,0,actual.width,actual.height);

      actual.noFill();
      //Ellipses represnting left volumes (horizontal and vertical)
      actual.stroke(playing.leftColor);
      actual.ellipse(width/2, height/9*8, map(playing.audio.left.level(), 0, 1, 0, height), map(playing.audio.left.level(), 0, 1, 0, height));
      actual.ellipse(width/2, height/9, map(playing.audio.left.level(), 0, 1, 0, height), map(playing.audio.left.level(), 0, 1, 0, height));
      actual.ellipse(width/4, height/2, map(playing.audio.left.level(), 0, 1, 0, height), map(playing.audio.left.level(), 0, 1, 0, height));
      actual.ellipse(width/4*3, height/2, map(playing.audio.left.level(), 0, 1, 0, height), map(playing.audio.left.level(), 0, 1, 0, height));
      actual.ellipse(width/2, height/2, map(playing.audio.left.level(), 0, 1, 0, height), map(playing.audio.left.level(), 0, 1, 0, height));

      //Ellipses representing right volumes (diagonals)
      actual.stroke(playing.rightColor);
      actual.ellipse(width/4, height/9*8, map(playing.audio.right.level(), 0, 1, 0, height), map(playing.audio.right.level(), 0, 1, 0, height));
      actual.ellipse(width/4*3, height/9, map(playing.audio.right.level(), 0, 1, 0, height), map(playing.audio.right.level(), 0, 1, 0, height));
      actual.ellipse(width/4, height/9, map(playing.audio.right.level(), 0, 1, 0, height), map(playing.audio.right.level(), 0, 1, 0, height));
      actual.ellipse(width/4*3, height/9*8, map(playing.audio.right.level(), 0, 1, 0, height), map(playing.audio.right.level(), 0, 1, 0, height));
      actual.ellipse(width/2, height/2, map(playing.audio.right.level(), 0, 1, 0, height), map(playing.audio.right.level(), 0, 1, 0, height));

      //Ellipse for mix Level (center)
      actual.stroke(playing.mixColor);
      actual.ellipse(width/2, height/2, map(playing.audio.mix.level(), 0, 1, 0, height), map(playing.audio.mix.level(), 0, 1, 0, height));

      //Audio waveforms
      for(int i = 0; i < playing.audio.bufferSize() - 1; i++){
        float x1 = map( i, 0, playing.audio.bufferSize(), 0, width );
        float x2 = map( i+1, 0, playing.audio.bufferSize(), 0, width );

        //Left
        actual.stroke(playing.leftColor);
        actual.line( x1, height/2 + map(playing.audio.left.get(i),-1,1,-100,100), x2, height/2 + map(playing.audio.left.get(i+1),-1,1,-100,100));

        //Right
        actual.stroke(playing.rightColor);
        actual.line( x1, height/2 + map(playing.audio.right.get(i),-1,1,-100,100), x2, height/2 + map(playing.audio.right.get(i+1),-1,1,-100,100) );

        //Mix
        actual.stroke(playing.mixColor);
        actual.line( x1, height/2 + map(playing.audio.mix.get(i),-1,1,-100,100), x2, height/2 + map(playing.audio.mix.get(i+1),-1,1,-100,100) );
      }
      actual.endDraw();
    }
    //Display buffer graphic
    tint(255,255);
    imageMode(CORNER);
    image(actual,0,0);

    //Draws controls before some elements, to create the animated buttons
    cp5.draw();
    if (cp5.isVisible()){
      if (playing != null){

        //Mute button animation
        if (playing.audio.isMuted()){
          imageMode(CENTER);
          tint(255,128);
          image(soundSymbol,width-275,height-75,mSpeakerSize,mSpeakerSize);
        }
        else{
          mSpeakerSize = map(playing.audio.mix.level(),0,1,30,90);
          rSpeakerSize = map(playing.audio.right.level(),0,1,30,90);
          lSpeakerSize = map(playing.audio.left.level(),0,1,30,90);
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

      //Shuffle button animation
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

      //Loop button animation
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

      //Displays Playlist name in top right
      stroke(255);
      fill(255);
      textAlign(RIGHT, TOP);
      textSize(30);
      text(n, width, 0);
      textSize(10);

      //Displays time position of song
      textAlign(LEFT,BOTTOM);
      if (playing != null){
        textAlign(RIGHT,BOTTOM);
        textSize(20);
        fill(255);
        int currentMins = floor(playing.audio.position()/1000/60);
        int currentSecs = floor((playing.audio.position()/1000)%60);
        String formattedCurrentSecs = (String.valueOf(currentSecs).length()<2) ? nf(currentSecs,2,0) : String.valueOf(currentSecs);
        int fullMins = floor(playing.audio.length()/1000/60);
        int fullSecs = floor((playing.audio.length()/1000)%60);
        String formattedFullSecs = (String.valueOf(fullSecs).length()<2) ? nf(fullSecs,2,0) : String.valueOf(fullSecs);
        text( currentMins + ":" + formattedCurrentSecs + "/" + fullMins + ":"+ formattedFullSecs,width-200,height);
      }
    }
  }
}
