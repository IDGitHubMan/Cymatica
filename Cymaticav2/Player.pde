class Player {
    PApplet p;
    SampleManager sm;
    SamplePlayer player;
    Glide gl;
    Gain g;
    AudioContext ac;
    RMS rms;
    FFT fft;
    
    String selectedList;
    int songNumber = 0;
    int visualMode = 0;
    Boolean playlistSelected = false;
    int outs;
    
    GButton newPlaylistFromDir;
    GButton newPlaylist;
    GButton addLocal;
    GButton addUrl;
    GButton addFolder;
    GButton viewLibrary;
    GTextField playlistTitle;
    
    Player(PApplet applet) {
        ac = AudioContext.getDefaultContext();
        gl = new Glide(ac, 1);
        g = new Gain(2, gl);
        p = applet;
        newPlaylistFromDir = new GButton(p, width / 2 - 100, height / 2 + 40, 100, 40, "Local Playlist");
        newPlaylist = new GButton(p, width / 2, height / 2 + 40, 100, 40, "Empty Playlist");
        addLocal = new GButton(p, 0, 0, 75, 25, "Add Song");
        addUrl = new GButton(p, 0, 25, 75, 25, "Add URL");
        addFolder = new GButton(p, 0, 50, 75, 25, "Add Multi");
        playlistTitle = new GTextField(p, width / 2 - 100, height / 2, 200, 20);
    }
    
    void display() {
        addLocal.setVisible(playlistSelected);
        addUrl.setVisible(playlistSelected);
        addFolder.setVisible(playlistSelected);
        if (playlistSelected) {
            playlistTitle.moveTo(width - 200, 0);
            newPlaylistFromDir.moveTo(width - 200, 30);
            newPlaylist.moveTo(width - 100, 30);
        } else {
            newPlaylistFromDir.moveTo(width / 2 - 100, height / 2 + 40);
            newPlaylist.moveTo(width / 2, height / 2 + 40);
            colorMode(RGB,255,255,255);
            textSize(50);
            textAlign(CENTER, CENTER);
            fill(255, 0, 0);
            text("Cymatica", width / 2 + map(noise(frameCount / 10), 0, 1, -5, 5), height / 2 - 50);
            fill(0, 255, 255);
            text("Cymatica", width / 2 - map(noise(frameCount / 10), 0, 1, -5, 5), height / 2 - 50);
            fill(255);
            text("Cymatica", width / 2, height / 2 - 50);
        }
    }
    
    public void addSong() {
    }
    
    public void createPlaylist() {
    }
    
    void fileSelected(File selection) {
        String audioFileName = selection.getAbsolutePath();
        SamplePlayer player = new SamplePlayer(SampleManager.sample(audioFileName));
        player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
        g.addInput(player);
        ac.out.addInput(g);
        ac.start();
    }
}
