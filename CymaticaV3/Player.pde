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
  float mRMS, lRMS, rRMS;
  int angleCount;
  int songLastChecked;
  int settingsLastChecked;
  int libLastChecked;
  File songList = new File(sketchPath() + "/data/queue.txt");
  File settingJSON = new File(sketchPath() + "/data/states.json");
  File libraryCSV = new File(sketchPath() + "/data/library.csv");
  color bg1, bg2;

  Player(PApplet applet) {
    actual = createGraphics(displayWidth, displayHeight, P3D);
    lib = loadTable("library.csv", "header");
    settings = loadJSONObject("states.json");
    reader = createReader("queue.txt");
    try {
      while ((line = reader.readLine()) != null) {
        ids = split(line, ",");
      }
      reader.close();
    }
    catch (IOException e) {
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
    ac.out.addInput(g);
    proportion = range / ac.getBufferSize();
    angleAmount = proportion * TWO_PI;
    angleCount = floor((TWO_PI) / angleAmount);
  }

  void run() {
    if (settings.getJSONObject("irisSettings").getBoolean("rotation")) {
      rotator += 0.01;
    }
    if (player == null && ids.length >= 1) {
      player = new SamplePlayer(ac, sm.sample((String) lib.getString(int(ids[songNumber]), "OrigPath")));
      player.setKillListener(
        new Bead() {
        protected void messageReceived(Bead b) {
          player = null;
          sm.removeSample((String) lib.getString(int(ids[songNumber]), "OrigPath"));
          songNumber += 1;
          if (songNumber >= ids.length) {
            songNumber = 0;
          }
        }
      }
      );
      g.clearInputConnections();
      g.addInput(player);
      ac.start();
    } else {
      if (songLastChecked < (int) songList.lastModified()) {
        songLastChecked = (int)songList.lastModified();
        reader = createReader("queue.txt");
        try {
          while ((line = reader.readLine()) != null) {
            ids = split(line, ",");
          }
          reader.close();
        }
        catch (IOException e) {
          e.printStackTrace();
        }
      }
      if (settingsLastChecked < (int) settingJSON.lastModified()) {
        settingsLastChecked = (int) settingJSON.lastModified();
        settings = loadJSONObject("states.json");
      }
      if (libLastChecked < (int) libraryCSV.lastModified()) {
        libLastChecked = (int) libraryCSV.lastModified();
        lib = loadTable("library.csv", "header");
      }
    }
    if (player != null) {
      float lSum = 0;
      for (int i = 0; i < ac.getBufferSize() - 1; i++) {
        lSum += player.getOutBuffer(0)[i] * player.getOutBuffer(0)[i];
      }
      lRMS = (float) Math.sqrt(lSum / ac.getBufferSize());

      float rSum = 0;
      for (int i = 0; i < ac.getBufferSize() - 1; i++) {
        rSum += player.getOutBuffer(1)[i] * player.getOutBuffer(1)[i];
      }
      rRMS = (float) Math.sqrt(rSum / ac.getBufferSize());

      float mSum = 0;
      for (int i = 0; i < ac.getBufferSize() - 1; i++) {
        mSum += ((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2) * ((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2);
      }
      mRMS = (float) Math.sqrt(mSum / ac.getBufferSize());
      actual.beginDraw();
      bg1 = color(lib.getInt(songNumber, "BG1R"), lib.getInt(songNumber, "BG1G"), lib.getInt(songNumber, "BG1B"), lib.getInt(songNumber, "BG1A"));
      bg2 = color(lib.getInt(songNumber, "BG2R"), lib.getInt(songNumber, "BG2G"), lib.getInt(songNumber, "BG2B"), lib.getInt(songNumber, "BG2A"));
      if (settings.getBoolean("bgVolLerp")) {
        actual.noStroke();
        actual.fill(actual.lerpColor(bg1, bg2, mRMS));
        actual.rect(0, 0, width, height);
      } else {
        actual.noStroke();
        actual.fill(actual.lerpColor(bg1, bg2, 0.5));
        actual.rect(0, 0, width, height);
      }
      if (settings.getInt("Visualizer") == 0) {
        actual.stroke(lib.getInt(int(ids[songNumber]), "LeftR"), lib.getInt(int(ids[songNumber]), "LeftG"), lib.getInt(int(ids[songNumber]), "LeftB"), lib.getInt(int(ids[songNumber]), "LeftA"));
        float waveLim = height * settings.getJSONObject("basicSettings").getFloat("waveformLimit");
        float ellipseLim = height * settings.getJSONObject("basicSettings").getFloat("ellipseLimit");
        for (int i = 0; i < ac.getBufferSize() - 1; i++) {
          float h = map(player.getOutBuffer(0)[i], -1, 1, height/2-waveLim/2, height/2+waveLim/2);
          float h2 = map(player.getOutBuffer(0)[i + 1], -1, 1, height/2-waveLim/2, height/2+waveLim/2);
          float x = map(i, 0, ac.getBufferSize(), 0, width);
          float x2 = map(i + 1, 0, ac.getBufferSize(), 0, width);
          actual.line(x, h, x2, h2);
        }
        actual.stroke(lib.getInt(int(ids[songNumber]), "RightR"), lib.getInt(int(ids[songNumber]), "RightG"), lib.getInt(int(ids[songNumber]), "RightB"), lib.getInt(int(ids[songNumber]), "RightA"));
        for (int i = 0; i < ac.getBufferSize() - 1; i++) {
          float h = map(player.getOutBuffer(1)[i], -1, 1, height/2-waveLim/2, height/2+waveLim/2);
          float h2 = map(player.getOutBuffer(1)[i + 1], -1, 1, height/2-waveLim/2, height/2+waveLim/2);
          float x = map(i, 0, ac.getBufferSize(), 0, width);
          float x2 = map(i + 1, 0, ac.getBufferSize(), 0, width);
          actual.line(x, h, x2, h2);
        }
        actual.stroke(lib.getInt(int(ids[songNumber]), "MixR"), lib.getInt(int(ids[songNumber]), "MixG"), lib.getInt(int(ids[songNumber]), "MixB"), lib.getInt(int(ids[songNumber]), "MixA"));
        for (int i = 0; i < ac.getBufferSize() - 1; i++) {
          float h = map((player.getOutBuffer(0)[i] + player.getOutBuffer(1)[i]) / 2, -1, 1, height/2-waveLim/2, height/2+waveLim/2);
          float h2 = map((player.getOutBuffer(0)[i + 1] + player.getOutBuffer(1)[i + 1]) / 2, -1, 1, height/2-waveLim/2, height/2+waveLim/2);
          float x = map(i, 0, ac.getBufferSize(), 0, width);
          float x2 = map(i + 1, 0, ac.getBufferSize(), 0, width);
          actual.line(x, h, x2, h2);
        }
        actual.noFill();
        actual.stroke(lib.getInt(int(ids[songNumber]), "LeftR"), lib.getInt(int(ids[songNumber]), "LeftG"), lib.getInt(int(ids[songNumber]), "LeftB"), lib.getInt(int(ids[songNumber]), "LeftA"));
        actual.ellipse(width / 2 - 1, height / 2, map(lRMS, 0, 1, 0, ellipseLim), map(lRMS, 0, 1, 0, ellipseLim));
        actual.stroke(lib.getInt(int(ids[songNumber]), "RightR"), lib.getInt(int(ids[songNumber]), "RightG"), lib.getInt(int(ids[songNumber]), "RightB"), lib.getInt(int(ids[songNumber]), "RightA"));
        actual.ellipse(width / 2 + 1, height / 2, map(rRMS, 0, 1, 0, ellipseLim), map(rRMS, 0, 1, 0, ellipseLim));
        actual.stroke(lib.getInt(int(ids[songNumber]), "MixR"), lib.getInt(int(ids[songNumber]), "MixG"), lib.getInt(int(ids[songNumber]), "MixB"), lib.getInt(int(ids[songNumber]), "MixA"));
        actual.ellipse(width / 2, height / 2, map(mRMS, 0, 1, 0, ellipseLim), map(mRMS, 0, 1, 0, ellipseLim));
        if (settings.getJSONObject("basicSettings").getBoolean("extraEllipses")) {
        }
      } else if (settings.getInt("Visualizer") == 1) {
        float[] features = ps.getFeatures();
        actual.stroke(lib.getInt(int(ids[songNumber]), "LeftR"), lib.getInt(int(ids[songNumber]), "LeftG"), lib.getInt(int(ids[songNumber]), "LeftB"), lib.getInt(int(ids[songNumber]), "LeftA"));
        if (settings.getJSONObject("irisSettings").getInt("shapeType") != 2) {
          for (int i1 = 0; i1 <= angleCount; i1 ++) {
            float start = i1 * angleAmount;
            if (features != null) {
              for (int i = 0; i < range; i++) {
                float angle = map(i, 0, range, start, start + angleAmount) + rotator;
                float x = cos(angle);
                float y = sin(angle);
                float fftVal = features[i]*i/sqrt(features.length);
                if (settings.getJSONObject("irisSettings").getInt("shapeType") == 1) {
                  actual.strokeWeight(1);
                  actual.line(width / 2 - 2 + (fftVal + map(lRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(lRMS, 0, 1, 1, height)) * y, width / 2 + 2 + map(lRMS, 0, 1, 1, height) * x, height / 2 + map(lRMS, 0, 1, 1, height) * y);
                } else {
                  actual.strokeWeight(3);
                  actual.point(width / 2 - 2 + (fftVal + map(lRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(lRMS, 0, 1, 1, height)) * y);
                }
              }
            }
          }
        } else {
          if (settings.getJSONObject("irisSettings").getBoolean("hollow")) {
            actual.noFill();
          } else {
            actual.fill(lib.getInt(int(ids[songNumber]), "LeftR"), lib.getInt(int(ids[songNumber]), "LeftG"), lib.getInt(int(ids[songNumber]), "LeftB"), lib.getInt(int(ids[songNumber]), "LeftA"));
          }
          actual.strokeWeight(1);
          actual.beginShape();
          for (int i1 = 0; i1 <= angleCount; i1 ++) {
            float start = i1 * angleAmount;
            if (features != null) {
              for (int i = 0; i < range; i++) {
                float angle = map(i, 0, range, start, start+angleAmount)+rotator;
                float x = cos(angle);
                float y = sin(angle);
                float fftVal = features[i]*i/sqrt(features.length);
                actual.vertex(width / 2 - 2 + (fftVal + map(lRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(lRMS, 0, 1, 1, height)) * y);
              }
            }
          }
          actual.endShape();
        }
        actual.stroke(lib.getInt(int(ids[songNumber]), "RightR"), lib.getInt(int(ids[songNumber]), "RightG"), lib.getInt(int(ids[songNumber]), "RightB"), lib.getInt(int(ids[songNumber]), "RightA"));
        if (settings.getJSONObject("irisSettings").getInt("shapeType") != 2) {
          for (int i1 = 0; i1 <= angleCount; i1 ++) {
            float start = i1 * angleAmount;
            if (features != null) {
              for (int i = 0; i < range; i++) {
                float angle = map(i, 0, range, start, start + angleAmount) + rotator;
                float x = cos(angle);
                float y = sin(angle);
                float fftVal = features[i]*i/sqrt(features.length);
                if (settings.getJSONObject("irisSettings").getInt("shapeType") == 1) {
                  actual.strokeWeight(1);
                  actual.line(width / 2 + 2 + (fftVal + map(rRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(rRMS, 0, 1, 1, height)) * y, width / 2 + 2 + map(rRMS, 0, 1, 1, height) * x, height / 2 + map(rRMS, 0, 1, 1, height) * y);
                } else {
                  actual.strokeWeight(3);
                  actual.point(width / 2 + 2 + (fftVal + map(rRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(rRMS, 0, 1, 1, height)) * y);
                }
              }
            }
          }
        } else {
          if (settings.getJSONObject("irisSettings").getBoolean("hollow")) {
            actual.noFill();
          } else {
            actual.fill(lib.getInt(int(ids[songNumber]), "RightR"), lib.getInt(int(ids[songNumber]), "RightG"), lib.getInt(int(ids[songNumber]), "RightB"), lib.getInt(int(ids[songNumber]), "RightA"));
          }
          actual.strokeWeight(1);
          actual.beginShape();
          for (int i1 = 0; i1 <= angleCount; i1 ++) {
            float start = i1 * angleAmount;
            if (features != null) {
              for (int i = 0; i < range; i++) {
                float angle = map(i, 0, range, start, start+angleAmount)+rotator;
                float x = cos(angle);
                float y = sin(angle);
                float fftVal = features[i]*i/sqrt(features.length);
                actual.vertex(width / 2 + 2 + (fftVal + map(rRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(rRMS, 0, 1, 1, height)) * y);
              }
            }
          }
          actual.endShape();
        }
        actual.stroke(lib.getInt(int(ids[songNumber]), "MixR"), lib.getInt(int(ids[songNumber]), "MixG"), lib.getInt(int(ids[songNumber]), "MixB"), lib.getInt(int(ids[songNumber]), "MixA"));
        if (settings.getJSONObject("irisSettings").getInt("shapeType") != 2) {
          for (int i1 = 0; i1 <= angleCount; i1 ++) {
            float start = i1 * angleAmount;
            if (features != null) {
              for (int i = 0; i < range; i++) {
                float angle = map(i, 0, range, start, start + angleAmount) + rotator;
                float x = cos(angle);
                float y = sin(angle);
                float fftVal = features[i]*i/sqrt(features.length);
                if (settings.getJSONObject("irisSettings").getInt("shapeType") == 1) {
                  actual.strokeWeight(1);
                  actual.line(width / 2 + (fftVal + map(mRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(mRMS, 0, 1, 1, height)) * y, width / 2 + 2 + map(mRMS, 0, 1, 1, height) * x, height / 2 + map(mRMS, 0, 1, 1, height) * y);
                } else {
                  actual.strokeWeight(3);
                  actual.point(width / 2 + (fftVal + map(mRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(mRMS, 0, 1, 1, height)) * y);
                }
              }
            }
          }
          if (!settings.getJSONObject("irisSettings").getBoolean("hollow")) {
            actual.fill(0);
          } else {
            actual.noFill();
          }
          actual.ellipse(width / 2, height / 2, 2 * min(map(lRMS, 0, 1, 1, height), map(rRMS, 0, 1, 1, height), map(mRMS, 0, 1, 1, height)), 2 * min(map(lRMS, 0, 1, 1, height), map(rRMS, 0, 1, 1, height), map(mRMS, 0, 1, 1, height)));
        } else {
          if (settings.getJSONObject("irisSettings").getBoolean("hollow")) {
            actual.noFill();
          } else {
            actual.fill(lib.getInt(int(ids[songNumber]), "MixR"), lib.getInt(int(ids[songNumber]), "MixG"), lib.getInt(int(ids[songNumber]), "MixB"), lib.getInt(int(ids[songNumber]), "MixA"));
          }
          actual.strokeWeight(1);
          actual.beginShape();
          for (int i1 = 0; i1 <= angleCount; i1 ++) {
            float start = i1 * angleAmount;
            if (features != null) {
              for (int i = 0; i < range; i++) {
                float angle = map(i, 0, range, start, start+angleAmount)+rotator;
                float x = cos(angle);
                float y = sin(angle);
                float fftVal = features[i]*i/sqrt(features.length);
                actual.vertex(width / 2 + (fftVal + map(mRMS, 0, 1, 1, height)) * x, height / 2 + (fftVal + map(mRMS, 0, 1, 1, height)) * y);
              }
            }
          }
          actual.endShape();
        }
      }
    }
    actual.endDraw();
    actual.updatePixels();
    image(actual, 0, 0);
    float reach = map(mRMS, 0, 1, 1, 100);
    float weight = map(mRMS, 0, 1, 1, 10);
    int space = settings.getInt("overlaySpace");
    actual.loadPixels();
    for (int ix = 0; ix < width; ix += space) {
      for (int iy = 0; iy < height; iy += space) {
        if (settings.getBoolean("bgVolLerp")) {
          if (red(actual.pixels[ix + (iy*actual.width)]) - red(actual.lerpColor(bg1, bg2, mRMS)) <= 10 && green(actual.pixels[ix + (iy*actual.width)]) - green(actual.lerpColor(bg1, bg2, mRMS)) <= 10 && blue(actual.pixels[ix + (iy*actual.width)]) - blue(actual.lerpColor(bg1, bg2, mRMS)) <= 10) {
          } else {
            stroke(color(actual.pixels[ix + (iy*actual.width)]));
            strokeWeight(weight);
            if (settings.getInt("overlay") == 1) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix-random(-reach, reach), iy-random(-reach, reach), ix+random(-reach, reach), iy+random(-reach, reach));
            } else if (settings.getInt("overlay") == 2) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix, iy, ix+random(-reach, reach), iy);
              line(ix, iy, ix, iy+random(-reach, reach));
            } else if (settings.getInt("overlay") == 3) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix-map(noise(ix, iy, (float)millis()/1000), 0, 1, -reach, reach), iy-map(noise(ix, iy, (float)millis()/1000), 0, 1, -reach, reach), ix+map(noise(ix, iy, (float)millis()/1000), 0, 1, -reach, reach), iy+map(noise(ix, iy, (float)millis()/1000), 0, 1, -reach, reach));
            } else if (settings.getInt("overlay") == 4) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix, iy - map(noise(ix, iy, ix + (float)millis() / 1000), 0, 1, 0, reach), ix, iy + map(noise(ix, iy, (float)millis() / 1000), 0, 1, 0, reach));
              line(ix - map(noise(ix, iy, ix + (float)millis() / 1000), 0, 1, 0, reach), iy, ix + map(noise(ix, iy, ix + (float)millis() / 1000), 0, 1, 0, reach), iy);
            } else if (settings.getInt("overlay") == 5) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix, iy, ix+reach, iy+reach);
            } else if (settings.getInt("overlay") == 6) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix-reach, iy-reach, ix, iy);
            } else if (settings.getInt("overlay") == 8) {
              reach = map(mRMS, 0, 1, 1, 100);
              noFill();
              ellipse(ix, iy, random(-reach, reach), random(-reach, reach));
            } else if (settings.getInt("overlay") == 7) {
              reach = map(mRMS, 0, 1, 1, 500);
              strokeWeight(map(mRMS, 0, 1, 1, 20));
              point(ix + random(-reach, reach), iy + random(-reach, reach));
            } else if (settings.getInt("overlay") == 9) {
              reach = map(mRMS, 0, 1, 1, 100);
              noFill();
              rect(ix-reach/2, iy-reach/2, reach, reach);
            } else if (settings.getInt("overlay") == 10) {
              reach = map(mRMS, 0, 1, 1, 100);
              noFill();
              float w = random(reach);
              float h = random(reach);
              rect(ix-w/2, iy-h/2, w, h);
            }
          }
        } else {
          if (red(actual.pixels[ix + (iy*actual.width)]) - red(actual.lerpColor(bg1, bg2, 0.5)) <= 10 && green(actual.pixels[ix + (iy*actual.width)]) - green(actual.lerpColor(bg1, bg2, 0.5)) <= 10 && blue(actual.pixels[ix + (iy*actual.width)]) - blue(actual.lerpColor(bg1, bg2, 0.5)) <= 10) {
          } else {
            stroke(color(actual.pixels[ix + (iy*actual.width)]));
            strokeWeight(weight);
            if (settings.getInt("overlay") == 1) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix-random(-reach, reach), iy-random(-reach, reach), ix+random(-reach, reach), iy+random(-reach, reach));
            } else if (settings.getInt("overlay") == 2) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix, iy, ix+random(-reach, reach), iy);
              line(ix, iy, ix, iy+random(-reach, reach));
            } else if (settings.getInt("overlay") == 3) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix-map(noise(ix, iy, (float)millis()/1000), 0, 1, -reach, reach), iy-map(noise(ix, iy, (float)millis()/1000), 0, 1, -reach, reach), ix+map(noise(ix, iy, (float)millis()/1000), 0, 1, -reach, reach), iy+map(noise(ix, iy, (float)millis()/1000), 0, 1, -reach, reach));
            } else if (settings.getInt("overlay") == 4) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix, iy - map(noise(ix, iy, ix + (float)millis() / 1000), 0, 1, 0, reach), ix, iy + map(noise(ix, iy, (float)millis() / 1000), 0, 1, 0, reach));
              line(ix - map(noise(ix, iy, ix + (float)millis() / 1000), 0, 1, 0, reach), iy, ix + map(noise(ix, iy, ix + (float)millis() / 1000), 0, 1, 0, reach), iy);
            } else if (settings.getInt("overlay") == 5) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix, iy, ix+reach, iy+reach);
            } else if (settings.getInt("overlay") == 6) {
              reach = map(mRMS, 0, 1, 1, 100);
              line(ix-reach, iy-reach, ix, iy);
            } else if (settings.getInt("overlay") == 8) {
              reach = map(mRMS, 0, 1, 1, 100);
              noFill();
              ellipse(ix, iy, random(-reach, reach), random(-reach, reach));
            } else if (settings.getInt("overlay") == 7) {
              reach = map(mRMS, 0, 1, 1, 500);
              strokeWeight(map(mRMS, 0, 1, 1, 20));
              point(ix + random(-reach, reach), iy + random(-reach, reach));
            } else if (settings.getInt("overlay") == 9) {
              reach = map(mRMS, 0, 1, 1, 100);
              noFill();
              rect(ix-reach/2, iy-reach/2, reach, reach);
            } else if (settings.getInt("overlay") == 10) {
              reach = map(mRMS, 0, 1, 1, 100);
              noFill();
              float w = random(reach);
              float h = random(reach);
              rect(ix-w/2, iy-h/2, w, h);
            }
          }
        }
      }
    }
  }
}
