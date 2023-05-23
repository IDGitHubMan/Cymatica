class Player {
    Table lib;
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
    String vizMode = "iris";
    int variety = 0;
    float range = 86;
    float proportion;
    float angleAmount;
    float rotator = 0.0;
    int angleCount;
    int songLastChecked;
    int settingsLastChecked;
    File songList = new File(sketchPath() + "/data/queue.txt");
    File settingsCSV = new File(sketchPath() + "/data/states.json");
    
    Player(PApplet applet) {
        lib = loadTable("library.csv","header");

        songLastChecked = (int) songList.lastModified();
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
            player = new SamplePlayer(ac,sm.sample((String) lib.getString(0,"LocalPath")));
            player.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
            g.addInput(player);
            ac.out.addInput(g);
            ac.start();
        }
        else{
            if(songLastChecked < (int) songList.lastModified()) {
                songLastChecked = (int)songList.lastModified();
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
                stroke(lib.getInt(0,"LeftR"),lib.getInt(0,"LeftG"),lib.getInt(0,"LeftB"),lib.getInt(0,"LeftA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map(player.getOutBuffer(0)[i], -1,1,0,height);
                    float h2 = map(player.getOutBuffer(0)[i + 1], -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }
                stroke(lib.getInt(0,"RightR"),lib.getInt(0,"RightG"),lib.getInt(0,"RightB"),lib.getInt(0,"RightA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map(player.getOutBuffer(1)[i], -1,1,0,height);
                    float h2 = map(player.getOutBuffer(1)[i + 1], -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }
                stroke(lib.getInt(0,"MixR"),lib.getInt(0,"MixG"),lib.getInt(0,"MixB"),lib.getInt(0,"MixA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2, -1,1,0,height);
                    float h2 = map((player.getOutBuffer(0)[i + 1] + player.getOutBuffer(1)[i + 1]) / 2, -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }   
                noFill();
                stroke(lib.getInt(0,"LeftR"),lib.getInt(0,"LeftG"),lib.getInt(0,"LeftB"),lib.getInt(0,"LeftA"));
                ellipse(width / 2 - 1,height / 2,map(lRMS,0,1,50,height),map(lRMS,0,1,50,height));
                stroke(lib.getInt(0,"RightR"),lib.getInt(0,"RightG"),lib.getInt(0,"RightB"),lib.getInt(0,"RightA"));
                ellipse(width / 2 + 1,height / 2,map(rRMS,0,1,50,height),map(rRMS,0,1,50,height));
                stroke(lib.getInt(0,"MixR"),lib.getInt(0,"MixG"),lib.getInt(0,"MixB"),lib.getInt(0,"MixA"));
                ellipse(width / 2,height / 2,map(mRMS,0,1,50,height),map(mRMS,0,1,50,height));
            }
            else if(vizMode == "iris") {
                float[] features = ps.getFeatures();
                stroke(lib.getInt(0,"LeftR"),lib.getInt(0,"LeftG"),lib.getInt(0,"LeftB"),lib.getInt(0,"LeftA"));
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
                stroke(lib.getInt(0,"RightR"),lib.getInt(0,"RightG"),lib.getInt(0,"RightB"),lib.getInt(0,"RightA"));
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
                stroke(lib.getInt(0,"MixR"),lib.getInt(0,"MixG"),lib.getInt(0,"MixB"),lib.getInt(0,"MixA"));
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