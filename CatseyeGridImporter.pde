String TILE_NORMALIZED = "tile";
String EDGE_NORMALIZED = "edge";

class CatseyeGridImporter {

  private JSONObject _data;

  private Rectangle _edge_norm_bb;
  private Rectangle _tile_norm_bb;
  private Polygon[] _edge_normalized_polygons;
  private Polygon[] _tile_normalized_polygons;

  CatseyeGridImporter(String url) {
    _data = loadJSONObject(url);

    JSONObject e_n_bb = _data.getJSONObject("edge_normalized_clipRect"); 
    _edge_norm_bb = new Rectangle(e_n_bb.getFloat("x"), e_n_bb.getFloat("y"), e_n_bb.getFloat("width"), e_n_bb.getFloat("height"));

    JSONObject t_n_bb = _data.getJSONObject("normalized_clipRect"); 
    _tile_norm_bb = new Rectangle(t_n_bb.getFloat("x"), t_n_bb.getFloat("y"), t_n_bb.getFloat("width"), t_n_bb.getFloat("height"));

    _edge_normalized_polygons =  JSONToPolyArray(_data.getJSONArray("edge_normalized_polygons"));
    _tile_normalized_polygons =  JSONToPolyArray(_data.getJSONArray("normalized_polygons"));
  }

  private Polygon[] JSONToPolyArray(JSONArray data) {
    Polygon[] polys = new Polygon[data.size()];

    for (int i = 0; i < data.size(); ++i) {
      polys[i] = new Polygon(data.getJSONArray(i));
    }
    
    return polys;
  }

  public Polygon[] polygons() { 
    return polygons(EDGE_NORMALIZED);
  }
 

  public Polygon[] polygons(String normalization) {
    return normalization == EDGE_NORMALIZED ? _edge_normalized_polygons : _tile_normalized_polygons;
  }

  public Rectangle boundingBox() {
    return boundingBox(EDGE_NORMALIZED);
  }
  
  public Rectangle boundingBox(String normalization) {
    return normalization == EDGE_NORMALIZED ? _edge_norm_bb : _tile_norm_bb;
  }
  
  public PImage gridImage(int w, int h, float gridSize){
   PGraphics gfx = createGraphics(w, h, P3D); 
   gfx.beginDraw();
   gfx.background(255);
   gfx.fill(255);
   
   float tileW = _edge_norm_bb.width()*gridSize;
   float tileH = _edge_norm_bb.height()*gridSize;
   int repsX = ceil(w / tileW);
   int repsY = ceil(h / tileH);
       
   gfx.pushMatrix();
   
   for(int i = 0; i < repsX; ++i){
     gfx.pushMatrix();
     gfx.translate(i*tileW, 0);
     for(int j = 0; j < repsY; ++j){
       gfx.pushMatrix();
       gfx.translate(0, j*tileH);
       drawOn(gridSize, gfx);
       gfx.popMatrix();
     }
     gfx.popMatrix();
   }
   
   gfx.popMatrix();
   gfx.endDraw();
   return gfx;
  }
  
  public void drawOn(float size, PGraphics gfx){
    for(int i = 0; i < _edge_normalized_polygons.length; ++i){
      _edge_normalized_polygons[i].drawOn(size, gfx);
    }
  }
  
  public void draw(float size){
    for(int i = 0; i < _edge_normalized_polygons.length; ++i){
      _edge_normalized_polygons[i].draw(size);
    }
  }
  
  public void drawOffset(float size, float offset){
    for(int i = 0; i < _edge_normalized_polygons.length; ++i){
      _edge_normalized_polygons[i].centeredScaleDraw(size, offset);
    }
  }
  
}


class Polygon{
  private PVector[] _vertices;
  private PVector _centroid;

  public Polygon(JSONArray data) {
    _vertices = new PVector[data.size()];
    JSONObject vertex;

    for (int i = 0; i < data.size(); ++i) {
      vertex = data.getJSONObject(i);
      _vertices[i] = new PVector(vertex.getFloat("x"), vertex.getFloat("y"));
    }

    calculateCentroid();
  }

  public PVector centroid(){
     return _centroid; 
  }

  private void calculateCentroid() {

    _centroid = new PVector(0, 0);
    for (int i = 0; i < _vertices.length; ++i) {
      _centroid.add(_vertices[i]);
    }
    _centroid.div(_vertices.length);
  }

  public void draw(float edgeSize) {
    beginShape();
    noStroke();
    fill(lerpColor(color(255), color(0), random(1)));
    for (int i = 0; i < _vertices.length; ++i) {
      PVector scaled = PVector.mult(_vertices[i], edgeSize); 
      vertex(scaled.x, scaled.y);
    }
    endShape(CLOSE);
  }
  
  public void drawOn(float edgeSize, PGraphics gfx) {
    gfx.beginShape();
    for (int i = 0; i < _vertices.length; ++i) {
      PVector scaled = PVector.mult(_vertices[i], edgeSize); 
      gfx.vertex(scaled.x, scaled.y);
    }
    gfx.endShape(CLOSE);
  }

  public void centeredScaleDraw(float size, float scale) {
    
    
    PVector c = PVector.mult(_centroid, size);
    pushMatrix();
    translate(c.x, c.y);
    
    beginShape();
    
    for (int i = 0; i < _vertices.length; ++i) {
      PVector v = PVector.mult(_vertices[i], size);
      v.sub(c);
      v.mult(scale);
      vertex(v.x, v.y);
    }
    
    endShape(CLOSE);
    popMatrix();
    
  }

  public PVector[] vertices() {
    return vertices(1);
  }
  
  public PVector[] vertices(float scale) {
    PVector[] scaled = new PVector[_vertices.length]; 
    for (int i = 0; i < _vertices.length; ++i) {
      scaled[i] = PVector.mult(_vertices[i], scale);
    }
    return scaled;
  }
  
  public void centroidDraw(float edgeSize){
    fill(0);
    ellipse(edgeSize*_centroid.x, edgeSize*_centroid.y, 10, 10);
  }
  
  public void sandDraw(float edgeSize, int density){
    PGraphics lines = createGraphics((int)edgeSize*3, (int)edgeSize*3);

    PGraphics mask = createGraphics((int)edgeSize*3, (int)edgeSize*3);
    mask.beginDraw();
    mask.translate(edgeSize*3/2, edgeSize*3/2);
    mask.noStroke();
    mask.fill(255);
    mask.beginShape();
    mask.strokeWeight(4);
    for (int i = 0; i < _vertices.length; ++i) {
      PVector scaled = PVector.sub(_vertices[i], _centroid); 
      scaled.mult(edgeSize);
      mask.vertex(scaled.x, scaled.y);
    }
    mask.endShape(CLOSE);
    mask.endDraw();
    
    lines.beginDraw();    
    lines.background(255);

    for(int v = 0; v < _vertices.length; ++v){
      lines.pushMatrix();
      float len = _vertices[v].dist(_vertices[(v+1)%_vertices.length]);
      float dx = _vertices[(v+1)%_vertices.length].x - _vertices[v].x;
      float dy = _vertices[(v+1)%_vertices.length].y - _vertices[v].y;
      float theta = atan2(dy, dx);     
      color col = color(0,5);
          
      lines.translate(edgeSize*3/2, edgeSize*3/2);
      lines.stroke(col);
      
      PVector scaled = PVector.sub(_vertices[v], _centroid); 
      scaled.mult(edgeSize);
      
      lines.translate(scaled.x, scaled.y);
      lines.rotate(theta);
      
      for(int i = 0; i < edgeSize; i++){
        float dist = random(edgeSize/1.5);
        for(int j = 0; j < density; j++){
          lines.point(i, random(dist));
        }
      }
      
      lines.popMatrix();
    }
    

    
    lines.endDraw();
    lines.mask(mask);
    imageMode(CENTER);
    image(lines, _centroid.x*edgeSize,  _centroid.y*edgeSize);
   }
  
  public void stripeDraw(float edgeSize, int density){
    PGraphics lines = createGraphics((int)edgeSize*3, (int)edgeSize*3);
    PGraphics mask = createGraphics((int)edgeSize*3, (int)edgeSize*3);
    mask.beginDraw();
    mask.translate(edgeSize*3/2, edgeSize*3/2);
    mask.noStroke();
    mask.fill(255);
    mask.beginShape();
    for (int i = 0; i < _vertices.length; ++i) {
      PVector scaled = PVector.sub(_vertices[i], _centroid); 
      scaled.mult(edgeSize);
      mask.vertex(scaled.x, scaled.y);
    }
    mask.endShape(CLOSE);
    mask.endDraw();
    
    lines.beginDraw();
    lines.background(255);
    lines.translate(edgeSize*3/2, edgeSize*3/2);
    lines.rotate(random(TWO_PI));
    lines.translate(-edgeSize*3/2, -edgeSize*3/2);
    for(int i = 0; i < edgeSize*3; i += density){
      lines.line(0, i, edgeSize*3, i);
    }
    lines.endDraw();
    lines.mask(mask);
    imageMode(CENTER);
    image(lines, _centroid.x*edgeSize,  _centroid.y*edgeSize);
   }
  
}

class Rectangle {

  private float _x, _y, _width, _height;

  public Rectangle(float x, float y, float w, float h) {
    _x = x;
    _y = y;
    _width = w;
    _height = h;
  }

  public float x() {
    return _x;
  }

  public float y() {
    return _y;
  }

  public float width() {
    return _width;
  }

  public float height() {
    return _height;
  }
}