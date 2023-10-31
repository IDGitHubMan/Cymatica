class Player{
    boolean playing = false;
    PApplet sketch;
    PGraphics actual;
    Table lib;
    AudioPlayer p;
    Minim minim;
    FFT fft;
    int activeTab = 0;
    int nowPlaying;
    Slider seekbar;
    
    Tab current,albums,artists,playlists,recents,all,settings;
    
    Player(Minim m, Table library, JSONObject settings) {
        minim = m;
        lib = library;
        actual = createGraphics(displayWidth, displayHeight);
    }
    
    void start(int id) {
        if(p != null) {
            p.pause();
            p.close();
        }
        TableRow song = lib.getRow(id - 1);
        p = minim.loadFile(song.getString("path"));
        p.play();
        fft = new FFT(p.bufferSize(),p.sampleRate());
        nowPlaying = id;
        
    }
    
    void display() {
        fill(0,40);
        noStroke();
        rect(0,0,width,height);
        //background(128);
        //colorMode(HSB,360);
        if(p != null) {
            noFill();
            for(int ix = 0; ix <= 4; ix ++) {
                stroke(color(lib.getInt(nowPlaying - 1,"color1")));
                strokeWeight(map(p.left.level(),0,1,0,5));
                ellipse(width / 4 * ix,height / 2,map(p.left.level(),0,1,0,width / 2),map(p.left.level(),0,1,0,width / 2));
                if(ix % 2 == 0) {
                    stroke(color(lib.getInt(nowPlaying - 1,"color2")));
                    strokeWeight(map(p.right.level(),0,1,0,5));
                    ellipse(width / 4 * ix,height / 2,map(p.right.level(),0,1,0,width / 2),map(p.right.level(),0,1,0,width / 2));
                    stroke(255);
                    strokeWeight(map(p.mix.level(),0,1,0,5));
                    ellipse(width / 4 * ix,height / 2,map(p.mix.level(),0,1,0,width / 2),map(p.mix.level(),0,1,0,width / 2));
                }
            }
            for(int ix = 0; ix <= 4; ix ++) {
                if(ix % 2 == 0) {
                    stroke(color(lib.getInt(nowPlaying - 1,"color1")));
                    strokeWeight(map(p.left.level(),0,1,0,5));
                    ellipse(width / 4 * ix,height / 9,map(p.left.level(),0,1,0,width / 2),map(p.left.level(),0,1,0,width / 2));
                    ellipse(width / 4 * ix,height / 9 * 8,map(p.left.level(),0,1,0,width / 2),map(p.left.level(),0,1,0,width / 2));
                }
                else {
                    stroke(color(lib.getInt(nowPlaying - 1,"color2")));
                    strokeWeight(map(p.right.level(),0,1,0,5));
                    ellipse(width / 4 * ix,height / 9,map(p.right.level(),0,1,0,width / 2),map(p.right.level(),0,1,0,width / 2));
                    ellipse(width / 4 * ix,height / 9 * 8,map(p.right.level(),0,1,0,width / 2),map(p.right.level(),0,1,0,width / 2));
                }
            }
            
            stroke(color(lib.getInt(nowPlaying - 1,"color1")));
            strokeWeight(1);
            fft.forward(p.left);
            for(int i = 0; i < fft.specSize(); i++) {
                float xPos = map(i,0,fft.specSize(), width / 2 - 2, -2);
                float xrPos = map(i,0,fft.specSize(),width / 2 + 2,width + 2);
                line(xPos,height - 10,xPos,height - 10 - fft.getBand(i) * (float)Math.log(i + 5) / 4);
                line(xrPos,height - 10,xrPos,height - 10 - fft.getBand(i) * (float)Math.log(i + 5) / 4);
                line(xPos,10,xPos,fft.getBand(i) * (float)Math.log(i + 5) / 4 + 10);
                line(xrPos,10,xrPos,fft.getBand(i) * (float)Math.log(i + 5) / 4 + 10);
            }
            
            stroke(color(lib.getInt(nowPlaying - 1,"color2")));
            fft.forward(p.right);
            for(int i = 0; i < fft.specSize(); i++) {
                float xPos = map(i,0,fft.specSize(),width / 2 + 2,2);
                float xrPos = map(i,0,fft.specSize(),width / 2 - 2,width - 2);
                line(xPos,height - 10,xPos,height - 10 - fft.getBand(i) * (float)Math.log(i + 5) / 4);
                line(xrPos,height - 10,xrPos,height - 10 - fft.getBand(i) * (float)Math.log(i + 5) / 4);
                line(xPos,10,xPos,fft.getBand(i) * (float)Math.log(i + 5) / 4 + 10);
                line(xrPos,10,xrPos,fft.getBand(i) * (float)Math.log(i + 5) / 4 + 10);
            }
            
            stroke(255);
            fft.forward(p.mix);
            for(int i = 0; i < fft.specSize(); i++) {
                float xPos = map(i,0,fft.specSize(),width / 2,0);
                float xrPos = map(i,0,fft.specSize(),width / 2,width);
                line(xPos,height - 10,xPos,height - 10 - fft.getBand(i) * (float)Math.log(i + 5) / 4);
                line(xrPos,height - 10,xrPos,height - 10 - fft.getBand(i) * (float)Math.log(i + 5) / 4);
                line(xPos,10,xPos,fft.getBand(i) * (float)Math.log(i + 5) / 4 + 10);
                line(xrPos,10,xrPos,fft.getBand(i) * (float)Math.log(i + 5) / 4 + 10);
            }
            for(int i = 0; i < p.bufferSize() - 1; i++) {
                float x1 = map(i, 0, p.bufferSize(), 0, width / 2);
                float x2 = map(i + 1, 0, p.bufferSize(), 0, width / 2);
                float xr1 = map(i,0,p.bufferSize(),width,width / 2);
                float xr2 = map(i + 1,0,p.bufferSize(),width,width / 2);
                
                //Left
                stroke(lib.getInt(nowPlaying - 1,"color1"));
                line(x1, height / 2 + map(p.left.get(i), -1,1, -100,100), x2, height / 2 + map(p.left.get(i + 1), -1,1, -100,100));
                line(x1, height / 2 + map(p.left.get(i), -1,1, 100, -100), x2, height / 2 + map(p.left.get(i + 1), -1,1, 100, -100));
                line(xr1, height / 2 + map(p.left.get(i), -1,1, -100,100), xr2, height / 2 + map(p.left.get(i + 1), -1,1, -100,100));
                line(xr1, height / 2 + map(p.left.get(i), -1,1, 100, -100), xr2, height / 2 + map(p.left.get(i + 1), -1,1, 100, -100));
                
                //Right
                stroke(lib.getInt(nowPlaying - 1,"color2"));
                line(x1, height / 2 + map(p.right.get(i), -1,1, -100,100), x2, height / 2 + map(p.right.get(i + 1), -1,1, -100,100));
                line(x1, height / 2 + map(p.right.get(i), -1,1, 100, -100), x2, height / 2 + map(p.right.get(i + 1), -1,1, 100, -100));
                line(xr1, height / 2 + map(p.right.get(i), -1,1, -100,100), xr2, height / 2 + map(p.right.get(i + 1), -1,1, -100,100));
                line(xr1, height / 2 + map(p.right.get(i), -1,1, 100, -100), xr2, height / 2 + map(p.right.get(i + 1), -1,1, 100, -100));
                
                //Mix
                stroke(255);
                line(x1, height / 2 + map(p.mix.get(i), -1,1, -100,100), x2, height / 2 + map(p.mix.get(i + 1), -1,1, -100,100));
                line(x1, height / 2 + map(p.mix.get(i), -1,1, 100, -100), x2, height / 2 + map(p.mix.get(i + 1), -1,1, 100, -100));
                line(xr1, height / 2 + map(p.mix.get(i), -1,1, -100,100), xr2, height / 2 + map(p.mix.get(i + 1), -1,1, -100,100));
                line(xr1, height / 2 + map(p.mix.get(i), -1,1, 100, -100), xr2, height / 2 + map(p.mix.get(i + 1), -1,1, 100, -100));
            }
        }
        else{
            for(float i = 0; i < 360; i += 0.01) {
                //colorMode(HSB,360);
                strokeWeight(0.5);
                //stroke(i,360,360);
                float dist = map(noise(millis() / 1000.0,i),0,1,50,200);
                point(width / 2 + dist * sin(radians(i)),height / 2 + dist * cos(radians(i)));
            }
        }
        colorMode(RGB,255);
        if(activeTab != 0) {
            fill(0,128);
            noStroke();
            rect(0,0,width,height);
        }
    }
}
