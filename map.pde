import java.util.Collections;


class Map extends Element{
  final int EW, EH, INITIALHOLD=1000;
  int[][] terrain;
  Party[][] parties;
  Building[][] buildings;
  int mapWidth;
  int mapHeight;
  float blockSize, targetBlockSize;
  float mapXOffset, mapYOffset, targetXOffset, targetYOffset, panningSpeed, resetTime;
  boolean panning=false, zooming=false;
  float mapMaxSpeed;
  int elementWidth;
  int elementHeight;
  float[] mapVelocity = {0,0};
  int startX;
  int startY;
  int frameStartTime;
  int xPos, yPos;
  boolean zoomChanged;
  boolean mapFocused;
  int selectedCellX, selectedCellY;
  boolean cellSelected;
  color partyManagementColour;
  Node[][] moveNodes;
  ArrayList<int[]> drawPath;

  Map(int x, int y, int w, int h, int[][] terrain, Party[][] parties, Building[][] buildings, int mapWidth, int mapHeight){
    xPos = x;
    yPos = y;
    EW = w;
    EH = h;
    this.mapWidth = mapWidth;
    this.mapHeight = mapHeight;
    elementWidth = round(EW*GUIScale);
    elementHeight = round(EH*GUIScale);
    mapXOffset = 0;
    mapYOffset = 0;
    mapMaxSpeed = 15;
    this.terrain = terrain;
    this.parties = parties;
    this.buildings = buildings;
    this.mapWidth = mapWidth;
    this.mapHeight = mapHeight;
    limitCoords();
    frameStartTime = 0;
    cancelMoveNodes();
    cancelPath();
  }
  void selectCell(int x, int y){
    cellSelected = true;
    selectedCellX = x;
    selectedCellY = y;
  }
  void unselectCell(){
    cellSelected = false;
  }
  void setPanningSpeed(float s){
    panningSpeed = s;
  }
  void limitCoords(){
    mapXOffset = min(max(mapXOffset, -mapWidth*blockSize+elementWidth), 0);
    mapYOffset = min(max(mapYOffset, -mapHeight*blockSize+elementHeight), 0);
  }
  void reset(int mapWidth, int mapHeight, int[][] terrain, Party[][] parties, Building[][] buildings){
    mapXOffset = 0;
    mapYOffset = 0;
    this.mapWidth = mapWidth;
    this.mapHeight = mapHeight;
    this.terrain = terrain;
    this.parties = parties;
    this.buildings = buildings;
    blockSize = min(elementWidth/(float)mapWidth, elementWidth/10);
    setPanningSpeed(0.02);
    resetTime = millis();
    frameStartTime = 0;
    cancelMoveNodes();
  }
  void loadSettings(float x, float y, float bs){
    targetZoom(bs);
    targetOffset(x, y);
  }
  void targetOffset(float x, float y){
    targetXOffset = x;
    targetYOffset = y;
    limitCoords();
    panning = true;
  }
  void targetZoom(float bs){
    zooming = true;
    targetBlockSize = bs;
  }
  float [] targetCell(int x, int y, float bs){
    targetBlockSize = bs;
    targetXOffset = -(x+0.5)*targetBlockSize+elementWidth/2+xPos;
    targetYOffset = -(y+0.5)*targetBlockSize+elementHeight/2+yPos;
    panning = true;
    zooming = true;
    return new float[]{targetXOffset, targetYOffset, targetBlockSize};
  }
  void focusMapMouse(float x, float y){
    // based on mouse click
    if(mouseOver()){
      targetXOffset = -scaleXInv(x)*blockSize+elementWidth/2+xPos;
      targetYOffset = -scaleYInv(y)*blockSize+elementHeight/2+yPos;
      limitCoords();
      panning = true;
    }
  }
  void resetTarget(){
    targetXOffset = mapXOffset;
    targetYOffset = mapYOffset;
    panning = false;
    mapVelocity[0] = 0;
    mapVelocity[1] = 0;
  }
  void resetTargetZoom(){
    zooming = false;
    targetBlockSize = blockSize;
    setPanningSpeed(0.05); //<>//
  } //<>//
   //<>// //<>// //<>// //<>// //<>// //<>//
  void updateMoveNodes(Node[][] nodes){ //<>// //<>// //<>// //<>// //<>// //<>//
    moveNodes = nodes;
  }
  void updatePath(ArrayList<int[]> nodes){
    drawPath = nodes;
  }
  void cancelMoveNodes(){
    moveNodes = null;
  }
  void cancelPath(){
    drawPath = null;
  }

  ArrayList<String> mouseEvent(String eventType, int button, MouseEvent event){
    if (eventType == "mouseWheel"){
      float count = event.getCount();
      if(mouseOver()){
        float zoom = pow(0.9, count);
        float newBlockSize = max(min(blockSize*zoom, (float)elementWidth/10), (float)elementWidth/(float)mapSize);
        if (blockSize != newBlockSize){
          mapXOffset = scaleX(((mouseX-mapXOffset-xPos)/blockSize))-xPos-((mouseX-mapXOffset-xPos)*newBlockSize/blockSize);
          mapYOffset = scaleY(((mouseY-mapYOffset-yPos)/blockSize))-yPos-((mouseY-mapYOffset-yPos)*newBlockSize/blockSize);
          blockSize = newBlockSize;
          limitCoords();
          resetTarget();
          resetTargetZoom();
        }
      }
    }
    return new ArrayList<String>();
  }

  ArrayList<String> mouseEvent(String eventType, int button){
    if (button == LEFT){
      if (eventType=="mouseDragged" && mapFocused){
        mapXOffset += (mouseX-startX);
        mapYOffset += (mouseY-startY);
        limitCoords();
        startX = mouseX;
        startY = mouseY;
        resetTarget();
        resetTargetZoom();
      }
      if (eventType == "mousePressed"){
        if (mouseOver()){
          startX = mouseX;
          startY = mouseY;
          mapFocused = true;
        }
        else{
          mapFocused = false;
        }
      }
      else if (eventType == "mouseClicked"){
        if (moveNodes == null)
        focusMapMouse(mouseX, mouseY);
      }
    }
    return new ArrayList<String>();
  }
  ArrayList<String> keyboardEvent(String eventType, char _key){
    if (eventType == "keyPressed"){
      if (_key == 'a'&&mapVelocity[0]>-mapMaxSpeed){
        mapVelocity[0] -= mapMaxSpeed;
      }
      if (_key == 's'&&mapVelocity[1]<mapMaxSpeed){
        mapVelocity[1] += mapMaxSpeed;
      }
      if (_key == 'd'&&mapVelocity[0]<mapMaxSpeed){
        mapVelocity[0] += mapMaxSpeed;
      }
      if (_key == 'w'&&mapVelocity[1]>-mapMaxSpeed){
        mapVelocity[1] -= mapMaxSpeed;
      }
    }
    if (eventType == "keyReleased"){
      if (_key == 'a'&&mapVelocity[0]<0){
        mapVelocity[0] += mapMaxSpeed;
      }
      if (_key == 's'&&mapVelocity[1]>0){
        mapVelocity[1] -= mapMaxSpeed;
      }
      if (_key == 'd'&&mapVelocity[0]>0){
        mapVelocity[0] -= mapMaxSpeed;
      }
      if (_key == 'w'&&mapVelocity[1]<0){
        mapVelocity[1] += mapMaxSpeed;
      }
    }
    return new ArrayList<String>();
  }


  void draw(){

    // Terrain

    PImage[] tempTileImages = new PImage[NUMOFGROUNDTYPES];
    PImage[] tempBuildingImages = new PImage[NUMOFBUILDINGTYPES];
    PImage[] tempPartyImages = new PImage[3];
    if (frameStartTime == 0){
      frameStartTime = millis();
    }
    int frameTime = millis()-frameStartTime;
    if (millis()-resetTime < INITIALHOLD){
      frameTime = 0;
    }
    if (zooming){
      blockSize += (targetBlockSize-blockSize)*panningSpeed*frameTime*60/1000;
      if (abs(blockSize-targetBlockSize) < 0.001){
        resetTargetZoom();
      }
    }

    // Resize map based on scale
    elementWidth = round(EW*GUIScale);
    elementHeight = round(EH*GUIScale);
    if (panning){
      mapVelocity[0] = (mapXOffset-targetXOffset)*panningSpeed;
      mapVelocity[1] = (mapYOffset-targetYOffset)*panningSpeed;
      if (pow(mapVelocity[0], 2) + pow(mapVelocity[1], 2) < pow(blockSize*0.0001, 2)){
        resetTarget();
      }
    }
    mapXOffset -= mapVelocity[0]*frameTime*60/1000;
    mapYOffset -= mapVelocity[1]*frameTime*60/1000;
    frameStartTime = millis();
    limitCoords();
    for (int i=0; i<NUMOFGROUNDTYPES; i++){
      if(blockSize<24&&lowImages.containsKey(i)){
        tempTileImages[i] = lowImages.get(i).copy();
        tempTileImages[i].resize(ceil(blockSize), 0);
      } else {
        tempTileImages[i] = tileImages[i].copy();
        tempTileImages[i].resize(ceil(blockSize), 0);
      }
    }
    for (int i=0; i<NUMOFBUILDINGTYPES; i++){
      tempBuildingImages[i] = buildingImages[i].copy();
      tempBuildingImages[i].resize(ceil(blockSize*48/64), 0);
    }
    for (int i=0; i<3; i++){
      tempPartyImages[i] = partyImages[i].copy();
      tempPartyImages[i].resize(ceil(blockSize), 0);
    }
    int lx = max(0, -ceil((mapXOffset)/blockSize)+1);
    int ly = max(0, -ceil((mapYOffset)/blockSize)+1);
    int hx = min(floor((elementWidth-mapXOffset)/blockSize), mapWidth-1);
    int hy = min(floor((elementHeight-mapYOffset)/blockSize), mapHeight-1);
    for(int y=ly;y<hy;y++){
      for (int x=lx; x<hx; x++){
       float x2 = round(scaleX(x));
       float y2 = round(scaleY(y));
       image(tempTileImages[terrain[y][x]-1], x2, y2);
       }
     }
     int x3 = round(scaleX(hx));
     int y3 = round(scaleY(hy));
     int topW = min(round(scaleY(ly)-yPos), ceil(blockSize));
     int bottomW = min(round(yPos+elementHeight-scaleY(hy)), ceil(blockSize));
     int leftW = min(round(scaleX(lx)-xPos), ceil(blockSize));
     int rightW = min(round(xPos+elementWidth-scaleX(hx)), ceil(blockSize));
     for(int y=ly;y<hy;y++){
       image(tempTileImages[terrain[y][hx]-1].get(0, 0, rightW, ceil(blockSize)), x3,round(scaleY(y)));
       image(tempTileImages[terrain[y][lx-1]-1].get(ceil(blockSize)-leftW, 0, leftW, ceil(blockSize)), xPos, round(scaleY(y)));
     }
     for(int x=lx;x<hx;x++){
       image(tempTileImages[terrain[hy][x]-1].get(0, 0, ceil(blockSize), bottomW), round(scaleX(x)), y3);
       image(tempTileImages[terrain[ly-1][x]-1].get(0, ceil(blockSize)-topW, ceil(blockSize), topW), round(scaleX(x)), yPos);
     }
     image(tempTileImages[terrain[ly-1][lx-1]-1].get(ceil(blockSize)-leftW, ceil(blockSize)-topW, leftW, topW), xPos, yPos);
     image(tempTileImages[terrain[hy][hx]-1].get(0, 0, rightW, bottomW), x3, y3);
     image(tempTileImages[terrain[hy][lx-1]-1].get(ceil(blockSize)-leftW, 0, leftW, bottomW), xPos, y3);
     image(tempTileImages[terrain[ly-1][hx]-1].get(0, ceil(blockSize)-topW, rightW, topW), x3, yPos);


     //Buildings
     PVector c;
     for(int y=ly-1;y<hy+1;y++){
       for (int x=lx-1; x<hx+1; x++){
         //int pt = millis();
         if (buildings[y][x] != null){
           c = new PVector(scaleX(x), scaleY(y));
           int border = round((64-48)*blockSize/(2*64));
           int imgSize = round(blockSize*48/60);
           drawCroppedImage(round(c.x+border), round(c.y+border*2), imgSize, imgSize, tempBuildingImages[buildings[y][x].type]);
         }
         //Parties
         if(parties[y][x]!=null){
           c = new PVector(scaleX(x), scaleY(y));
           if(c.x<xPos+elementWidth&&c.y+blockSize/8>yPos&&c.y<yPos+elementHeight){
             noStroke();
             if(parties[y][x].player == 2){
               Battle battle = (Battle) parties[y][x];
               if (c.x+blockSize>xPos){
                 fill(120, 120, 120);
                 rect(max(c.x, xPos), max(c.y, yPos), max(0, min(blockSize, xPos+elementWidth-c.x, blockSize+c.x-xPos)), max(0, min(ceil(blockSize/16), yPos+elementHeight-c.y, blockSize/16+c.y-yPos)));
               }
               if (c.x+blockSize*parties[y][x].unitNumber/1000>xPos){
                 fill(playerColours[battle.party1.player]);
                 rect(max(c.x, xPos), max(c.y, yPos), max(0, min(blockSize*battle.party1.unitNumber/1000, xPos+elementWidth-c.x, blockSize*battle.party1.unitNumber/1000+c.x-xPos)), max(0, min(ceil(blockSize/16), yPos+elementHeight-c.y, blockSize/16+c.y-yPos)));
               }
               if (c.x+blockSize>xPos){
                 fill(120, 120, 120);
                 rect(max(c.x, xPos), max(c.y+blockSize/16, yPos), max(0, min(blockSize, xPos+elementWidth-c.x, blockSize+c.x-xPos)), max(0, min(ceil(blockSize/16), yPos+elementHeight-c.y-blockSize/16, blockSize/16+c.y-yPos)));
               }
               if (c.x+blockSize*parties[y][x].unitNumber/1000>xPos){
                 fill(playerColours[battle.party2.player]);
                 rect(max(c.x, xPos), max(c.y+blockSize/16, yPos), max(0, min(blockSize*battle.party2.unitNumber/1000, xPos+elementWidth-c.x, blockSize*battle.party2.unitNumber/1000+c.x-xPos)), max(0, min(ceil(blockSize/16), yPos+elementHeight-c.y-blockSize/16, blockSize/8+c.y-yPos)));
               }
               
             } else {
               if (c.x+blockSize>xPos){
                 fill(120, 120, 120);
                 rect(max(c.x, xPos), max(c.y, yPos), min(blockSize, xPos+elementWidth-c.x, blockSize+c.x-xPos), min(blockSize/8, yPos+elementHeight-c.y, blockSize/8+c.y-yPos));
               }
               if (c.x+blockSize*parties[y][x].unitNumber/1000>xPos){
                 fill(playerColours[parties[y][x].player]);
                 rect(max(c.x, xPos), max(c.y, yPos), min(blockSize*parties[y][x].unitNumber/1000, xPos+elementWidth-c.x, blockSize*parties[y][x].unitNumber/1000+c.x-xPos), min(blockSize/8, yPos+elementHeight-c.y, blockSize/8+c.y-yPos));
               }
             }
           }
           int imgSize = round(blockSize);
           drawCroppedImage(floor(c.x), floor(c.y), imgSize, imgSize, tempPartyImages[parties[y][x].player]);
         }
         //if (millis()-pt > 10){
         //  println(millis()-pt);
         //}
       }
     }

     //cell selection
     stroke(0);
     if (cellSelected){
       c = new PVector(scaleX(selectedCellX), scaleY(selectedCellY));
       if (max(c.x, xPos)+min(blockSize, xPos+elementWidth-c.x, blockSize+c.x-xPos)>xPos && max(c.x, xPos) < elementWidth+xPos && max(c.y, yPos)+min(blockSize, yPos+elementHeight-c.y, blockSize+c.y-yPos)>yPos && max(c.y, yPos) < elementHeight+yPos){
         fill(50, 100);
         rect(max(c.x, xPos), max(c.y, yPos), min(blockSize, xPos+elementWidth-c.x, blockSize+c.x-xPos), min(blockSize, yPos+elementHeight-c.y, blockSize+c.y-yPos));
       }
     }
     if (moveNodes != null){
       for (int y1=0; y1<mapHeight; y1++){
         for (int x=0; x<mapWidth; x++){
           if (moveNodes[y1][x] != null){
             c = new PVector(scaleX(x), scaleY(y1));
             if (max(c.x, xPos)+min(blockSize, xPos+elementWidth-c.x, blockSize+c.x-xPos)>xPos && max(c.x, xPos) < elementWidth+xPos && max(c.y, yPos)+min(blockSize, yPos+elementHeight-c.y, blockSize+c.y-yPos)>yPos && max(c.y, yPos) < elementHeight+yPos){
               if (blockSize > 10*TextScale && moveNodes[y1][x].cost <= 24){
                 fill(50, 150);
                 rect(max(c.x, xPos), max(c.y, yPos), min(blockSize, xPos+elementWidth-c.x, blockSize+c.x-xPos), min(blockSize, yPos+elementHeight-c.y, blockSize+c.y-yPos));
                 fill(255);
                 textSize(8*TextScale);
                 textAlign(CENTER, CENTER);
                 String s = ""+moveNodes[y1][x].cost;
                 s = s.substring(0, min(s.length(), 3));
                 BigDecimal cost = new BigDecimal(s);
                 text(cost.stripTrailingZeros().toPlainString(), c.x+blockSize/2, c.y+blockSize/2);
               }
             }
           }
         }
       }
     }
     
     if (drawPath != null){
       for (int i=0; i<drawPath.size()-1;i++){
         pushStyle();
         stroke(255,0,0); 
         line(scaleX(drawPath.get(i)[0])+blockSize/2, scaleY(drawPath.get(i)[1])+blockSize/2, scaleX(drawPath.get(i+1)[0])+blockSize/2, scaleY(drawPath.get(i+1)[1])+blockSize/2);
         popStyle();
       }
     }

     noFill();
     rect(xPos, yPos, elementWidth, elementHeight);
  }
  int sign(float x){
    if(x > 0){
      return 1;
    }
    else if (x < 0){
      return -1;
    }
    return 0;
  }
  void drawCroppedImage(int x, int y, int w, int h, PImage img){
    if (x+w>xPos && x<elementWidth+xPos && y+h>yPos && y<elementHeight+yPos){
      int newX = max(min(x, xPos+elementWidth), xPos);
      int newY = max(min(y, yPos+elementHeight), yPos);
      int imgX = max(0, newX-x, 0);
      int imgY = max(0, newY-y, 0);
      int imgW = min(max(elementWidth+xPos-x, -sign(elementWidth+xPos-x)*(x+w-newX)), img.width);
      int imgH = min(max(elementHeight+yPos-y, -sign(elementHeight+yPos-y)*(y+h-newY)), img.height);
      image(img.get(imgX, imgY, imgW, imgH), newX, newY);
    }
  }
  float scaleX(float x){
    return x*blockSize + mapXOffset + xPos;
  }
  float scaleY(float y){
    return y*blockSize + mapYOffset + yPos;
  }
  float scaleXInv(float x){
    return (x-mapXOffset-xPos)/blockSize;
  }
  float scaleYInv(float y){
    return (y-mapYOffset-yPos)/blockSize;
  }
  boolean mouseOver(){
    return mouseX > xPos && mouseX < xPos+elementWidth && mouseY > yPos && mouseY < yPos+elementHeight;
  }
}