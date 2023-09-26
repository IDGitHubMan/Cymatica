JSONObject data;
JSONArray sections, bars, tatums;
float[] times;
boolean changing;
int section = 0;
float size = 20;
void setup() {
  size(600, 200);
  data = loadJSONObject("ram.json");
  sections = data.getJSONArray("segments");
  tatums = data.getJSONArray("tatums");
}

void draw() {
  float jitter = map(size, 20, min(height, width), 0, 25);
  float w = map(size, 20, min(height, width), 0, 5);
  strokeWeight(w);
  ellipse(width/2+random(-jitter, jitter), height/2+random(-jitter, jitter), size, size);
  if (size > 20) {
    size -= 4;
  }
  if (changing) {
    fill(random(255), random(255), random(255), random(255));
    stroke(random(255), random(255), random(255), random(255));
    JSONArray pitches = sections.getJSONObject(section).getJSONArray("pitches");
    for (int i = 0; i <pitches.size(); i++) {
      float x = map(i, 0, 7, 0, width);
      rect(x, height, width/pitches.size(), -map(pitches.getFloat(i), 0, 1, 0, height));
    }
    println(sections.getJSONObject(section).getJSONArray("pitches"));
    size = min(height, width);
    changing = false;
  } else {
    fill(51, 50);
    rect(0, 0, width, height);
    if (millis() <= data.getJSONObject("track").getFloat("duration")*1000) {
      checkChange();
    }
  }
}

void checkChange() {
  for (int i=section; i < sections.size(); i++) {
    //ellipse(mouseX,mouseY,20,20);
    JSONObject s = sections.getJSONObject(i);
    if (millis() > s.getFloat("start") + s.getFloat("duration")) {
      changing = true;
      section += 1;
      break;
    }
  }
}
