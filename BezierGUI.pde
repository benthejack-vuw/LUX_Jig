class BezierGUI extends InteractiveDisplayObject{
 
  private ArrayList<SelectionHandle> _handles;
   
  public BezierGUI(PVector position, PVector size){
    super(position, size);
  }
  
  protected void addedToStage(){
      setPointCount(4);
  }
  
  public void setPointCount(int numPoints){
    
    if(_handles != null){
     for(int i = 0; i < _handles.size(); ++i){
       this.removeChild(_handles.get(i));
     }
     
    PVector[] newPoints = newCatmullPoints(numPoints, asVectorArray());
    _handles = new ArrayList<SelectionHandle>();
    for(int i = 0; i < numPoints; ++i){
        SelectionHandle h = new SelectionHandle(newPoints[i], new PVector(15,15), parent);
        _handles.add(h);
        this.addChild(h);
    }
    
    }else{
      _handles = new ArrayList<SelectionHandle>();
      for(int i = 0; i < numPoints; ++i){
        SelectionHandle h = new SelectionHandle(new PVector(size.x/2, i*(size.y/(numPoints-1))), new PVector(15,15), parent);
        _handles.add(h);
        this.addChild(h);
      }
    }
  }
  
  public PVector[] asNormalizedPVectorArray(){
    return asScaledPVectorArray(1);
  }
 
  public PVector[] asVectorArray(){
    return asScaledPVectorArray(size.x);
  }
  
  public PVector[] asScaledPVectorArray(float i_scale){
    
    PVector[] out = new PVector[_handles.size()];
     for(int i = 0; i < _handles.size(); ++i){
      out[i] = _handles.get(i).getPosition();
      out[i].x /= size.x;
      out[i].y /= size.x; //intentionally x to keep proportions
      out[i].x *= i_scale;
      out[i].y *= i_scale; //intentionally x to keep proportions
     }
     return out;
     
  }
  
  public void draw(PGraphics gfx){
    
    PVector[] pts = this.asVectorArray();
    
    gfx.fill(200);
    gfx.rect(0, 0, size.x, size.y);
    gfx.stroke(0);
    float res = 0.002;
    
    for(float i = res; i <= 1; i+=res){
      PVector p1 = catmullSpline(i, pts);
      PVector p2 = catmullSpline(i-res, pts);
      gfx.line(p1.x, p1.y, p2.x, p2.y);
    }
    
  }
  
  public boolean isOver(PVector p){
    return inBounds(p);
  }
  
}