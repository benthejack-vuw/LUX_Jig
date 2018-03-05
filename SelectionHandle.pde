public class SelectionHandle extends InteractiveDisplayObject {
  
  private float radius;    
  private InteractiveDisplayObject _interctionParent;
  
  public SelectionHandle(PVector i_position, PVector i_size, InteractiveDisplayObject i_parent) {
    super(i_position, i_size);
    radius = i_size.x/2.0f;
    _interctionParent = i_parent;
  }
  
  public void addedToStage(){
   constrain(new PVector(size.x/2,size.y/2), parent.getSize().sub(new PVector(size.x/2, size.y/2))); 
  }
  
  public boolean isOver(PVector i_position){
    PVector locPos = globalToLocal(i_position);
    return PVector.dist(locPos, new PVector(0,0)) < radius || selected;
  }
  
  public void draw(PGraphics i_context){
        
    if(!mouseIsOver)
      i_context.fill(255,0,0);
    else
      i_context.fill(100,255,100);
    
    i_context.noStroke();
    i_context.ellipse(0, 0, radius*2, radius*2);
  }
  
  public void mouseDragged(PVector i_mousePos){
    setPositionFromGlobal(i_mousePos);
   constrain(new PVector(size.x/2,size.y/2), parent.getSize().sub(new PVector(size.x/2, size.y/2))); 
    
  }
  
  public void mouseReleased(PVector i_mousePos){
     _interctionParent.actionHook(this, 1);
  }
  
  public void constrain(PVector i_tl, PVector i_br){
    constrain(i_tl, i_br, false);
  }
  
  public void constrain(PVector i_tl, PVector i_br, boolean seperateHandles){
    
    float x = PApplet.constrain(getPosition().x, i_tl.x, i_br.x);
    float y = PApplet.constrain(getPosition().y, i_tl.y, i_br.y);
    this.setPositionFromLocal(new PVector(x,y));
    
  }

}