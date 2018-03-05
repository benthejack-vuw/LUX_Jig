import peasy.*;

import controlP5.*;

import flashStackP5.display.*;
import flashStackP5.gui.*;
import flashStackP5.processing.*;

import wblut.math.*;
import wblut.processing.*;
import wblut.core.*;
import wblut.hemesh.*;
import wblut.geom.*;

PApplet parentApp;
FlashStackP5 stage;
GUI gui;

void setup() {

  size(displayWidth, displayHeight, P3D);
  parentApp = this;


  background(255);
  stage = new FlashStackP5(this);
  gui = new GUI(new PVector(0, 0), new PVector(width, height));
  FlashStackP5.mainStage.addChild(gui);
  
}

public void doSave(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    
    String absolutePath = selection.getAbsolutePath();
    String path = absolutePath.substring(0,absolutePath.lastIndexOf(File.separator));
    String fileName = selection.getName();
    
    HE_Mesh cpy = gui._meshBuilder._mesh.getMesh().copy();
    cpy.triangulate();
    HET_Export.saveToSTL(cpy, path, fileName);

    HE_Mesh inset_faces = gui._meshBuilder._mesh.insetFaces.getAsMesh();
    HET_Export.saveToSTL(inset_faces, path, fileName+"_faces");
    println(path+"  /  "+fileName);
  }
}

void draw() {
  //background(80);
  

}