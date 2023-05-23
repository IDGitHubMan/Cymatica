class Player {
    Table lib;
    JSONObject settings;
    BufferedReader reader;
    String line;
    String[] ids;
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
    int variety = 0;
    float range = 86;
    float proportion;
    float angleAmount;
    float rotator = 0.0;
    int angleCount;
    int songLastChecked;
    int settingsLastChecked;
    int libLastChecked;
    File songList = new File(sketchPath() + "/data/queue.txt");
    File settingJSON = new File(sketchPath() + "/data/states.json");
    File libraryCSV = new File(sketchPath() + "/data/library.csv");
    
    Player(PApplet applet) {
        lib = loadTable("library.csv","header");
        settings = loadJSONObject("states.json");
        reader = createReader("queue.txt");
        try {
            while ((line = reader.readLine()) != null) {
                ids = split(line, ",");
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
        songLastChecked = (int) songList.lastModified();
        settingsLastChecked = (int) settingJSON.lastModified();
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
            player = new SamplePlayer(ac,sm.sample((String) lib.getString(int(ids[songNumber]),"LocalPath")));
            player.setKillListener(
                new Bead(){
                    protected void messageReceived(Bead b){
                        songNumber += 1;
                        if (songNumber >= ids.length){
                            songNumber = 0; 
                        }
                        player = null;
                    }
                }
            );

            g.addInput(player);
            ac.out.addInput(g);
            ac.start();
        }
        else{
            if(songLastChecked < (int) songList.lastModified()) {
                songLastChecked = (int)songList.lastModified();
                lib = loadTable("library.csv","header");
            }
            if(settingsLastChecked < (int) settingJSON.lastModified()){
                settingsLastChecked = (int) settingJSON.lastModified();
                settings = loadJSONObject("states.json");
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
            
            if(settings.getString("Visualizer").equals("basic")) {
                stroke(lib.getInt(int(ids[songNumber]),"LeftR"),lib.getInt(int(ids[songNumber]),"LeftG"),lib.getInt(int(ids[songNumber]),"LeftB"),lib.getInt(int(ids[songNumber]),"LeftA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map(player.getOutBuffer(0)[i], -1,1,0,height);
                    float h2 = map(player.getOutBuffer(0)[i + 1], -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }
                stroke(lib.getInt(int(ids[songNumber]),"RightR"),lib.getInt(int(ids[songNumber]),"RightG"),lib.getInt(int(ids[songNumber]),"RightB"),lib.getInt(int(ids[songNumber]),"RightA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map(player.getOutBuffer(1)[i], -1,1,0,height);
                    float h2 = map(player.getOutBuffer(1)[i + 1], -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }
                stroke(lib.getInt(int(ids[songNumber]),"MixR"),lib.getInt(int(ids[songNumber]),"MixG"),lib.getInt(int(ids[songNumber]),"MixB"),lib.getInt(int(ids[songNumber]),"MixA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2, -1,1,0,height);
                    float h2 = map((player.getOutBuffer(0)[i + 1] + player.getOutBuffer(1)[i + 1]) / 2, -1,1,0,height);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    line(x,h,x2,h2);
                }   
                noFill();
                stroke(lib.getInt(int(ids[songNumber]),"LeftR"),lib.getInt(int(ids[songNumber]),"LeftG"),lib.getInt(int(ids[songNumber]),"LeftB"),lib.getInt(int(ids[songNumber]),"LeftA"));
                ellipse(width / 2 - 1,height / 2,map(lRMS,0,1,50,height),map(lRMS,0,1,50,height));
                stroke(lib.getInt(int(ids[songNumber]),"RightR"),lib.getInt(int(ids[songNumber]),"RightG"),lib.getInt(int(ids[songNumber]),"RightB"),lib.getInt(int(ids[songNumber]),"RightA"));
                ellipse(width / 2 + 1,height / 2,map(rRMS,0,1,50,height),map(rRMS,0,1,50,height));
                stroke(lib.getInt(int(ids[songNumber]),"MixR"),lib.getInt(int(ids[songNumber]),"MixG"),lib.getInt(int(ids[songNumber]),"MixB"),lib.getInt(int(ids[songNumber]),"MixA"));
                ellipse(width / 2,height / 2,map(mRMS,0,1,50,height),map(mRMS,0,1,50,height));
            }
            else if(settings.getString("Visualizer").equals("iris")) {
                float[] features = ps.getFeatures();
                stroke(lib.getInt(int(ids[songNumber]),"LeftR"),lib.getInt(int(ids[songNumber]),"LeftG"),lib.getInt(int(ids[songNumber]),"LeftB"),lib.getInt(int(ids[songNumber]),"LeftA"));
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
                stroke(lib.getInt(int(ids[songNumber]),"RightR"),lib.getInt(int(ids[songNumber]),"RightG"),lib.getInt(int(ids[songNumber]),"RightB"),lib.getInt(int(ids[songNumber]),"RightA"));
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
                stroke(lib.getInt(int(ids[songNumber]),"MixR"),lib.getInt(int(ids[songNumber]),"MixG"),lib.getInt(int(ids[songNumber]),"MixB"),lib.getInt(int(ids[songNumber]),"MixA"));
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