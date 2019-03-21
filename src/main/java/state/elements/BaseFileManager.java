package state.elements;

import json.JSONManager;
import processing.core.PApplet;
import processing.core.PConstants;
import processing.core.PGraphics;
import processing.event.MouseEvent;
import state.Element;

import java.io.File;
import java.util.ArrayList;
import java.util.logging.Level;

import static util.Logging.LOGGER_MAIN;
import static util.Util.between;
import static util.Util.papplet;

public class BaseFileManager extends Element {
    // Basic file manager that scans a folder and makes a selectable list for all the files
    final int TEXTSIZE = 14, SCROLLWIDTH = 30;
    String folderString;
    String[] saveNames;
    int selected, rowHeight, numDisplayed, scroll;
    boolean scrolling;
    float fakeHeight;


    public BaseFileManager(int x, int y, int w, int h, String folderString) {
        super.x = x;
        super.y = y;
        super.w = w;
        super.h = h;
        this.folderString = folderString;
        saveNames = new String[0];
        selected = 0;
        rowHeight = PApplet.ceil(TEXTSIZE * JSONManager.loadFloatSetting("text scale"))+5;
        scroll = 0;
        scrolling = false;
        updateFakeHeight();
    }

    public void updateFakeHeight() {
        fakeHeight = rowHeight * numDisplayed;
    }

    public String getNextAutoName() {
        // Find the next automatic name for save
        loadSaveNames();
        int mx = 1;
        for (int i=0; i<saveNames.length; i++) {
            if (saveNames[i].length() > 8) {// 'Untitled is 8 characters
                if (saveNames[i].substring(0, 8).equals("Untitled")) {
                    try {
                        mx = PApplet.max(mx, Integer.parseInt(saveNames[i].substring(8)));
                    }
                    catch(NumberFormatException e) {
                        LOGGER_MAIN.log(Level.WARNING, "Save name confusing becuase in autogen format", e);
                    }
                    catch(Exception e) {
                        LOGGER_MAIN.log(Level.SEVERE, "An error occured with finding autogen name", e);
                        throw e;
                    }
                }
            }
        }
        String name = "Untitled"+(mx+1);
        LOGGER_MAIN.info("Created autogenerated file name: " + name);
        return name;
    }

    public void loadSaveNames() {
        try {
            File dir = new File(papplet.sketchPath("saves"));
            if (!dir.exists()) {
                LOGGER_MAIN.info("Creating new 'saves' directory");
                dir.mkdir();
            }
            saveNames = dir.list();
        }
        catch (Exception e) {
            LOGGER_MAIN.log(Level.SEVERE, "Files scanning failed", e);
        }
    }

    public ArrayList<String> mouseEvent(String eventType, int button) {
        ArrayList<String> events = new ArrayList<String>();
        int d = saveNames.length - numDisplayed;
        if (eventType.equals("mouseClicked")) {
            if (moveOver()) {
                if (d <= 0 || papplet.mouseX-xOffset<x+w-SCROLLWIDTH) {
                    // If not hovering over scroll bar, then select item
                    selected = hoveringOption();
                    events.add("valueChanged");
                    scrolling = false;
                }
            }
        } else if (eventType.equals("mousePressed")) {
            if (d > 0 && moveOver() && papplet.mouseX-xOffset>x+w-SCROLLWIDTH) {
                // If hovering over scroll bar, set scroll to mouse pos
                scrolling = true;
                scroll = PApplet.round(between(0, (papplet.mouseY-y-yOffset)*(d+1)/h, d));
            } else {
                scrolling = false;
            }
        } else if (eventType.equals("mouseDragged")) {
            if (scrolling && d > 0) {
                // If scrolling, set scroll to mouse pos
                scroll = PApplet.round(between(0, (papplet.mouseY-y-yOffset)*(d+1)/h, d));
            }
        } else if (eventType.equals("mouseReleased")) {
            scrolling = false;
        }

        return events;
    }

    public ArrayList<String> mouseEvent(String eventType, int button, MouseEvent event) {
        ArrayList<String> events = new ArrayList<String>();
        if (eventType == "mouseWheel") {
            float count = event.getCount();
            if (moveOver()) { // Check mouse over element
                if (saveNames.length > numDisplayed) {
                    scroll = PApplet.round(between(0, scroll+count, saveNames.length-numDisplayed));
                    LOGGER_MAIN.finest("Changing scroll to: "+scroll);
                }
            }
        }
        return events;
    }

    public String selectedSaveName() {
        if (saveNames.length == 0) {
            return "Untitled";
        } else if (saveNames.length <= selected) {
            LOGGER_MAIN.severe("Selected name is out of range " + selected);
        }
        LOGGER_MAIN.info("Selected save name is : " + saveNames[selected]);
        return saveNames[selected];
    }

    public void draw(PGraphics panelCanvas) {

        rowHeight = PApplet.ceil(TEXTSIZE * JSONManager.loadFloatSetting("text scale"))+5;
        updateFakeHeight();

        numDisplayed = PApplet.ceil(h/rowHeight);
        panelCanvas.pushStyle();

        panelCanvas.textSize(TEXTSIZE * JSONManager.loadFloatSetting("text scale"));
        panelCanvas.textAlign(PConstants.LEFT, PConstants.TOP);
        for (int i = scroll; i< PApplet.min(numDisplayed+scroll, saveNames.length); i++) {
            if (selected == i) {
                panelCanvas.strokeWeight(2);
                panelCanvas.fill(papplet.color(100));
            } else {
                panelCanvas.strokeWeight(1);
                panelCanvas.fill(papplet.color(150));
            }
            panelCanvas.rect(x, y+rowHeight*(i-scroll), w, rowHeight);
            panelCanvas.fill(0);
            panelCanvas.text(saveNames[i], x, y+rowHeight*(i-scroll));
        }

        // Draw the scroll bar
        panelCanvas.strokeWeight(2);
        int d = saveNames.length - numDisplayed;
        if (d > 0) {
            panelCanvas.fill(120);
            panelCanvas.rect(x+w-SCROLLWIDTH, y, SCROLLWIDTH, fakeHeight);
            if (scrolling) {
                panelCanvas.fill(40);
            } else {
                panelCanvas.fill(70);
            }
            panelCanvas.stroke(0);
            panelCanvas.rect(x+w-SCROLLWIDTH, y+(fakeHeight-fakeHeight/(d+1))*scroll/d, SCROLLWIDTH, fakeHeight/(d+1));
        }

        panelCanvas.popStyle();
    }

    public boolean moveOver() {
        return papplet.mouseX-xOffset >= x && papplet.mouseX-xOffset <= x+w && papplet.mouseY-yOffset >= y && papplet.mouseY-yOffset <= y+fakeHeight;
    }
    public boolean pointOver() {
        return moveOver();
    }

    public int hoveringOption() {
        int s = (papplet.mouseY-yOffset-y)/rowHeight;
        if (!(0 <= s && s < numDisplayed)) {
            return selected;
        }
        return s+scroll;
    }
}
