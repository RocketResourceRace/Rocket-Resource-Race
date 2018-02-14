
class Player{
  float mapXOffset, mapYOffset, blockSize;
  Player(float mapXOffset, float mapYOffset, float blockSize){
    this.mapXOffset = mapXOffset;
    this.mapYOffset = mapYOffset;
    this.blockSize = blockSize;
  }
  void saveMapSettings(float mapXOffset, float mapYOffset, float blockSize){
    this.mapXOffset = mapXOffset;
    this.mapYOffset = mapYOffset;
    this.blockSize = blockSize;
  }
  void loadMapSettings(Map m){
    m.loadSettings(mapXOffset, mapYOffset, blockSize);
  }
}