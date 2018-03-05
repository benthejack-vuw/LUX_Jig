PVector catmullSpline (float _t, PVector[] _points) {
  
  _t = constrain(_t, 0, 3);
  float segSize = 1.0/(_points.length-1);
  
  int segment = (int)floor(_t*(_points.length-1));
  
  float nt = map(_t, segment*segSize, (segment+1)*segSize, 0, 1);
  int p1, p2, p3, p4;
  
  if(_t >= 1.0){
   p1 = (_points.length-1);
   p2 = (_points.length-1);
   p3 = (_points.length-1);
   p4 = (_points.length-1);
  }else{
   p1 = segment > 0 ? segment-1 : segment;
   p2 = segment > 0 ? segment   : segment;
   p3 = segment+1;
   p4 = segment < _points.length-2 ? segment+2 : segment+1; 
  }
     
  return catmullSegment (nt, _points[p1], _points[p2], _points[p3], _points[p4]);
}

PVector[] newCatmullPoints(int newCount, PVector[] points){
 
  PVector[] out = new PVector[newCount];
  
  for(int i = 0; i < newCount; ++i){
    out[i] = catmullSpline(i*(1.0/(newCount-1)), points);
  }
  
  return out;
}

PVector catmullSegment (float _t, PVector P0, PVector P1, PVector P2, PVector P3) {
  float _x = 0.5 * ((2*P1.x) + (-P0.x + P2.x)*_t + (2*P0.x - 5*P1.x + 4*P2.x -P3.x) * pow(_t, 2) + (-P0.x + 3*P1.x - 3*P2.x + P3.x) * pow(_t, 3));
  float _y = 0.5 * ((2*P1.y) + (-P0.y + P2.y)*_t + (2*P0.y - 5*P1.y + 4*P2.y -P3.y) * pow(_t, 2) + (-P0.y + 3*P1.y - 3*P2.y + P3.y) * pow(_t, 3));
  return new PVector (_x, _y);
}

float splineLength(PVector[] _points){
  float y = 0;
  float iterations = 50;
  for(int i = 1; i <= iterations; i++){
    y += PVector.dist(catmullSpline(i/iterations, _points), catmullSpline((i-1)/iterations, _points));
  }
 return y; 
}

float minX( PVector[] _points) {
  float min = Float.MAX_VALUE;
  for(float i = 0; i <= 1; i += 0.01){
      min = min(min, catmullSpline(i, _points).x);
  }
  return min;
}

float minY(PVector[] _points) {
  float min = Float.MAX_VALUE;
  for(float i = 0; i <= 1; i += 0.01){
      min = min(min, catmullSpline(i, _points).y);
  }
  return min;
}

float maxX( PVector[] _points) {
  float max = -Float.MAX_VALUE;
  for(float i = 0; i <= 1; i += 0.01){
      max = max(max, catmullSpline(i, _points).x);
  }
  return max;
}

float maxY( PVector[] _points) {
  float max = -Float.MAX_VALUE;
  for(float i = 0; i <= 1; i += 0.01){
      max = max(max, catmullSpline(i, _points).y);
  }
  return max;
}