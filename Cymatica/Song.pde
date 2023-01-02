public class Song{
    Minim m;
    FFT fft;
    AudioPlayer audio;
    String artist, title, album, path;
    PImage art;
    int position;
    AudioMetaData meta;
    color leftColor, rightColor, mixColor;
    boolean laserEffect, sparkEffect, lineEffect;
    int laserBandMin, laserBandMax, sparkBandMin, sparkBandMax, lineBandMin, lineBandMax;

    Song(Minim minim, String p, int n){
        path = p;
        m = minim;
        audio = m.loadFile(path);
        meta = audio.getMetaData();
        leftColor = color(0,255,255);
        rightColor = color(255,0,0);
        mixColor = color(255);
        fft = new FFT(audio.bufferSize(),audio.sampleRate());
        if (meta.title() != "") {
            title = meta.title();
        } else {
            title = meta.fileName().substring(meta.fileName().lastIndexOf("/")+1,meta.fileName().length()-4);
        }
        artist = meta.author();
        album = meta.album();
        position = n;
    }

    Song(Minim minim, String path, String art, String t, String alb, int pos, color lColor, color rColor, color mColor){
        m = minim;
        audio = m.loadFile(path);
        meta = audio.getMetaData();
        fft = new FFT(audio.bufferSize(),audio.sampleRate());
        artist = art;
        title = t;
        album = alb;
        position = pos;
        leftColor = lColor;
        rightColor = rColor;
        mixColor = mColor;
    }
}