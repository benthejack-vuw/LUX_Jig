class GridMesh implements Runnable{
   
  private MapTo3D _map;
  private CatseyeGridImporter _grid;
  private HE_Mesh _mesh;
  
  private int _xTiles = -1;
  private int _yTiles = -1;
  
  private ArrayList<PVector> _verts = new ArrayList<PVector>(); 
  private ArrayList<int[]> _faces = new ArrayList<int[]>();
  
  private float _binSize = 2;
  private int[][][] _vertexBins;
  
  private boolean _done = false;
    
  public HE_Selection insetFaces;

    
  public GridMesh(CatseyeGridImporter grid, MapTo3D map, int xTiles){
    _grid = grid;
    _map = map;
    _xTiles = xTiles;
    
    int binsX = (int)(map.bounds().xSize()/_binSize + 1);
    int binsY = (int)(map.bounds().ySize()/_binSize + 1);
    int binsZ = (int)(map.bounds().xSize()/_binSize + 1);
    println("BINS:", binsX,binsY,binsZ, map.bounds().xSize());

    _vertexBins = new int[binsX][binsY][binsZ]; 
        
    generate();
  }
  
  public GridMesh(CatseyeGridImporter grid, MapTo3D map, int xTiles, int yTiles){
    _grid = grid;
    _map = map;
    _xTiles = xTiles;
    _yTiles = yTiles;
    
    int binsX = (int)(map.bounds().xSize()/_binSize + 1);
    int binsY = (int)(map.bounds().ySize()/_binSize + 1);
    int binsZ = (int)(map.bounds().xSize()/_binSize + 1);
    println("BINS:", binsX,binsY,binsZ, map.bounds().xSize());

    _vertexBins = new int[binsX][binsY][binsZ]; 
    
    generate();
  }
  
  public void generate(){
     new Thread(this).start();
     //run();
  }
  
  public void run(){
     generateAdaptive();
     _vertexBins = new int[1][1][1];
     _done = true;
  }
  
  public void generateAdaptive(){
        
     ((LatheMap)_map).buildAdaptiveSpline(_grid.boundingBox(), _xTiles, 0.5);
    
     Polygon[] polys = _grid.polygons(); 
     float xScale = 1.0/_xTiles;     

     //loop through tiling
     for(int x = 0; x < _xTiles; x+=1){ 
      try{
        println((x/(_xTiles+0.0))*100.0,"%");
        Thread.sleep(5);
      }catch(InterruptedException e){}
      for(int y = 2; y < _map.adaptivePointCount()-1; y++){
         //loop through polygons in tile
         for(int p = 0; p < polys.length; ++p){
           PVector[] polyVerts = polys[p].vertices();      
           int[] face = new int[polyVerts.length];
           //loop through vertices in tile
           for(int v = 0; v < polyVerts.length; ++v){
             float xP = ((polyVerts[v].x / _grid.boundingBox().width() ) / _xTiles) + x*xScale; 
             PVector vertex = _map.to3DAdaptive(xP, polyVerts[v].y/_grid.boundingBox().height(), y);
             face[polyVerts.length-(v+1)] = addPoint(vertex);
           }
           
           _faces.add(face);
         }
       }
     }
     
     
     buildMesh(); 
     insetFaces = new HE_Selection(_mesh);
  }
  
  public boolean done(){
    return _done;
  }
  
  public void buildMesh(){
    
    int[][] faceArray = new int[_faces.size()][];
    for(int i = 0; i < _faces.size(); i++){
       faceArray[i] = _faces.get(i);
    }

    float[][] vertArray = new float[_verts.size()][];
    for(int i = 0; i < _verts.size(); i++){
      PVector v = _verts.get(i); 
      vertArray[i] = new float[3];
      vertArray[i][0] = v.x;
      vertArray[i][1] = v.y;
      vertArray[i][2] = v.z;
    }
    
    //create HE_MESH with vertices and faces
    HEC_FromFacelist creator = new HEC_FromFacelist();
    creator.setVertices(vertArray);
    creator.setFaces(faceArray);
    creator.setDuplicate(false); //check for duplicate points, by default true.. already done 
    creator.setCheckNormals(false); //check for face orientation consistency, can be slow
    _mesh=new HE_Mesh(creator);   
   // _mesh.validate();
   
   println("mesh built");
  }
  
  public void thicken(int w){ 
    HEM_Lattice modifier=new HEM_Lattice();
    modifier.setWidth(w);// desired width of struts
    modifier.setDepth(w);// depth of struts
    modifier.setThresholdAngle(1.5*HALF_PI);// treat edges sharper than this angle as hard edges
    _mesh.modify(modifier);
  }
  
  public int addPoint(PVector p){
    int index = -1;
    
    int x = (int)abs(floor((p.x - _map.bounds().minX())/_binSize));
    int y = (int)abs(floor((p.y - _map.bounds().minY())/_binSize));
    int z = (int)abs(floor((p.z - _map.bounds().minZ())/_binSize));
    
    try{
      if(_vertexBins[x][y][z] > 0){
        index = _vertexBins[x][y][z] - 1;
      }else{
        _verts.add(p);
        index = _verts.size()-1;
        _vertexBins[x][y][z] = index + 1;
      }
    }
    catch(ArrayIndexOutOfBoundsException e){
        println("dud index");
        _verts.add(p);
        index = _verts.size()-1;
    }
    return index; 
  }
  
  public HE_Mesh getMesh(){
    return _mesh; 
  }
  
  //void extrude() {
  //  println("extruding" + this._chamfer);
    
  //  HEM_Extrude modifier=new HEM_Extrude();
  //  modifier.setDistance(0);// extrusion distance, set to 0 for inset faces
  //  modifier.setRelative(false);// treat chamfer as relative to face size or as absolute value
  //  modifier.setChamfer(_chamfer);// chamfer for non-hard edges
  //  modifier.setFuse(true);// try to fuse planar adjacent planar faces created by the extrude
  //  modifier.setFuseAngle(0.05*HALF_PI);// threshold angle to be considered coplanar
  //  modifier.setPeak(true);//if absolute chamfer is too large for face, create a peak on the face
  //  _mesh.modify(modifier); 

  //  _insetFaces=modifier.extruded;
  //  modifier.setDistance(_extrudeDepth).setChamfer(0);
  //  _insetFaces.modify(modifier);
  //  _insetFaces = modifier.extruded; 
  //}
   
}