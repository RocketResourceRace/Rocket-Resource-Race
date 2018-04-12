
class Map3D extends Element{
  final int thickness = 10;
  int x, y, w, h, mapWidth, mapHeight, focusedX, focusedY;
  Building[][] buildings;
  int[][] terrain;
  Party[][] parties;
  PShape tiles;
  PImage[] tempTileImages;
  float targetZoom, zoom, tilt, rot;
  Boolean zooming, panning, mapActive;
  Node[][] moveNodes;
  float blockSize = 32;
  
  Map3D(int x, int y, int w, int h, int[][] terrain, Party[][] parties, Building[][] buildings, int mapWidth, int mapHeight){
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.terrain = terrain;
    this.parties = parties;
    this.buildings = buildings;
    this.mapWidth = mapWidth;
    this.mapHeight = mapHeight;
    blockSize = 64;
    focusedX = round(mapWidth*blockSize/2);
    focusedY = round(mapHeight*blockSize/2);
  }
  
  void updateMoveNodes(Node[][] nodes){}
  void cancelMoveNodes(){}
  void loadSettings(float mapXOffset, float mapYOffset, float blockSize){}
  float[] targetCell(int x, int y, float zoom){return new float[2];}
  void unselectCell(){}
  void selectCell(int x, int y){}
  float scaleXInv(int x){return x;}
  float scaleYInv(int y){return y;}
  void updatePath(ArrayList<int[]> n){};
  void cancelPath(){}
  void reset(int mapWidth, int mapHeight, int [][] terrain, Party[][] parties, Building[][] buildings) {
    this.terrain = terrain;
    this.parties = parties;
    this.buildings = buildings;
    this.mapWidth = mapWidth;
    this.mapHeight = mapHeight;
  }
  void generateShape(){
    pushStyle();
    noFill();
    noStroke();
    tempTileImages = new PImage[gameData.getJSONArray("terrain").size()];
    for (int i=0; i<gameData.getJSONArray("terrain").size(); i++){
      JSONObject tileType = gameData.getJSONArray("terrain").getJSONObject(i);
      tempTileImages[i] = tileImages.get(tileType.getString("id")).copy();
    }
    float[][] heights = new float[mapHeight*2+1][mapWidth*2];
    PGraphics[] tempTerrain = new PGraphics[mapHeight];
    for(int y=0; y<mapHeight; y++){
      tempTerrain[y] = createGraphics(round(mapWidth*64), round(64));
      tempTerrain[y].beginDraw();
      for (int x=0; x<mapWidth; x++){
        tempTerrain[y].image(tempTileImages[terrain[y][x]-1], x*64, 0);
      }
      tempTerrain[y].endDraw();
    }
    
    for(int y=0; y<mapHeight*2+1; y++){
      for (int x=0; x<mapWidth*2; x++){
        heights[y][x] = noise(x, y)*blockSize*0.5;
      }
    }
    
    tiles = createShape(GROUP);
    textureMode(IMAGE);
    for(int y=0; y<mapHeight; y++){
      PShape t = createShape();
      //textureWrap(CLAMP);
      t.setTexture(tempTerrain[y]);
      t.beginShape(TRIANGLE_STRIP);
      for (int x=0; x<mapWidth; x++){
        //translate();
        t.vertex(x*blockSize, y*blockSize, heights[y][x], x*blockSize, 0);   
        t.vertex(x*blockSize, (y+1)*blockSize, heights[y+1][x], x*blockSize, blockSize);
      }
      t.endShape();
      tiles.addChild(t);
    }
    popStyle();
  }
  
  void setZoom(int zoom){
    this.zoom = zoom;
  }
  
  ArrayList<String> mouseEvent(String eventType, int button){
    if (eventType.equals("mouseDragged")){
      if (mouseButton == LEFT){
        focusedX -= mouseX-pmouseX;
        focusedY -= mouseY-pmouseY;
      }
      else if (mouseButton != RIGHT){
        tilt += (mouseY-pmouseY)*0.01;
      }
    }
    return new ArrayList<String>();
  }
  
  
  ArrayList<String> mouseEvent(String eventType, int button, MouseEvent event){
    if (eventType == "mouseWheel"){
      float count = event.getCount();
      zoom += count*200;
    }
    return new ArrayList<String>();
  }
  
  void draw(){
    pushStyle();
    hint(ENABLE_DEPTH_TEST);
    camera(focusedX+width/2, focusedY+height/2, (height+zoom), focusedX+width/2, focusedY+height/2, 0, 0, 1, 0);
    rotateX(tilt);
    shape(tiles);
    camera();
    hint(DISABLE_DEPTH_TEST);
    popStyle();
    
  }
  
  boolean mouseOver(){
    return mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h;
  }
}
