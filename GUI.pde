class GUI extends DisplayPane{
  
  BezierGUI _bez;
  GUIControlContainer _controls;
  MeshBuilder _meshBuilder;

  public GUI(PVector i_position, PVector i_size){
    super(i_position, i_size);
  }
  
  public void changeNumPoints(float value){
    _bez.setPointCount((int)value);
  }
  
  public void changeSegments(float value){
    _meshBuilder.setSegments((int)value);
    generate();
  }
  
  public void changeInsetWidth(float value){
    _meshBuilder.changeInsetWidth(value);
  }
  
  public void changeInsetDepth(float value){
    _meshBuilder.changeInsetDepth(value);
  }
  
  public void generate(){
    _meshBuilder.generate(_bez.asScaledPVectorArray(600));
  }
  
  public void insetAll(){
     _meshBuilder.insetAll();
  }
  
  public void addedToStage(){
    _bez = new BezierGUI(new PVector(5,5), new PVector(300,300));
    this.addChild(_bez);
    _controls = new GUIControlContainer(new PVector(310, 5), new PVector(width-315, 300));
    this.addChild(_controls);
    _meshBuilder = new MeshBuilder(new PVector(0, 310), new PVector(width, height-310), _bez.asScaledPVectorArray(800));
    this.addChild(_meshBuilder);
    generate();
  }
  
  public void draw(PGraphics gfx){
    if(frameCount == 1)
      println("GUI");
    gfx.fill(220);
    gfx.rect(0,0,size.x,size.y);
  }
  
  public boolean isOver(PVector pt){
    return inBounds(pt);
  }
  
  public void actionHook(InteractiveDisplayObject child, int i_action){
    generate();
  }
  
}