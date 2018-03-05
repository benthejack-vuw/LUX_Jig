class GUIControlContainer extends InteractiveDisplayObject{
 
  GUIControls _controls;
  
  public GUIControlContainer(PVector i_position, PVector i_size){
   super(i_position, i_size);
  }
  
  public void addedToStage(){
    _controls = new GUIControls(this, Stage.cp5);
  }
  
  public void generate(){
    ((GUI)parent).generate(); 
  }
  
  public void insetAll(){
    ((GUI)parent).insetAll(); 
  }
  
  public void changeNumPoints(float value){
    ((GUI)parent).changeNumPoints(value); 
  }
  
  public void changeSegments(float value){
    println("here");
    ((GUI)parent).changeSegments(value); 
  }
  
  public void changeInsetWidth(float value){
    println("here");
    ((GUI)parent).changeInsetWidth(value); 
  }
  
  public void changeInsetDepth(float value){
    println("here");
    ((GUI)parent).changeInsetDepth(value); 
  }
  
  
  public void draw(PGraphics ctx){
   ctx.fill(80);
   ctx.rect(0,0,size.x,size.y);
  }
  
  public boolean isOver(PVector pt){
    return inBounds(pt);
  }
}

class GUIControls extends Cp5Plug{
  
  
  public GUIControls(InteractiveDisplayObject i_parent, ControlP5 i_cp5) {
    super(i_parent, i_cp5);
  }
  
  protected void setupControls(InteractiveDisplayObject i_object) {
     Button generateButton = cp5.addButton("generate")
    .setSize(50, 20);
    
     i_object.addCP5Control(generateButton, new PVector(i_object.getSize().x-55, 5), "generate");

     Button insetAllButton = cp5.addButton("inset all")
     .setSize(50, 20);
    
     i_object.addCP5Control(insetAllButton, new PVector(i_object.getSize().x-55, 30), "insetAll");
     
      Slider slider = cp5.addSlider("bezier points")
     .setWidth(200)
     .setRange(2,10) // values can range from big to small as well
     .setValue(4)
     .setNumberOfTickMarks(9)
     .setSliderMode(Slider.FLEXIBLE);
     
     i_object.addCP5Control(slider, new PVector(5, 5), "changeNumPoints");
     
     Slider slider2 = cp5.addSlider("Segments")
     .setWidth(200)
     .setRange(3,20) // values can range from big to small as well
     .setValue(4)
     .setNumberOfTickMarks(18)
     .setSliderMode(Slider.FLEXIBLE);
     
     i_object.addCP5Control(slider2, new PVector(5, 25), "changeSegments");

     Slider slider3 = cp5.addSlider("inset width")
     .setWidth(200)
     .setRange(2,100) // values can range from big to small as well
     .setValue(10);
     
     i_object.addCP5Control(slider3, new PVector(5, 45), "changeInsetWidth");
     
     Slider slider4 = cp5.addSlider("inset depth")
     .setWidth(200)
     .setRange(0,10) // values can range from big to small as well
     .setValue(2);
     
     i_object.addCP5Control(slider4, new PVector(5, 65), "changeInsetDepth");
  }
  
}