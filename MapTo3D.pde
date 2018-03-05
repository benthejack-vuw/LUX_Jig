interface MapTo3D{
  public PVector to3D(float x, float y);
  public PVector to3DAdaptive(float x, float y, int tileY);
  public void buildAdaptiveSpline(Rectangle boundingBox, int xTiles);
  public int adaptivePointCount();
  public Box bounds();
}

class Box{
 
  private PVector _topLeft, _bottomRight;
  
  Box(PVector topLeft, PVector bottomRight){
    _topLeft = topLeft;
    _bottomRight = bottomRight;
  }
  
  public float minX(){
   return  _topLeft.x;
  }
  public float minY(){
   return  _topLeft.y;
  }
  public float minZ(){
   return  _topLeft.x;
  }
  
  public float xSize(){
    return _bottomRight.x - _topLeft.x;
  }
  
  public float ySize(){
    return _bottomRight.y - _topLeft.y;
  }
  
  public float zSize(){
    return _bottomRight.z - _topLeft.z;
  }
  
}