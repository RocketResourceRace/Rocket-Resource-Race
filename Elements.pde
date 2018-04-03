

class NotificationManager extends Element{
  ArrayList<Notification> notifications;
  int bgColour, textColour, displayNots, notHeight, topOffset, scroll;
  NotificationManager(int x, int y, int w, int h, int bgColour, int textColour, int displayNots){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.bgColour = bgColour;
    this.textColour = textColour;
    this.displayNots = displayNots;
    this.notHeight = h/displayNots;
    this.notifications = new ArrayList<Notification>();
    this.scroll = 1;
    for(int i=0; i < 12; i++)
    notifications.add(new Notification("Building finished: sawmill"+i, 50, 40, i));
  }
  
  boolean moveOver(){
    return mouseX >= x+xOffset && mouseX <= x+w+xOffset && mouseY >= y+yOffset && mouseY <= y+h*notifications.size()+yOffset;
  }
  boolean mouseOver(int i){
    return mouseX >= x+xOffset && mouseX <= x+w+xOffset && mouseY >= y+yOffset+notHeight*i+topOffset && mouseY <= y+notHeight*(i+1)+yOffset+topOffset;
  }
  int findMouseOver(){
    if (!moveOver()){
      return -1;
    }
    for (int i=0; i<notifications.size(); i++){
      if (mouseOver(i)){
        return i;
      }
    }
    return -1;
  }
  
  ArrayList<String> mouseEvent(String eventType, int button, MouseEvent event){
    ArrayList<String> events = new ArrayList<String>();
    if (eventType == "mouseWheel"){
      float count = event.getCount();
      if (moveOver()){
        scroll = round(between(0, scroll+count, notifications.size()-displayNots));
      }
    }
    return events;
  }
  
  void draw(){
    pushStyle();
    fill(bgColour);
    rect(x, y, w, h);
    textSize(10*TextScale);
    fill(brighten(bgColour, -50));
    topOffset = ceil(textAscent()+textDescent());
    this.notHeight = (h-topOffset)/displayNots;
    rect(x, y, w, topOffset);
    fill(textColour);
    textAlign(CENTER, TOP);
    text("Notification Manager", x+w/2, y);
    
    int hovering = findMouseOver();
    for (int i=0; i<min(notifications.size(), displayNots); i++){
      
      if (hovering == i){
        fill(brighten(bgColour, 20));
      }
      else{
        fill(brighten(bgColour, -10));
      }
      rect(x, y+i*notHeight+topOffset, w, notHeight);
      
      fill(brighten(bgColour, -20));
      if (mouseX<x+notHeight){
        if (hovering == i){
          fill(brighten(bgColour, 80));
        }
        else{
          fill(brighten(bgColour, -20));
        }
      }
      rect(x, y+i*notHeight+topOffset, notHeight, notHeight);
      strokeWeight(3);
      line(x+5, y+i*notHeight+topOffset+5, x+notHeight-5, y+(i+1)*notHeight+topOffset-5);
      line(x+notHeight-5, y+i*notHeight+topOffset+5, x+5, y+(i+1)*notHeight+topOffset-5);
      strokeWeight(1);
      
      fill(textColour);
      textSize(8*TextScale);
      textAlign(LEFT, CENTER);
      text(notifications.get(i+scroll).name, x+notHeight+5, y+topOffset+i*notHeight+notHeight/2);
      
      textAlign(RIGHT, CENTER);
      text("Turn "+notifications.get(i+scroll).turn, x-notHeight+w, y+topOffset+i*notHeight+notHeight/2);
    }
    
    //draw scroll
    int d = notifications.size() - displayNots;
    if (d > 0){
      fill(brighten(bgColour, 60));
      rect(x-notHeight+w, y+(h-topOffset-notHeight)*scroll/d+topOffset, notHeight, notHeight);
    }
    
    popStyle();
  }
}



class TextBox extends Element{
  int textSize, bgColour, textColour;
  String text;
  boolean autoSizing;
  
  TextBox(int x, int y, int w, int h, int textSize, String text, int bgColour, int textColour){
    //w=-1 means get width from text
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    if (this.w == -1)
      autoSizing = true;
    else
      autoSizing = false;
    this.textSize = textSize;
    this.bgColour = bgColour;
    this.textColour = textColour;
    setText(text);
  }
  
  void setText(String text){
    this.text = text;
    if (autoSizing){
      textSize(textSize*TextScale);
      this.w = ceil(textWidth(text))+10;
    }
  }
  String getText(){
    return text;
  }
  
  void setColour(int c){
    bgColour = c;
  }
  
  void draw(){
    pushStyle();
    textSize(textSize*TextScale);
    textAlign(CENTER, CENTER);
    rectMode(CORNER);
    if (bgColour != color(255, 255)){
      fill(bgColour);
      rect(x+xOffset, y+yOffset, w, h);
    }
    fill(textColour);
    text(text, x+xOffset+w/2, y+yOffset+h/2);
    popStyle();
  }
}



class ResourceSummary extends Element{
  float[] stockPile, net;
  String[] resNames;
  int numRes, scroll;
  boolean expanded;
  int[] timings;
  
  final int GAP = 10;
  final int FLASHTIMES = 500;
  
  ResourceSummary(int x, int y, int h, String[] resNames, float[] stockPile, float[] net){
    this.x = x;
    this.y = y;
    this.h = h;
    this.resNames = resNames;
    this.numRes = resNames.length;
    this.stockPile = stockPile;
    this.net = net;
    this.expanded = false;
    this.timings = new int[resNames.length];
  }
  
  void updateStockpile(float[] v){
    stockPile = v;
  }
  void updateNet(float[] v){
    net = v;
  }
  void toggleExpand(){
    expanded = !expanded;
  }
  
  String getResString(int i){
    return resNames[i];
  }
  String getStockString(int i){
    String tempString = (new BigDecimal(""+stockPile[i]).divide(new BigDecimal("1"), 1, BigDecimal.ROUND_HALF_EVEN).stripTrailingZeros()).toPlainString();
    return tempString;
  }
  String getNetString(int i){
    String tempString = (new BigDecimal(""+net[i]).divide(new BigDecimal("1"), 1, BigDecimal.ROUND_HALF_EVEN).stripTrailingZeros()).toPlainString();
    if (net[i] >= 0){
      return "+"+tempString;
    }
    return tempString;
  }
  int columnWidth(int i){
    textSize(10*TextScale);
    return ceil(textWidth(getResString(i)));
  }
  int totalWidth(){
    int startRes;
    if (expanded){
      startRes = numRes-1;
    }
    else{
      startRes = 3;
    }
    int tot = 0;
    for (int i=startRes; i>=0; i--)
      tot += columnWidth(i)+GAP;
    return tot;
  }
  
  void flash(int i){
    timings[i] = millis()+FLASHTIMES;
  }
  int getFill(int i){
   if (timings[i] < millis()){
     return color(100);
    }
    return color(155*(timings[i]-millis())/FLASHTIMES+100, 100, 100);
  }
  
  void draw(){
    int cw = 0, startRes;
    int w, yLevel;
    if (expanded){
      startRes = numRes-1;
    }
    else{
      startRes = 3;
    }
    pushStyle();
    textAlign(LEFT, TOP);
    rectMode(CORNERS);
    for (int i=startRes; i>=0; i--){
      w = columnWidth(i);
      fill(getFill(i));
      textSize(10*TextScale);
      rect(width-cw+xOffset+x-GAP/2, yOffset+y, width-cw+xOffset+x-GAP/2-(w+GAP), yOffset+y+textAscent()+textDescent());
      cw += w+GAP;
      line(width-cw+xOffset+x-GAP/2, yOffset+y, width-cw+xOffset+x-GAP/2, yOffset+y+h);
      fill(0);
      
      yLevel=0;
      textSize(10*TextScale);
      text(getResString(i), width-cw+xOffset, y+yOffset);
      yLevel += textAscent()+textDescent();
      
      textSize(8*TextScale);
      text(getStockString(i), width-cw+xOffset, y+yOffset+yLevel);
      yLevel += textAscent()+textDescent();
      
      if (net[i] < 0)
        fill(255,0,0);
      else
        fill(0,255,0);
      textSize(8*TextScale);
      text(getNetString(i), width-cw+xOffset, y+yOffset+yLevel);
      yLevel += textAscent()+textDescent();
    }
    popStyle();
  }
}



class DropDown extends Element{
  ArrayList<String> options;
  ArrayList<Integer> availableOptions;
  int textSize;
  boolean dropped;
  color bgColour, strokeColour;
  private final int HOVERINGOFFSET = 80, ONOFFSET = -50;
  DropDown(int x, int y, int w, int textSize, color bgColour, color strokeColour, String[] options){
    this.x = x;
    this.y = y;
    this.w = w;
    this.textSize = textSize;
    this.h = getH();
    this.bgColour = bgColour;
    this.strokeColour = strokeColour;
    removeAllOptions();
    for (String option : options){
      this.options.add(option);
    }
    dropped = true;
    resetAvailable();
  }
  void setOptions(ArrayList<String> options){
    this.options = options;
  }
  void addOption(String option){
    this.options.add(option);
  }
  void removeOption(String option){
    for (int i=0; i <options.size(); i++){
      if (option.equals(options.get(i))){
        options.remove(i);
      }
    }
  }
  void removeAllOptions(){
    this.options = new ArrayList<String>();
  }
  void resetAvailable(){
    this.availableOptions = new ArrayList<Integer>();
  }
  String getSelected(){
    return options.get(availableOptions.get(0));
  }
  void makeAvailable(String option){
    for (int i=0; i<availableOptions.size(); i++){
      if (options.get(availableOptions.get(i)).equals(option)){
        return;
      }
    }
    for (int i=0; i<options.size(); i++){
      if (options.get(i).equals(option)){
        this.availableOptions.add(i);
        return;
      }
    }
  }
  void makeUnavailable(String option){
    for (int i=0; i<options.size(); i++){
      if (options.get(i).equals(option)){
        this.availableOptions.remove(i);
        return;
      }
    }
  }
  void select(int j){
    int temp = availableOptions.get(0);
    availableOptions.set(0, availableOptions.get(j));
    availableOptions.set(j, temp);
  }
  void select(String s){
    for (int j=0; j<availableOptions.size(); j++){
      if (options.get(availableOptions.get(j)) == s){
        select(j);
      }
    }
  }
  int getH(){
    textSize(textSize*TextScale);
    return ceil(textAscent() + textDescent());
  }
  boolean optionAvailable(int i){
    for (int option : availableOptions){
      if(option == i){
        return true;
      }
    }
    return false;
  }
  void draw(){
    pushStyle();
    h = getH();
    fill(brighten(bgColour, ONOFFSET));
    stroke(strokeColour);
    rect(x+xOffset, y+yOffset, w, h);
    fill(0);
    textAlign(LEFT, TOP);
    text("Current Task: "+options.get(availableOptions.get(0)), x+xOffset+5, y+yOffset);
    
    if (dropped){
      for (int j=1; j< availableOptions.size(); j++){
        if (active && mouseOver(j)){
          fill(brighten(bgColour, HOVERINGOFFSET));
        }
        else{
          fill(bgColour);
        }
        rect(x+xOffset, y+yOffset+h*j, w, h);
        fill(0);
        text(options.get(availableOptions.get(j)), x+xOffset+5, y+yOffset+h*j);
      }
    }
    popStyle();
  }
  
  ArrayList<String> mouseEvent(String eventType, int button){
    ArrayList<String> events = new ArrayList<String>();
    if (eventType == "mouseMoved"){
      active = moveOver();
      
    }
    if (eventType == "mouseClicked" && button == LEFT){
      for (int j=1; j < availableOptions.size();j++){
        if (mouseOver(j)){
          select(j);
          events.add("valueChanged");
        }
      }
    }
    return events;
  }
  
  String findMouseOver(){
    for (int j=0; j<availableOptions.size(); j++){
      if (mouseX >= x+xOffset && mouseX <= x+w+xOffset && mouseY >= y+h*j+yOffset && mouseY <= y+h*(j+1)+yOffset)
        return options.get(availableOptions.get(j));
    }
    return "";
  }
  
  boolean moveOver(){
    return mouseX >= x+xOffset && mouseX <= x+w+xOffset && mouseY >= y+yOffset && mouseY <= y+h*availableOptions.size()+yOffset;
  }
  boolean mouseOver(int j){
    return mouseX >= x+xOffset && mouseX <= x+w+xOffset && mouseY >= y+h*j+yOffset && mouseY <= y+h*(j+1)+yOffset;
  }
}





class Button extends Element{
  private int x, y, w, h, cx, cy, textSize, textAlign;
  private color bgColour, strokeColour, textColour;
  private String state, text;
  private final int HOVERINGOFFSET = 80, ONOFFSET = -50;
  private ArrayList<String> lines;
  
  Button(int x, int y, int w, int h, color bgColour, color strokeColour, color textColour, int textSize, int textAlign, String text){
    state = "off";
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.bgColour = bgColour;
    this.strokeColour = strokeColour;
    this.textColour = textColour;
    this.textSize = textSize;
    this.textAlign = textAlign;
    this.text = text;
    centerCoords();
    
    setLines(text);
  }
  void transform(int x, int y, int w, int h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    centerCoords();
  }
  void centerCoords(){
    cx = x+w/2;
    cy = y+h/2;
  }
  void setText(String text){
    this.text = text;
    setLines(text);
  }
  String getText(){
    return this.text;
  }
  void draw(){
    //println(xOffset, yOffset);
    int padding=0;
    float r = red(bgColour), g = green(bgColour), b = blue(bgColour);
    pushStyle();
    fill(bgColour);
    if (state == "off"){
      fill(bgColour);
    }
    else if (state == "hovering"){
      fill(min(r+HOVERINGOFFSET, 255), min(g+HOVERINGOFFSET, 255), min(b+HOVERINGOFFSET, 255));
    }
    else if (state == "on"){
      fill(min(r+ONOFFSET, 255), min(g+ONOFFSET, 255), min(b+ONOFFSET, 255));
    }
    stroke(strokeColour);
    strokeWeight(3);
    rect(x+xOffset, y+yOffset, w, h);
    noTint();
    fill(textColour);
    textAlign(textAlign, TOP);
    textSize(textSize*TextScale);
    if (lines.size() == 1){
      padding = h/10;
    }
    padding = (lines.size()*(int)(textSize*TextScale)-h/2)/2;
    for (int i=0; i<lines.size(); i++){
      if (textAlign == CENTER){
        text(lines.get(i), cx+xOffset, y+(h*0.9-textSize*TextScale)/2+yOffset);
      }
      else{
        text(lines.get(i), x+xOffset, y + yOffset);
      }
    }
    popStyle();
  }
  
  ArrayList<String> setLines(String s){
    int j = 0;
    lines = new ArrayList<String>();
    for (int i=0; i<s.length(); i++){
      if(s.charAt(i) == '\n'){
        lines.add(s.substring(j, i));
        j=i+1;
      }
    }
    lines.add(s.substring(j, s.length()));
    
    return lines;
  }
  
  ArrayList<String> mouseEvent(String eventType, int button){
    ArrayList<String> events = new ArrayList<String>();
    if(eventType == "mouseReleased"){
      if (state == "on"){
        events.add("clicked");
      }
      state = "off";
    }
    if (mouseOver()){
      if (!state.equals("on")){
        state = "hovering";
      }
      if (eventType == "mousePressed"){
        state = "on";
        if(soundOn){
          sfx.get("click3").play();
        }
      }
    }
    else{
      state = "off";
    }
    return events;
  }
  
  Boolean mouseOver(){
    return mouseX >= x+xOffset && mouseX <= x+w+xOffset && mouseY >= y+yOffset && mouseY <= y+h+yOffset;
  }
}





class Slider extends Element{
  private int x, y, w, h, cx, cy, major, minor, lw, lx;
  private int padding = 20;
  private BigDecimal value, step, upper, lower;
  private float knobSize;
  private color KnobColour, bgColour, strokeColour, scaleColour;
  private boolean horizontal, pressed=false;
  final int boxHeight = 20, boxWidth = 10;
  private final int PRESSEDOFFSET = 50;
  private String name;
  boolean visible = true;
  
  Slider(int x, int y, int w, int h, color KnobColour, color bgColour, color strokeColour, color scaleColour, float lower, float value, float upper, int major, int minor, float step, boolean horizontal, String name){
    this.lx = x;
    this.x = x;
    this.y = y;
    this.lw = w;
    this.w = w;
    this.h = h;
    this.KnobColour = KnobColour;
    this.bgColour = bgColour;
    this.strokeColour = strokeColour;
    this.scaleColour = scaleColour;
    this.major = major;
    this.minor = minor;
    this.upper = new BigDecimal(""+upper);
    this.lower = new BigDecimal(""+lower);
    this.horizontal = horizontal;
    this.step = new BigDecimal(""+step);
    this.value = new BigDecimal(""+value);
    this.name = name;
    scaleKnob();
  }
  void show(){
    visible = true;
  }
  void hide(){
    visible = false;
  }
  void scaleKnob(){
    textSize(8*TextScale);
    this.knobSize = textWidth(""+getInc(new BigDecimal(""+upper)));
  }
  void transform(int x, int y, int w, int h){
    this.lx = x;
    this.x = x;
    this.lw = w;
    this.w = w; 
    this.y = y;
    this.h = h;
  }
  void setScale(float lower, float value, float upper, int major, int minor){
    this.major = major;
    this.minor = minor;
    this.upper = new BigDecimal(""+upper);
    this.lower = new BigDecimal(""+lower);
    this.value = new BigDecimal(""+value);
    scaleKnob();
  }
  
  void setValue(BigDecimal value){
    if (value.compareTo(lower) < 0){
      this.value = lower;
    }
    else if (value.compareTo(upper)>0){
      this.value = new BigDecimal(""+upper);
    }
    else{
      this.value = value.divideToIntegralValue(step).multiply(step);
    }
  }
  
  float getValue(){
    return value.floatValue();
  }
  BigDecimal getPreciseValue(){
    return value;
  }
  
  ArrayList<String> mouseEvent(String eventType, int button){
    ArrayList<String> events = new ArrayList<String>();
    if (button == LEFT){
      if (mouseOver() && eventType == "mousePressed"){
          pressed = true;
          setValue((new BigDecimal(mouseX-x-xOffset)).divide(new BigDecimal(w), 15, BigDecimal.ROUND_HALF_EVEN).multiply(upper.subtract(lower)).add(lower));
          events.add("valueChanged");
      }
      else if (eventType == "mouseReleased"){
        pressed = false;
      }
      if (eventType == "mouseDragged" && pressed){
        setValue((new BigDecimal(mouseX-x-xOffset)).divide(new BigDecimal(w), 15, BigDecimal.ROUND_HALF_EVEN).multiply(upper.subtract(lower)).add(lower));
        events.add("valueChanged");
      }
    }
    return events;
  }
  
  Boolean mouseOver(){
    return mouseX >= x+xOffset && mouseX <= x+w+xOffset && mouseY >= y+yOffset && mouseY <= y+h+yOffset;
  }
  
  BigDecimal getInc(BigDecimal i){
    return i.stripTrailingZeros();
  }
  
  void draw(){
    if (!visible)return;
    BigDecimal range = upper.subtract(lower);
    float r = red(KnobColour), g = green(KnobColour), b = blue(KnobColour);
    pushStyle();
    fill(255, 100);
    stroke(strokeColour, 50);
    //rect(lx, y, lw, h);
    //rect(xOffset+x, y+yOffset+padding+2, w, h-padding);
    stroke(strokeColour);
    
    
    for(int i=0; i<=minor; i++){
      fill(scaleColour);
      line(xOffset+x+w*i/minor, y+yOffset+padding+(h-padding)/6, xOffset+x+w*i/minor, y+yOffset+5*(h-padding)/6+padding);
    }
    for(int i=0; i<=major; i++){
      fill(scaleColour);
      textSize(10*TextScale);
      textAlign(CENTER);
      text(getInc((new BigDecimal(""+i).multiply(range).divide(new BigDecimal(""+major), 15, BigDecimal.ROUND_HALF_EVEN).add(lower))).toPlainString(), xOffset+x+w*i/major, y+yOffset+padding);
      line(xOffset+x+w*i/major, y+yOffset+padding, xOffset+x+w*i/major, y+yOffset+h);
    }
    
    if (pressed){
      fill(min(r-PRESSEDOFFSET, 255), min(g-PRESSEDOFFSET, 255), min(b+PRESSEDOFFSET, 255));
    }
    else{
      fill(KnobColour);
    }
    
    textSize(TextScale*8);
    textAlign(CENTER);
    rectMode(CENTER);
    this.knobSize = max(this.knobSize, textWidth(""+getInc(value)));
    rect(x+value.floatValue()/range.floatValue()*w+xOffset-lower.floatValue()*w/range.floatValue(), y+h/2+yOffset+padding/2, knobSize, boxHeight);
    rectMode(CORNER);
    fill(scaleColour);
    text(getInc(value).toPlainString(), x+value.floatValue()/range.floatValue()*w+xOffset-lower.floatValue()*w/range.floatValue(), y+h/2+boxHeight/4+yOffset+padding/2);
    stroke(0);
    textAlign(CENTER);
    stroke(255, 0, 0);
    line(x+value.floatValue()/range.floatValue()*w+xOffset-lower.floatValue()*w/range.floatValue(), y+h/2-boxHeight/2+yOffset+padding/2, x+value.floatValue()/range.floatValue()*w+xOffset-lower.floatValue()*w/range.floatValue(), y+h/2-boxHeight+yOffset+padding/2);
    stroke(0);
    fill(0);
    textSize(12*TextScale);
    textAlign(LEFT, BOTTOM);
    text(name, x+xOffset, y+yOffset);
    popStyle();
  }
}




class Text extends Element{
  int x, y, size, colour, align;
  PFont font;
  String text;
  
  Text(int x, int y,  int size, String text, color colour, int align){
    this.x = x;
    this.y = y;
    this.size = size;
    this.text = text;
    this.colour = colour;
    this.align = align;
  }
  void translate(int x, int y){
    this.x = x;
    this.y = y;
  }
  void setText(String text){
    this.text = text;
  }
  void calcSize(){
    textSize(size*TextScale);
    this.w = ceil(textWidth(text));
    this.h = ceil(textAscent()+textDescent());
  }
  void draw(){
    calcSize();
    if (font != null){
      textFont(font);
    }
    textAlign(align, TOP);
    textSize(size*TextScale);
    fill(colour);
    text(text, x+xOffset, y+yOffset);
  }
  boolean mouseOver(){
    return mouseX >= x+xOffset && mouseX <= x+w+xOffset && mouseY >= y+yOffset && mouseY <= y+h+yOffset;
  }
}





class TextEntry extends Element{
  StringBuilder text;
  int x, y, w, h, textSize, textAlign, cursor, selected;
  color textColour, boxColour, borderColour, selectionColour;
  String allowedChars, name;
  final int BLINKTIME = 500;
  
  TextEntry(int x, int y, int w, int h, int textAlign, color textColour, color boxColour, color borderColour, String allowedChars){
    this.x = x;
    this.y = y;
    this.h = h;
    this.w = w;
    this.textColour = textColour;
    this.textSize = 10;
    this.textAlign = textAlign;
    this.boxColour = boxColour;
    this.borderColour = borderColour;
    this.allowedChars = allowedChars;
    text = new StringBuilder();
    selectionColour = brighten(selectionColour, 150);
    deactivate();
  }
  TextEntry(int x, int y, int w, int h, int textAlign, color textColour, color boxColour, color borderColour, String allowedChars, String name){
    this.x = x;
    this.y = y;
    this.h = h;
    this.w = w;
    this.textColour = textColour;
    this.textSize = 20;
    this.textAlign = textAlign;
    this.boxColour = boxColour;
    this.borderColour = borderColour;
    this.allowedChars = allowedChars;
    this.name = name;
    text = new StringBuilder();
    selectionColour = brighten(selectionColour, 150);
    deactivate();
  }
  
  void draw(){
    boolean showCursor = ((millis()/BLINKTIME)%2==0 || keyPressed) && active;
    pushStyle();
    
    // Draw a box behind the text
    fill(boxColour);
    stroke(borderColour);
    rect(x+xOffset, y+yOffset, w, h);
    // Draw selection box
    if (selected != cursor && active && cursor >= 0 ){
      fill(selectionColour);
      rect(x+textWidth(text.substring(0, min(cursor, selected)))+xOffset+5, y+2, textWidth(text.substring(min(cursor, selected)+yOffset, max(cursor, selected))), h-4);
    }
    
    // Draw the text
    textSize(textSize*TextScale);
    textAlign(textAlign);
    fill(textColour);
    text(text.toString(), x+xOffset+5, y+yOffset+(h-textSize*TextScale)/2, w, h);
    
    // Draw cursor
    if (showCursor){
      fill(0);
      noStroke();
      rect(x+textWidth(text.toString().substring(0,cursor))+xOffset+5, y+yOffset+(h-textSize*TextScale)/2, 1, textSize*TextScale);
    }
    if (name != null){
      fill(0);
      textSize(10);
      textAlign(LEFT);
      text(name, x, y-12);
    }
    
    popStyle();
  }
  
  void resetSelection(){
    selected = cursor;
  }
  void transform(int x, int y, int w, int h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  
  int getCursorPos(int mx, int my){
    int i=0;
    for(; i<text.length(); i++){
      textSize(textSize*TextScale);
      if (textWidth(text.substring(0, i)) + x > mx)
        break;
    }
    if (0 <= i && i <= text.length() && y+yOffset+(h-textSize*TextScale)/2<= my && my <= y+yOffset+(h-textSize*TextScale)/2+textSize*TextScale){
      return i;
    }
    return cursor;
  }
  
  void doubleSelectWord(){
    if (!(y <= mouseY && mouseY <= y+h)){
      return;
    }
    int c = getCursorPos(mouseX, mouseY);
    int i;
    for (i=min(c, text.length()-1); i>0; i--){
      if (text.charAt(i) == ' '){
        i++;
        break;
      }
    }
    cursor = i;
    for (i=c; i<text.length(); i++){
      if (text.charAt(i) == ' '){
        break;
      }
    }
    selected = i;
  }
  
  ArrayList<String> mouseEvent(String eventType, int button){
    ArrayList<String> events = new ArrayList<String>();
    if (eventType == "mouseClicked"){
      if (button == LEFT){
        if (mouseOver()){
          activate();
        }
      }
    }
    else if (eventType == "mousePressed"){
      if (button == LEFT){
        cursor = getCursorPos(mouseX, mouseY);
        selected = getCursorPos(mouseX, mouseY);
      }
      if(!mouseOver()){
        deactivate();
      }
    }
    else if (eventType == "mouseDragged"){
      if (button == LEFT){
        selected = getCursorPos(mouseX, mouseY);
      }
    }
    else if (eventType == "mouseDoubleClicked"){
      doubleSelectWord();
    }
    return events;
  }
  
  ArrayList<String> keyboardEvent(String eventType, char _key){
    ArrayList<String> events = new ArrayList<String>();
    if (eventType == "keyTyped"){
      if (_key == BACKSPACE){
        if (selected == cursor){
          if (cursor > 0){
            text.deleteCharAt(--cursor);
            resetSelection();
          }
        }
        else{
          text = new StringBuilder(text.substring(0, min(cursor, selected)) + text.substring(max(cursor, selected), text.length()));
          cursor = min(cursor, selected);
          resetSelection();
        }
      }
      else if (_key == '\n'){
        events.add("enterPressed");
        deactivate();
      }
      else if (allowedChars.equals("") || allowedChars.contains(""+_key)){
        if (cursor != selected){
          text = new StringBuilder(text.substring(0, min(cursor, selected)) + text.substring(max(cursor, selected), text.length()));
          cursor = min(cursor, selected);
          resetSelection();
        }
        text.insert(cursor++, _key);
        resetSelection();
      }
    }
    else if (eventType == "keyPressed"){
      if (_key == CODED){
        if (keyCode == LEFT){
          cursor = max(0, cursor-1);
          resetSelection();
        }
        if (keyCode == RIGHT){
          cursor = min(text.length(), cursor+1);
          resetSelection();
        }
      }
    }
    return events;
  }
  
  Boolean mouseOver(){
    return mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h;
  }
}





class ToggleButton extends Element{
  color bgColour, strokeColour;
  String name;
  boolean on;
  ToggleButton(int x, int y, int w, int h, color bgColour, color strokeColour, String name){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.bgColour = bgColour;
    this.strokeColour = strokeColour;
    this.name = name;
  }
  ArrayList<String> mouseEvent(String eventType, int button){
    ArrayList<String> events = new ArrayList<String>();
    if (eventType == "mouseClicked"&&mouseOver()){
      events.add("toggled");
      on = !on;
    }
    return events;
  }
  void transform(int x, int y, int w, int h){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }
  boolean getState(){
    return on;
  }
  void draw(){
    pushStyle();
    fill(bgColour);
    stroke(strokeColour);
    rect(x, y, w, h);
    if (on){
      fill(0, 255, 0);
      rect(x, y, w/2, h);
    }
    else{
      fill(255, 0, 0);
      rect(x+w/2, y, w/2, h);
    }
    fill(0);
    textSize(8*TextScale);
    textAlign(LEFT, BOTTOM);
    text(name, x, y);
    popStyle();
  }
  Boolean mouseOver(){
    return mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h;
  }
}
