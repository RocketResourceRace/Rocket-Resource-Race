
class TextEntry extends Element{
  StringBuilder text;
  int x, y, w, h, textSize, textAlign, cursor, selected;
  color textColour, boxColour, borderColour, selectionColour;
  String allowedChars;
  final int BLINKTIME = 500;
  
  TextEntry(int x, int y, int w, int h, int textSize, int textAlign, color textColour, color boxColour, color borderColour, String allowedChars){
    this.x = x;
    this.y = y;
    this.h = h;
    this.w = w;
    this.textColour = textColour;
    this.textSize = textSize;
    this.textAlign = textAlign;
    this.boxColour = boxColour;
    this.borderColour = borderColour;
    this.allowedChars = allowedChars;
    text = new StringBuilder();
    selectionColour = brighten(selectionColour, 150);
  }
  
  void draw(int xOffset, int yOffest){
    boolean showCursor = ((millis()/BLINKTIME)%2==0 || keyPressed) && active;
    pushStyle();
    
    // Draw a box behind the text
    fill(boxColour);
    stroke(borderColour);
    rect(x, y, w, h);
    
    // Draw selection box
    if (selected != cursor){
      fill(selectionColour);
      rect(x+textWidth(text.substring(0, min(cursor, selected))), y, textWidth(text.substring(min(cursor, selected), max(cursor, selected))), textSize);
    }
    
    // Draw the text
    textSize(textSize);
    textAlign(textAlign);
    fill(textColour);
    text(text.toString(), x, y+textSize);
    
    // Draw cursor
    if (showCursor){
      fill(0);
      rect(x+textWidth(text.toString().substring(0,cursor)), y, 1, textSize);
    }
    
    popStyle();
  }
  
  void resetSelection(){
    selected = cursor;
  }
  
  int getCursorPos(int mx, int my){
    int i=0;
    for(; i<text.length(); i++){
      if (textWidth(text.substring(0, i)) + x > mx)
        break;
    }
    if (0 <= i && i <= text.length() && y <= my && my <= y+textSize){
      return i;
    }
    return cursor;
  }
  
  ArrayList<String> _mouseEvent(String eventType, int button){
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
    }
    else if (eventType == "mouseDragged"){
      if (button == LEFT){
        selected = getCursorPos(mouseX, mouseY);
      }
    }
    return events;
  }
  
  ArrayList<String> _keyboardEvent(String eventType, char _key){
    keyboardEvent(eventType, _key);
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