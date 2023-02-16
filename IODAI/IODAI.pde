import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

FFT fft;
Minim m;
AudioPlayer audio;
void setup() {
    fullScreen(P3D);
    m = new Minim(this);
    audio = m.loadFile("/Users/isaiahdesrosiers/Downloads/Going Up Now - APNEA (Tower of God M ： The Great Journey OST).wav");
    audio.setGain(0);
    audio.loop();
    fft = new FFT(audio.bufferSize(),audio.sampleRate());
    println(fft.specSize());
    strokeWeight(2);
}

void draw() {
    fill(0,50);
    noStroke();
    rect(0,0,width,height);
    //background(0);
    float rAudLevel = map(audio.right.level(),0,1,0,height);
    float lAudLevel = map(audio.left.level(),0,1,0,height);
    float mAudLevel = map(audio.mix.level(),0,1,0,height);
    float range = 86;
    float proportion = range / fft.specSize();
    float angleAmount = proportion * TWO_PI;
    float angleCount = (TWO_PI) / angleAmount;
    fft.forward(audio.right);
    stroke(255,0,0);
    for (int i1 = 0; i1 < angleCount; i1 ++) {
        float start = i1 * angleAmount;
        for (int i = 0; i < range; i++) {
            float angle = map(i,0,range,start,start + angleAmount);
            float x = cos(angle);
            float y = sin(angle);
            float fftVal = fft.getBand(i) * (float)Math.log(i + 1) / 4;
            line(width / 2 + 2 + (fftVal + rAudLevel) * x,height / 2 + (fftVal + rAudLevel) * y,width / 2 + 2 + rAudLevel * x,height / 2 + rAudLevel * y);
            point(width / 2 + 2 + (fftVal + rAudLevel) * x,height / 2 + (fftVal + rAudLevel) * y);
        }
    }
    fft.forward(audio.left);
    stroke(0,255,255);
    for (int i1 = 0; i1 < angleCount; i1 ++) {
        float start = i1 * angleAmount;
        for (int i = 0; i < range; i++) {
            float angle = map(i,0,range,start,start + angleAmount);
            float x = cos(angle);
            float y = sin(angle);
            float fftVal = fft.getBand(i) * (float)Math.log(i + 1) / 4;
            line(width / 2 - 2 + (fftVal + lAudLevel) * x,height / 2 + (fftVal + lAudLevel) * y,width / 2 - 2 + lAudLevel * x,height / 2 + lAudLevel * y);
            point(width / 2 - 2 + (fftVal + lAudLevel) * x,height / 2 + (fftVal + lAudLevel) * y);
        }
    }
    fft.forward(audio.mix);
    stroke(255);
    for (int i1 = 0; i1 < angleCount; i1 ++) {
        float start = i1 * angleAmount;
        for (int i = 0; i < range; i++) {
            float angle = map(i,0,range,start,start + angleAmount);
            float x = cos(angle);
            float y = sin(angle);
            float fftVal = fft.getBand(i) * (float)Math.log(i + 1) / 4;
            line(width / 2 + (fftVal + mAudLevel) * x,height / 2 + (fftVal + mAudLevel) * y,width / 2 + mAudLevel * x,height / 2 + mAudLevel * y);
            point(width / 2 + (fftVal + mAudLevel) * x,height / 2 + (fftVal + mAudLevel) * y);
        }
    }
}
