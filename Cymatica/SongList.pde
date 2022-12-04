class SongList{
    Player p;
    SongList(Player parent){
        p = parent;
        for (int i = 0; i < songList.size(); i++) {
        JSONObject s = (JSONObject) p.songList.get(i);
        AudioPlayer a = minim.loadFile(s.getString("path"));
        try {
            audio.add(minim.loadFile(s.getString("path")));
            ffts.add(new FFT(a.bufferSize(), a.sampleRate()));
        }
        catch (NullPointerException e){
            incompatible = true;
            continue;
        }
        cp5.addGroup(String.valueOf(i+1)).setGroup("list").setPosition(0,20 + i*60).setWidth(200);
        cp5.addTextlabel("title" + String.valueOf(i)).setGroup(String.valueOf(i+1)).setText(s.getString("title")).setPosition(0,5);
        //cp5.addButton("remove"+ String.valueOf(i)).setPosition(0,20).setGroup(String.valueOf(i+1)).setLabel("Remove").plugTo(this);
        cp5.addButton("play"+String.valueOf(i)).setPosition(0,20).setGroup(String.valueOf(i+1)).setLabel("play").plugTo(p);
        }
    }
}