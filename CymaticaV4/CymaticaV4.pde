import controlP5.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import java.util.*;
import javax.sound.sampled.*;
Player p;

JSONObject setting;
Table lib;

JSONObject json;
Minim minim;
ControlP5 cp5;
boolean playlistSelected = false;
int doubleCount = 0;
int lastKey;
int activeTab = 0;
String path;
AudioPlayer audio;
Slider seekbar;

int songLastChecked;
int settingsLastChecked;

File settingJSON, libraryCSV;

Tab current,albums,artists,playlists,recents,all,settings;

void settings() {
    size(500, 500);
}

void setup() {
    surface.setResizable(true);
    minim = new Minim(this);
    cp5 = new ControlP5(this);
    cp5.addBang("addSong");
    
    settingJSON = new File(dataPath("") + "/states.json");
    if(!settingJSON.exists()) {
        JSONObject def = new JSONObject();
        def.setInt("Visualizer",1);
        def.setInt("Overlay",1);
        def.setInt("overlaySpace",10);
        def.setBoolean("channelDiff",true);
        def.setInt("background",color(0,0,0));
        
        JSONObject playback = new JSONObject();
        playback.setInt("progress",0);
        playback.setInt("volume",27);
        playback.setBoolean("loop",true);
        playback.setBoolean("shuffle",true);
        playback.setInt("song",0);
        ArrayList<Integer> queue = new ArrayList<Integer>();
        playback.setJSONArray("queue",new JSONArray());
        def.setJSONObject("playback",playback);
        
        JSONObject basic = new JSONObject();
        basic.setBoolean("extraEllipses",false);
        basic.setFloat("waveLimit",0.5);
        basic.setFloat("ellipseLimit",0.3);
        def.setJSONObject("basic",basic);
        
        JSONObject iris = new JSONObject();
        iris.setBoolean("rotation",true);
        iris.setInt("lowerBound",0);
        iris.setInt("upperBound",100);
        iris.setBoolean("hollow",true);
        iris.setInt("shape",0);
        def.setJSONObject("iris",iris);
        
        JSONObject playlists = new JSONObject();
        def.setJSONObject("playlists",playlists);
        
        saveJSONObject(def, "data/states.json");
        setting = loadJSONObject("states.json");   
    }
    setting = loadJSONObject("states.json");
    
    libraryCSV = new File(dataPath("") + "/library.csv");
    if(!libraryCSV.exists()) {
        Table t = new Table();
        t.addColumn("id");
        t.addColumn("path");
        t.addColumn("name");
        t.addColumn("genre");
        t.addColumn("artist");
        t.addColumn("album");
        t.addColumn("color1");
        t.addColumn("color2");
        t.addColumn("color3");
        t.addColumn("laserToggle");
        t.addColumn("laserMin");
        t.addColumn("laserMax");
        t.addColumn("laserThreshold");
        t.addColumn("lineToggle");
        t.addColumn("lineMin");
        t.addColumn("lineMax");
        t.addColumn("lineThreshold");
        t.addColumn("sparkToggle");
        t.addColumn("sparkMin");
        t.addColumn("sparkMax");
        t.addColumn("sparkThreshold");
        
        saveTable(t,"data/library.csv");
    }
    lib = loadTable("library.csv", "header");
    
    settingsLastChecked = (int) settingJSON.lastModified();
    songLastChecked = (int) libraryCSV.lastModified();
    
    
    current = cp5.getDefaultTab().setId(0).activateEvent(true);
    cp5.getDefaultTab().setCaptionLabel("Now Playing");
    albums = cp5.addTab("Albums").setId(1).activateEvent(true);
    artists = cp5.addTab("Artists").setId(2).activateEvent(true);
    playlists = cp5.addTab("Playlists").setId(3).activateEvent(true);
    recents = cp5.addTab("Recently Added").setId(4).activateEvent(true);
    all = cp5.addTab("All Music").setId(5).activateEvent(true);
    for(TableRow s : lib.rows()) {
        cp5.addBang("PLAY" + s.getInt("id")).setId(s.getInt("id")).setLabel(s.getString("name")).setPosition(100,50 + 30 * s.getInt("id")).setTab("All Music").getCaptionLabel().align(CENTER,CENTER);
    }
    settings = cp5.addTab("settings").setId(6).activateEvent(true);
    seekbar = cp5.addSlider("seek").setPosition(0,height - 10).setWidth(width).setCaptionLabel("").plugTo(this);
    seekbar.getValueLabel().hide();
    cp5.setAutoDraw(false);

    MenuList m = new MenuList( cp5, "menu", 200, 368 );
  
  m.setPosition(40, 40);
  // add some items to our menuList
  for (int i=0;i<100;i++) {
    m.addItem(makeItem("headline-"+i, "subline", "some copy lorem ipsum ", createImage(50, 50, RGB)));
  }
    
    p = new Player(minim,lib,setting);
}

void draw() {
    //background(128);
    p.display();
    cp5.draw();
    point(mouseX,mouseY);
    if(songLastChecked != (int)libraryCSV.lastModified()) {
        lib = loadTable("library.csv","header");
        for(TableRow s : lib.rows()) {
            cp5.addBang("PLAY" + s.getInt("id")).setId(s.getInt("id")).setLabel(s.getString("name")).setPosition(100,50 + 30 * s.getInt("id")).setTab("All Music").getCaptionLabel().align(CENTER,CENTER);
        }
        
    }
    
}

// void keyPressed() {
//   if (p != null && p.playing != null) {
//     if ( key == ' ' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
//       p.playPause();
//     }

//     if (key == 'h' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
//       if (cp5.isVisible()) {
//         cp5.hide();
//       } else {
//         cp5.show();
//       }
//     }

//     if (key == 'm' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
//       if (p.playing.audio.isMuted()) {
//         p.playing.audio.unmute();
//       } else {
//         p.playing.audio.mute();
//       }
//       cp5.get(Toggle.class,"mute").setValue(!p.playing.audio.isMuted());
//     }

//     if (key == 'r' && !cp5.get(Textfield.class,"playlistName").isFocus() || key == 'l' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
//       p.loopSwitch();
//     }

//     if (key == 's' && !cp5.get(Textfield.class,"playlistName").isFocus()) {
//       p.shuffle = !p.shuffle;
//       cp5.get(Toggle.class,"shuffle").setValue(p.shuffle);
//     }

//     if (keyCode == UP) {
//       p.volUp();
//     }

//     if (keyCode == DOWN) {
//       p.volDown();
//     }

//     if (keyCode == RIGHT && !cp5.get(Textfield.class,"playlistName").isFocus()) {
//       if (lastKey != 0) {
//         if (lastKey == RIGHT && doubleCount <= frameRate / 2) {
//           p.skipForward();
//           lastKey = 0;
//         } else {
//           p.fiveForward();
//         }
//       } else {
//         lastKey = RIGHT;
//         p.fiveForward();
//       }
//     }

//     if (keyCode == LEFT && !cp5.get(Textfield.class,"playlistName").isFocus()) {
//       if (lastKey != 0) {
//         if (lastKey == LEFT && doubleCount <= frameRate / 2) {
//           p.skipBackward();
//           lastKey = 0;
//         } else {
//           p.fiveBackward();
//         }
//       } else {
//         lastKey = LEFT;
//         p.fiveBackward();
//       }
//     }
//   }
// }

void controlEvent(ControlEvent ce) {
    if(ce.isTab()) {
        activeTab = ce.getTab().getId();
        p.activeTab = ce.getTab().getId();
    }
    if(ce.getName().contains("PLAY")) {
        p.start(ce.getId());
    }
}

void addSong() {
    selectInput("Select a WAV, MP3, or AIFF file.", "songAppend", null, this);
}

Map<String, Object> makeItem(String theHeadline, String theSubline, String theCopy, PImage theImage) {
  Map m = new HashMap<String, Object>();
  m.put("headline", theHeadline);
  m.put("subline", theSubline);
  m.put("copy", theCopy);
  m.put("image", theImage);
  return m;
}

void songAppend(File f) {
    TableRow newRow = lib.addRow();
    newRow.setInt("id",lib.getRowCount());
    newRow.setString("path",f.getAbsolutePath());
    audio = minim.loadFile(f.getAbsolutePath());
    AudioMetaData meta = audio.getMetaData();
    newRow.setString("name",meta.title());
    newRow.setString("genre",meta.genre());
    newRow.setString("artist",meta.author());
    newRow.setString("album",meta.album());
    float r = random(255);
    float g = random(255);
    float b = random(255);
    newRow.setInt("color1",color(r,g,b));
    newRow.setInt("color2",color(255 - r,255 - g,255 - b));
    newRow.setInt("color3",color(255,255,255));
    newRow.setInt("laserToggle",0);
    newRow.setInt("laserMin",0);
    newRow.setInt("laserMax",20);
    newRow.setInt("laserThreshold",40);
    newRow.setInt("lineToggle",0);
    newRow.setInt("lineMin",50);
    newRow.setInt("lineMax",100);
    newRow.setInt("lineThreshold",10);
    newRow.setInt("sparkToggle",0);
    newRow.setInt("sparkMin",50);
    newRow.setInt("sparkMax",100);
    newRow.setInt("sparkThreshold",10);
    saveTable(lib,"data/library.csv");
}

void windowResized() {
    cp5 = new ControlP5(this);
    current = cp5.getDefaultTab().setId(0).activateEvent(true);
    cp5.getDefaultTab().setCaptionLabel("Now Playing");
    albums = cp5.addTab("Albums").setId(1).activateEvent(true);
    artists = cp5.addTab("Artists").setId(2).activateEvent(true);
    playlists = cp5.addTab("Playlists").setId(3).activateEvent(true);
    recents = cp5.addTab("Recently Added").setId(4).activateEvent(true);
    all = cp5.addTab("All Music").setId(5).activateEvent(true);
    for(TableRow s : lib.rows()) {
        cp5.addBang("PLAY" + s.getInt("id")).setId(s.getInt("id")).setLabel(s.getString("name")).setPosition(100,50 + 30 * s.getInt("id")).setTab("All Music").getCaptionLabel().align(CENTER,CENTER);
    }
    settings = cp5.addTab("settings").setId(6).activateEvent(true);
    seekbar = cp5.addSlider("seek").setPosition(0,height - 10).setWidth(width).setCaptionLabel("").plugTo(this);
    seekbar.getValueLabel().hide();
    cp5.setAutoDraw(false);
}

class MenuList extends controlP5.Controller<MenuList> {

  float pos, npos;
  int itemHeight = 100;
  int scrollerLength = 40;
  List< Map<String, Object>> items = new ArrayList< Map<String, Object>>();
  PGraphics menu;
  boolean updateMenu;

  MenuList(ControlP5 c, String theName, int theWidth, int theHeight) {
    super( c, theName, 0, 0, theWidth, theHeight );
    c.register( this );
    menu = createGraphics(getWidth(), getHeight() );

    setView(new ControllerView<MenuList>() {

      public void display(PGraphics pg, MenuList t ) {
        if (updateMenu) {
          updateMenu();
        }
        if (inside() ) {
          menu.beginDraw();
          int len = -(itemHeight * items.size()) + getHeight();
          int ty = int(map(pos, len, 0, getHeight() - scrollerLength - 2, 2 ) );
          menu.fill(255 );
          menu.rect(getWidth()-4, ty, 4, scrollerLength );
          menu.endDraw();
        }
        pg.image(menu, 0, 0);
      }
    }
    );
    updateMenu();
  }

  /* only update the image buffer when necessary - to save some resources */
  void updateMenu() {
    int len = -(itemHeight * items.size()) + getHeight();
    npos = constrain(npos, len, 0);
    pos += (npos - pos) * 0.1;
    menu.beginDraw();
    menu.noStroke();
    menu.background(255, 64 );
    menu.textFont(cp5.getFont().getFont());
    menu.pushMatrix();
    menu.translate( 0, pos );
    menu.pushMatrix();

    int i0 = PApplet.max( 0, int(map(-pos, 0, itemHeight * items.size(), 0, items.size())));
    int range = ceil((float(getHeight())/float(itemHeight))+1);
    int i1 = PApplet.min( items.size(), i0 + range );

    menu.translate(0, i0*itemHeight);

    for (int i=i0;i<i1;i++) {
      Map m = items.get(i);
      menu.fill(255, 100);
      menu.rect(0, 0, getWidth(), itemHeight-1 );
      menu.fill(255);
      menu.text(m.get("headline").toString(), 10, 20 );
      menu.textLeading(12);
      menu.text(m.get("subline").toString(), 10, 35 );
      menu.text(m.get("copy").toString(), 10, 50, 120, 50 );
      menu.image(((PImage)m.get("image")), 140, 10, 50, 50 );
      menu.translate( 0, itemHeight );
    }
    menu.popMatrix();
    menu.popMatrix();
    menu.endDraw();
    updateMenu = abs(npos-pos)>0.01 ? true:false;
  }
  
  /* when detecting a click, check if the click happend to the far right, if yes, scroll to that position, 
   * otherwise do whatever this item of the list is supposed to do.
   */
  public void onClick() {
    if (getPointer().x()>getWidth()-10) {
      npos= -map(getPointer().y(), 0, getHeight(), 0, items.size()*itemHeight);
      updateMenu = true;
    } 
    else {
      int len = itemHeight * items.size();
      int index = int( map( getPointer().y() - pos, 0, len, 0, items.size() ) ) ;
      setValue(index);
    }
  }
  
  public void onMove() {
  }

  public void onDrag() {
    npos += getPointer().dy() * 2;
    updateMenu = true;
  } 

  public void onScroll(int n) {
    npos += ( n * 4 );
    updateMenu = true;
  }

  void addItem(Map<String, Object> m) {
    items.add(m);
    updateMenu = true;
  }
  
  Map<String,Object> getItem(int theIndex) {
    return items.get(theIndex);
  }
}