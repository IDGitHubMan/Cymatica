class Player {
    Table song;
    PApplet p;
    SampleManager sm;
    SamplePlayer player;
    PowerSpectrum ps;
    Glide gl;
    Gain g;
    AudioContext ac;
    FFT fft;
    ShortFrameSegmenter sfs;
    int songNumber = 0;
    Bead nextSong;
    String vizMode = "basic";
    int variety = 0;
    float range = 86;
    float proportion;
    float angleAmount;
    float rotator = 0.0;
    int angleCount;
    int songLastChecked;
    int settingsLastChecked;
    File songCSV = new File(sketchPath() + "/data/nowPlaying.csv");
    File settingsCSV = new File(sketchPath() + "/data/states.csv");
    
    Player(PApplet applet) {
        song = loadTable("nowPlaying.csv","header");
        songLastChecked = (int) songCSV.lastModified();
        settingsLastChecked = (int) settingsCSV.lastModified();
        p = applet;
        ac = AudioContext.getDefaultContext();
        gl = new Glide(ac, 1);
        g = new Gain(2, gl);
        sfs = new ShortFrameSegmenter(ac);
        sfs.addInput(ac.out);
        fft = new FFT();
        ps = new PowerSpectrum();
        sfs.addListener(fft);
        fft.addListener(ps);
        ac.out.addDependent(sfs);
        proportion = range / ac.getBufferSize();
        angleAmount = proportion * TWO_PI;
        angleCount = floor((TWO_PI) / angleAmount);
    }
    
    void run() {
        rotator += 0.01;
        if(player == null) {
            player = new SamplePlayer(ac,sm.sample((String) song.getString(0,"Path")));
            player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
            g.addInput(player);
            ac.out.addInput(g);
            ac.start();
        }
        else{
            if(songLastChecked < (int) songCSV.lastModified()) {
                songLastChecked = (int)songCSV.lastModified();
                Table newSong = loadTable("nowPlaying.csv","header");
                song = loadTable("nowPlaying.csv","header");
                if(song.getString(songNumber,"Path") != newSong.getString(songNumber,"Path")) {
                    ac.out.clearInputConnections();
                    g.clearInputConnections();
                    player = null;
                }
                song = newSong;
            }
        }
        if(player != null) {
            float lSum = 0;
            for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                lSum += player.getOutBuffer(0)[i] * player.getOutBuffer(0)[i];   
            }
            float lRMS = (float) Math.sqrt(lSum / ac.getBufferSize());
            
            float rSum = 0;
            for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                rSum += player.getOutBuffer(1)[i] * player.getOutBuffer(1)[i];   
            } 
            float rRMS = (float) Math.sqrt(rSum / ac.getBufferSize());
            
            float mSum = 0;
            for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                mSum += ((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2) * ((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2);   
            }
            float mRMS = (float) Math.sqrt(mSum / ac.getBufferSize());
            
            if(vizMode == "basic") {
                stroke(song.getInt(0,"LeftR"),song.getInt(0,"LeftG"),song.getInt(0,"LeftB"),song.getInt(0,"LeftA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map(player.getOutBuffer(0)[i], -1,1,0,height);
                    float h2 = map(player.getOutBuffer(0)[i + 1], -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }
                stroke(song.getInt(0,"RightR"),song.getInt(0,"RightG"),song.getInt(0,"RightB"),song.getInt(0,"RightA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map(player.getOutBuffer(1)[i], -1,1,0,height);
                    float h2 = map(player.getOutBuffer(1)[i + 1], -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }
                stroke(song.getInt(0,"MixR"),song.getInt(0,"MixG"),song.getInt(0,"MixB"),song.getInt(0,"MixA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2, -1,1,0,height);
                    float h2 = map((player.getOutBuffer(0)[i + 1] + player.getOutBuffer(1)[i + 1]) / 2, -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }   
                noFill();
                stroke(song.getInt(0,"LeftR"),song.getInt(0,"LeftG"),song.getInt(0,"LeftB"),song.getInt(0,"LeftA"));
                ellipse(width / 2 - 1,height / 2,map(lRMS,0,1,50,height),map(lRMS,0,1,50,height));
                stroke(song.getInt(0,"RightR"),song.getInt(0,"RightG"),song.getInt(0,"RightB"),song.getInt(0,"RightA"));
                ellipse(width / 2 + 1,height / 2,map(rRMS,0,1,50,height),map(rRMS,0,1,50,height));
                stroke(song.getInt(0,"MixR"),song.getInt(0,"MixG"),song.getInt(0,"MixB"),song.getInt(0,"MixA"));
                ellipse(width / 2,height / 2,map(mRMS,0,1,50,height),map(mRMS,0,1,50,height));
            }
            else if(vizMode == "iris") {
                float[] features = ps.getFeatures();
                stroke(song.getInt(0,"LeftR"),song.getInt(0,"LeftG"),song.getInt(0,"LeftB"),song.getInt(0,"LeftA"));
                for(int i1 = 0; i1 <= angleCount; i1 ++) {
                    float start = i1 * angleAmount;
                    if(features != null) {
                        for(int i = 0; i < range; i++) {
                            float angle = map(i,0,range,start,start + angleAmount) + rotator;
                            float x = cos(angle);
                            float y = sin(angle);
                            float fftVal = features[i] * (float)Math.log(i + 1);
                            line(width / 2 + 2 + (fftVal + map(lRMS,0,1,100,height)) * x,height / 2 + (fftVal + map(lRMS,0,1,100,height)) * y,width / 2 + 2 + map(lRMS,0,1,100,height) * x,height / 2 + map(lRMS,0,1,100,height) * y);
                        }
                    }
                }
                stroke(song.getInt(0,"RightR"),song.getInt(0,"RightG"),song.getInt(0,"RightB"),song.getInt(0,"RightA"));
                for(int i1 = 0; i1 <= angleCount; i1 ++) {
                    float start = i1 * angleAmount;
                    if(features != null) {
                        for(int i = 0; i < range; i++) {
                            float angle = map(i,0,range,start,start + angleAmount) + rotator;
                            float x = cos(angle);
                            float y = sin(angle);
                            float fftVal = features[i] * (float)Math.log(i + 1);
                            line(width / 2 - 2 + (fftVal + map(rRMS,0,1,100,height)) * x,height / 2 + (fftVal + map(rRMS,0,1,100,height)) * y,width / 2 + 2 + map(rRMS,0,1,100,height) * x,height / 2 + map(rRMS,0,1,100,height) * y);
                        }
                    }
                }
                stroke(song.getInt(0,"MixR"),song.getInt(0,"MixG"),song.getInt(0,"MixB"),song.getInt(0,"MixA"));
                for(int i1 = 0; i1 <= angleCount; i1 ++) {
                    float start = i1 * angleAmount;
                    if(features != null) {
                        for(int i = 0; i < range; i++) {
                            float angle = map(i,0,range,start,start + angleAmount) + rotator;
                            float x = cos(angle);
                            float y = sin(angle);
                            float fftVal = features[i] * (float)Math.log(i + 1);
                            line(width / 2 + (fftVal + map(mRMS,0,1,100,height)) * x,height / 2 + (fftVal + map(mRMS,0,1,100,height)) * y,width / 2 + 2 + map(mRMS,0,1,100,height) * x,height / 2 + map(mRMS,0,1,100,height) * y);
                        }
                    }
                }
                fill(0);
                ellipse(width / 2,height / 2,2 * min(map(lRMS,0,1,100,height),map(rRMS,0,1,100,height),map(mRMS,0,1,100,height)),2 * min(map(lRMS,0,1,100,height),map(rRMS,0,1,100,height),map(mRMS,0,1,100,height)));
            }
        }
    }
}