class MeshBuilder extends DisplayPane { //<>//

  PGraphics _renderContext;

  float mesh_thickness = 5;

  CatseyeGridImporter _gridImporter;
  GridMesh  _mesh;
  WB_Render _renderer;
  LatheMap  _latheMap;
  PeasyCam camera;

  PVector[] _points;

  String gridName = "tri";
  int _xTiles = 4;

  float _chamfer = 10;
  float _extrudeDepth = 2;
  float _renderScale = 1;

  PVector _mouse, _pMouse, _rotation;


  public MeshBuilder(PVector i_position, PVector i_size, PVector[] i_points) {
    super(i_position, i_size);

    _rotation = new PVector();
    _renderContext = createGraphics((int)size.x, (int)size.y, P3D);  
    camera = new PeasyCam(parentApp, _renderContext, 800);
    camera.setViewport((int)i_position.x, (int)i_position.y, (int)i_size.x, (int)i_size.y);
    
    _points = i_points;
    _gridImporter = new CatseyeGridImporter(gridName+".json");
    _renderer = new WB_Render((PGraphics3D)_renderContext);

    //thread("saveMesh");
  }

  public void addedToStage() {

    Button save = Stage.cp5.addButton("save")
      .setWidth(80);

    this.addCP5Control(save, new PVector(width-85, 5), "saveMesh");
  }

  public void generate(PVector[] points) {

    _points = points;
    _latheMap = new LatheMap(_points);
    _mesh = new GridMesh(_gridImporter, _latheMap, _xTiles);
  }

  public void changeInsetWidth(float value) {
    _chamfer = value;
  }

  public void changeInsetDepth(float value) {
    _extrudeDepth = value;
  }

  public void saveMesh(float value) {
    File selection = new File("");
    selectOutput("select where to save your file", "doSave");
  }

  public void setSegments(int value) {
    println("segment set");
    _xTiles = value;
  }

  public void mouseDragged(PVector mousePos) {
    if (_pMouse != null) {
      PVector diff = PVector.sub(mousePos, _pMouse);
      diff.div(200.0);
      diff.y /= 2.0;
      _rotation.add(diff);
    }

    _pMouse = mousePos;
  }

  public void mouseMoved(PVector mousePos) {
    _mouse = globalToLocal(mousePos);
  }

  public void mouseReleased(PVector mousePos) {
    _pMouse = null;
  }


  public void insetAll() {
    HE_Selection all = new HE_Selection(_mesh.getMesh());
    all.invertSelection();
    insetSelection(all);
  }

  public void click(PVector mousePos) {
    HE_Face f=_renderer.pickClosestFace(_mesh.getMesh(), _mouse.x, _mouse.y);
    HE_Selection face = new HE_Selection(_mesh.getMesh());
    face.add(f);

    insetSelection(face);
  }

  public void insetSelection(HE_Selection selection) {
    HEM_Extrude modifier=new HEM_Extrude();
    modifier.setDistance(0);// extrusion distance, set to 0 for inset faces
    modifier.setRelative(false);// treat chamfer as relative to face size or as absolute value
    modifier.setChamfer(_chamfer);// chamfer for non-hard edges
    modifier.setFuse(true);// try to fuse planar adjacent planar faces created by the extrude
    modifier.setFuseAngle(0.05*HALF_PI);// threshold angle to be considered coplanar
    modifier.setPeak(true);//if absolute chamfer is too large for face, create a peak on the face
    selection.modify(modifier); 

    HE_Selection extruded=modifier.extruded;
    modifier.setDistance(-_extrudeDepth).setChamfer(0);
    extruded.modify(modifier);
    _mesh.insetFaces.add(modifier.extruded);
  }

  public void draw(PGraphics ctx) {
    ctx.background(80);
    ctx.endDraw();
    camera.lookAt(0, 600, 0);

    _renderContext.beginDraw();

    _renderContext.background(180);
    _renderContext.directionalLight(255, 255, 255, 1, 1, -1);
    _renderContext.directionalLight(127, 127, 127, -1, -1, 1);
    _renderContext.noStroke();
    _renderContext.fill(255);

    if (_mesh != null && _mesh.done()) {
      _renderer.drawFaces(_mesh.getMesh());

      _renderContext.noFill();
      _renderContext.strokeWeight(1);
      _renderContext.stroke(0);
      _renderer.drawEdges(_mesh.getMesh());

      if (_mouse != null) {
        _renderContext.fill(255, 0, 0);
        HE_Face f = _renderer.pickClosestFace(_mesh.getMesh(), _mouse.x, _mouse.y);
        if (f!=null) _renderer.drawFace(f);
      }
    }

    _renderContext.endDraw();
    ctx.beginDraw();
    ctx.image(_renderContext, 0, 0);
  }
}