class Player {
    Table lib;
    JSONObject settings;
    PGraphics actual;
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
        actual = createGraphics(displayWidth,displayHeight,P3D);
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
        libLastChecked = (int) libraryCSV.lastModified();
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
        if(player == null && ids.length >= 1) {
            player = new SamplePlayer(ac,sm.sample((String) lib.getString(int(ids[songNumber]),"LocalPath")));
            player.setKillListener(
                new Bead(){
                    protected void messageReceived(Bead b){
                        player = null;
                        sm.removeSample((String) lib.getString(int(ids[songNumber]),"LocalPath"));
                        songNumber += 1;
                        if (songNumber >= ids.length){
                            songNumber = 0; 
                        }
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
                reader = createReader("queue.txt");
                try {
                    while ((line = reader.readLine()) != null) {
                        ids = split(line, ",");
                    }
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if(settingsLastChecked < (int) settingJSON.lastModified()){
                settingsLastChecked = (int) settingJSON.lastModified();
                settings = loadJSONObject("states.json");
            }
            if (libLastChecked < (int) libraryCSV.lastModified()){
                libLastChecked = (int) libraryCSV.lastModified();
                lib = loadTable("library.csv","header");
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
            actual.beginDraw();
            color bg1 = color(settings.getJSONArray("bg1").getInt(0),settings.getJSONArray("bg1").getInt(1),settings.getJSONArray("bg1").getInt(2),settings.getJSONArray("bg1").getInt(3));
                color bg2 = color(settings.getJSONArray("bg2").getInt(0),settings.getJSONArray("bg2").getInt(1),settings.getJSONArray("bg2").getInt(2),settings.getJSONArray("bg2").getInt(3));
            if (settings.getBoolean("bgVolLerp")){
                actual.background(actual.lerpColor(bg1, bg2, mRMS));
            }
            else {
                actual.background(bg2);
            }
            if(settings.getString("Visualizer").equals("basic")) {
                actual.stroke(lib.getInt(int(ids[songNumber]),"LeftR"),lib.getInt(int(ids[songNumber]),"LeftG"),lib.getInt(int(ids[songNumber]),"LeftB"),lib.getInt(int(ids[songNumber]),"LeftA"));
                float waveLim = height * settings.getJSONObject("basicSettings").getFloat("waveformLimit");
                float ellipseLim = height * settings.getJSONObject("basicSettings").getFloat("ellipseLimit");
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map(player.getOutBuffer(0)[i], -1,1,height/2-waveLim/2,height/2+waveLim/2);
                    float h2 = map(player.getOutBuffer(0)[i + 1], -1,1,height/2-waveLim/2,height/2+waveLim/2);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    actual.line(x,h,x2,h2);
                }
                actual.stroke(lib.getInt(int(ids[songNumber]),"RightR"),lib.getInt(int(ids[songNumber]),"RightG"),lib.getInt(int(ids[songNumber]),"RightB"),lib.getInt(int(ids[songNumber]),"RightA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map(player.getOutBuffer(1)[i], -1,1,height/2-waveLim/2,height/2+waveLim/2);
                    float h2 = map(player.getOutBuffer(1)[i + 1], -1,1,height/2-waveLim/2,height/2+waveLim/2);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    actual.line(x,h,x2,h2);
                }
                actual.stroke(lib.getInt(int(ids[songNumber]),"MixR"),lib.getInt(int(ids[songNumber]),"MixG"),lib.getInt(int(ids[songNumber]),"MixB"),lib.getInt(int(ids[songNumber]),"MixA"));
                for(int i = 0; i < ac.getBufferSize() - 1; i++) {
                    float h = map((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2, -1,1,height/2-waveLim/2,height/2+waveLim/2);
                    float h2 = map((player.getOutBuffer(0)[i + 1] + player.getOutBuffer(1)[i + 1]) / 2, -1,1,height/2-waveLim/2,height/2+waveLim/2);
                    float x = map(i,0,ac.getBufferSize(),0,width);
                    float x2 = map(i + 1,0,ac.getBufferSize(),0,width);
                    actual.line(x,h,x2,h2);
                }   
                actual.noFill();
                actual.stroke(lib.getInt(int(ids[songNumber]),"LeftR"),lib.getInt(int(ids[songNumber]),"LeftG"),lib.getInt(int(ids[songNumber]),"LeftB"),lib.getInt(int(ids[songNumber]),"LeftA"));
                actual.ellipse(width / 2 - 1,height / 2,map(lRMS,0,1,0,ellipseLim),map(lRMS,0,1,0,ellipseLim));
                actual.stroke(lib.getInt(int(ids[songNumber]),"RightR"),lib.getInt(int(ids[songNumber]),"RightG"),lib.getInt(int(ids[songNumber]),"RightB"),lib.getInt(int(ids[songNumber]),"RightA"));
                actual.ellipse(width / 2 + 1,height / 2,map(rRMS,0,1,0,ellipseLim),map(rRMS,0,1,0,ellipseLim));
                actual.stroke(lib.getInt(int(ids[songNumber]),"MixR"),lib.getInt(int(ids[songNumber]),"MixG"),lib.getInt(int(ids[songNumber]),"MixB"),lib.getInt(int(ids[songNumber]),"MixA"));
                actual.ellipse(width / 2,height / 2,map(mRMS,0,1,0,ellipseLim),map(mRMS,0,1,0,ellipseLim));
                if (settings.getJSONObject("basicSettings").getBoolean("extraEllipses")){

                }
            }
            else if(settings.getString("Visualizer").equals("iris")) {
                float[] features = ps.getFeatures();
                actual.stroke(lib.getInt(int(ids[songNumber]),"LeftR"),lib.getInt(int(ids[songNumber]),"LeftG"),lib.getInt(int(ids[songNumber]),"LeftB"),lib.getInt(int(ids[songNumber]),"LeftA"));
                for(int i1 = 0; i1 <= angleCount; i1 ++) {
                    float start = i1 * angleAmount;
                    if(features != null) {
                        for(int i = 0; i < range; i++) {
                            float angle = map(i,0,range,start,start + angleAmount) + rotator;
                            float x = cos(angle);
                            float y = sin(angle);
                            float fftVal = features[i]*(float)Math.log(i+5)/3;
                            actual.line(width / 2 + 2 + (fftVal + map(lRMS,0,1,100,height)) * x,height / 2 + (fftVal + map(lRMS,0,1,100,height)) * y,width / 2 + 2 + map(lRMS,0,1,100,height) * x,height / 2 + map(lRMS,0,1,100,height) * y);
                        }
                    }
                }
                actual.stroke(lib.getInt(int(ids[songNumber]),"RightR"),lib.getInt(int(ids[songNumber]),"RightG"),lib.getInt(int(ids[songNumber]),"RightB"),lib.getInt(int(ids[songNumber]),"RightA"));
                for(int i1 = 0; i1 <= angleCount; i1 ++) {
                    float start = i1 * angleAmount;
                    if(features != null) {
                        for(int i = 0; i < range; i++) {
                            float angle = map(i,0,range,start,start + angleAmount) + rotator;
                            float x = cos(angle);
                            float y = sin(angle);
                            float fftVal = features[i]*(float)Math.log(i+5)/3;
                            actual.line(width / 2 - 2 + (fftVal + map(rRMS,0,1,100,height)) * x,height / 2 + (fftVal + map(rRMS,0,1,100,height)) * y,width / 2 + 2 + map(rRMS,0,1,100,height) * x,height / 2 + map(rRMS,0,1,100,height) * y);
                        }
                    }
                }
                actual.stroke(lib.getInt(int(ids[songNumber]),"MixR"),lib.getInt(int(ids[songNumber]),"MixG"),lib.getInt(int(ids[songNumber]),"MixB"),lib.getInt(int(ids[songNumber]),"MixA"));
                for(int i1 = 0; i1 <= angleCount; i1 ++) {
                    float start = i1 * angleAmount;
                    if(features != null) {
                        for(int i = 0; i < range; i++) {
                            float angle = map(i,0,range,start,start + angleAmount) + rotator;
                            float x = cos(angle);
                            float y = sin(angle);
                            float fftVal = features[i]*(float)Math.log(i+5)/3;
                            actual.line(width / 2 + (fftVal + map(mRMS,0,1,100,height)) * x,height / 2 + (fftVal + map(mRMS,0,1,100,height)) * y,width / 2 + 2 + map(mRMS,0,1,100,height) * x,height / 2 + map(mRMS,0,1,100,height) * y);
                        }
                    }
                }
                actual.fill(0);
                actual.ellipse(width / 2,height / 2,2 * min(map(lRMS,0,1,100,height),map(rRMS,0,1,100,height),map(mRMS,0,1,100,height)),2 * min(map(lRMS,0,1,100,height),map(rRMS,0,1,100,height),map(mRMS,0,1,100,height)));
            }
        }
        actual.endDraw();
        image(actual,0,0);
    }  
}