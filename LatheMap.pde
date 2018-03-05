class LatheMap implements MapTo3D{
   
    public PVector[] _points;
    public float _splineLength;
    public PVector[] _adaptiveSpline;
    public Box _bounds;
  
    public LatheMap(PVector[] curvePoints){
        _points = curvePoints;
        _splineLength = splineLength(curvePoints);
        _bounds = new Box(new PVector(-maxX(_points), -maxY(_points)), new PVector(maxX(_points), maxY(_points))); 
    }
    
    public void buildAdaptiveSpline(Rectangle tileBounds, int tileX){
      buildAdaptiveSpline(tileBounds, tileX, 0);
    }
    
    public Box bounds(){
      return _bounds;
    }
    
    public void buildAdaptiveSpline(Rectangle tileBounds, int tileX, float midPoint){
      ArrayList<PVector> adsp = new ArrayList<PVector>();
     // float scaleDivisor = 
      
     // adsp.add(new PVector(0, midPoint, 0));
      adsp.add(new PVector(0, midPoint, 0));

      float topT = midPoint, botT = midPoint, topR, botR, topA, botA, botShrink, topShrink;
      
      while(topT < 1 || botT > 0){
       
        if(botT >= 0){
           botR = catmullSpline(botT, _points).x;
           botA = TWO_PI*botR / tileX;
           botShrink = botA/tileBounds.width();
          
           float lt = botT;
           botT -= (tileBounds.height()*botShrink)/_splineLength;
           adsp.add(0, new PVector(0,botT,0));
        }
         
         if(topT <= 1){
           topR = catmullSpline(topT, _points).x;
           topA = TWO_PI*topR / tileX;
           topShrink = topA/tileBounds.width();
           topT += (tileBounds.height()*topShrink)/_splineLength;
           adsp.add(new PVector(0,topT,0));  
         }
         
      }
      
      _adaptiveSpline = new PVector[adsp.size()];
      for(int i = 0; i < adsp.size(); ++i){
        _adaptiveSpline[i] = (PVector)adsp.get(i); 
      }
      
      println(adsp.size());

      
    }
    
    public int adaptivePointCount(){
     return _adaptiveSpline.length;
    }
    
    public PVector to3D(float x, float y){      
      PVector splinePoint = catmullSpline(y, _points);
      float theta = x * TWO_PI;
      float rad = splinePoint.x;
      float xP = cos(theta) * rad;
      float yP = splinePoint.y;
      float zP = sin(theta) * rad;
      
      return new PVector(xP, yP, zP); 
    }
    
    public PVector to3DAdaptive(float x, float y, int tileY){      

      float step = 1.0/adaptivePointCount();
      float yTime = step*tileY + y/adaptivePointCount();
      float yInterp = catmullSpline(yTime, _adaptiveSpline).y;  
      PVector splinePoint = catmullSpline(yInterp, _points);
      float rad = splinePoint.x;
      float theta = TWO_PI*x;
       
      float xP = cos(theta) * rad;
      float yP = splinePoint.y;
      float zP = sin(theta) * rad; 
      
      return new PVector(xP, yP, zP);  
    }
    
}