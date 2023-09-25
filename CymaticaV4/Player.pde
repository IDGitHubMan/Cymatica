class Player{
    PApplet sketch;
    PGraphics actual;
    JSONObject setting;
    Table lib;
    File settingJSON = new File(dataPath("") + "/states.json");
    File libraryCSV = new File(dataPath("") + "/library.csv");
    
    Player(PApplet s) {
        sketch = s;
        actual = createGraphics(displayWidth, displayHeight, P3D);
        if(settingJSON.exists()) {
            setting = loadJSONObject("states.json");
        }
        else {
            PrintWriter output = createWriter(dataPath("") + "/states.json");
            output.println("{");
            output.println("\t\"Visualizer\":1,");
            output.println("\t\"VisualizerSpeciation\": 0,");
            output.println("\t\"overlay\": 1,");
            output.println("\t\"overlaySpace\": 10,");
            output.println("\t\"channel_diff\": true,");
            output.println("\t\"playback\":{");
            output.println("\t\t\"progress\":0,");
            output.println("\t\t\"volume\":1,");
            output.println("\t\t\"loop\":true,");
            output.println("\t\t\"shuffle\":true,");
            output.println("\t\t\"song\":0");
            output.println("\t},");
            output.println("\t\"basic_opts\":{");
            output.println("\t\t\"extra_ellipses\":0,");
            output.println("\t\t\"waveform_limit\":0.5,");
            output.println("\t\t\"ellipse_limit\":0.3");
            output.println("\t},");
            output.println("\t\"iris_opts\":{");
            output.println("\t\t\"rotation\":true,");
            output.println("\t\t\"lower_bound\":0,");
            output.println("\t\t\"upper_bound\":100,");
            output.println("\t\t\"hollow\":true,");
            output.println("\t\t\"shape\":0");
            output.println("\t}");
            output.println("} ");
            output.flush();
            output.close();
            setting = loadJSONObject("states.json");
        }
        
        if(libraryCSV.exists()) {
            lib = loadTable("library.csv", "header");
        }
        else {
            Table t = new Table();
            t.addColumn("id");
            t.addColumn("path");
            t.addColumn("color1");
            t.addColumn("color2");
            t.addColumn("color3");
            t.addColumn("laserToggle");
            t.addColumn("laserMin");
            t.addColumn("laserMax");
            t.addColumn("laserThreshold");
            t.addColumn("lineToggle");
            t.addColumn("lineMin");
            t.addColumn("lineMax");
            t.addColumn("lineThreshold");
            t.addColumn("sparkToggle");
            t.addColumn("sparkMin");
            t.addColumn("sparkMax");
            t.addColumn("sparkThreshold");
            saveTable(t,"data/library.csv");
            lib = loadTable("library.csv", "header");
        }
    }
}
