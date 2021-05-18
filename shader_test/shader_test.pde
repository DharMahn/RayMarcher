import java.awt.Robot;
import java.awt.Component;
import java.util.*;
import controlP5.*;
Robot robot;
int lastMillis = millis();

GUI gui;

boolean forward, backward, left, right, up, down;
int lastMouseX;
int lastMouseY;
PShader shader;
String currentOS;

float rotX=0f;
float rotY=0f;

Camera c;
static Random r = new Random();
SceneHandler sceneHandler;
boolean capMouse;

float sliderX=0;
float sliderY=0;
float sliderZ=0;


void setup() {
  fullScreen(P3D);
  //size(1920,1080,P3D);
  noStroke();
  frameRate(144);
  shader = loadShader("main.glsl");
  ShaderWriter.testPath();
  c=new Camera(new PVector(0f, 0f, -10f), new PVector(0f, 0f, 1f));
  sceneHandler = new SceneHandler();
  /*if (displayWidth > displayHeight) {
    c.pg = createGraphics((displayWidth - (displayWidth / 20)) / c.scale, (displayHeight - (displayHeight/20))/c.scale, P3D);
    shader.set("u_resolution", float(c.pg.width), float(c.pg.height));
  } else {
    c.pg = createGraphics((displayHeight - (displayHeight / 20)) / c.scale, (displayWidth-(displayWidth/20))/c.scale, P3D); 
    shader.set("u_resolution", float(c.pg.width), float(c.pg.height));
  }*/
  c.pg=createGraphics(displayWidth/c.scale,displayWidth/c.scale,P3D);
  shader.set("u_resolution",float(c.pg.width),float(c.pg.height));
  sceneHandler.generateRandomShapes(10);
  sceneHandler.generateRandomLights(4);
  ControlP5 cp5;
  cp5 = new ControlP5(this);
  gui=new GUI();
  gui.setControl(cp5);
  gui.LoadGUI(sceneHandler.getShapesList());
  
  currentOS=OsDetector.GetOS();
  if (currentOS=="Windows") {
    try {
      robot = new Robot();
      noCursor();
    } 
    catch (Throwable e) {
    }
  }
  
}

void updateCamera() {
  c.MoveCamera(c.Pos, new PVector(c.Pos.x+(cos(rotX)*cos(rotY)), c.Pos.y+sin(rotY), c.Pos.z+(sin(rotX)*cos(rotY))));
}

void loop() {
}

void draw() {
  background(127);
  float deltaTime = millis()-lastMillis;
  if (forward) {
  c.Pos=PVector.add(c.Pos, PVector.mult(c.Forward, deltaTime*c.camSpeed));
  } else if (backward) {
    c.Pos=PVector.sub(c.Pos, PVector.mult(c.Forward, deltaTime*c.camSpeed));
  } 
  if (left) {
    c.Pos=PVector.sub(c.Pos, PVector.mult(c.Right, deltaTime*c.camSpeed));
  } else if (right) {
    c.Pos=PVector.add(c.Pos, PVector.mult(c.Right, deltaTime*c.camSpeed));
  } 
  if (up) {
    c.Pos=PVector.sub(c.Pos, PVector.mult(new PVector(0f, -1f, 0f), deltaTime*c.camSpeed));
  } else if (down) {
    c.Pos=PVector.add(c.Pos, PVector.mult(new PVector(0f, -1f, 0f), deltaTime*c.camSpeed));
  }
  if(capMouse){
    int displX=lastMouseX-mouseX;
    int displY=lastMouseY-mouseY;
    rotX+=displX/500f;
    rotX %=PI*2;
    rotY+=displY/500f;
    rotY = constrain(rotY, -((float)(PI / 2) - 0.1f), (float)(PI / 2) - 0.1f);
    updateCamera();
  }
  c.Render(shader,sceneHandler);
  image(c.pg, 0, 0, displayWidth, displayWidth);
  lastMouseX=mouseX;
  lastMouseY=mouseY;
  lastMillis=millis();
}

void keyPressed() {

  if (key == 'w') {
    forward=true;
  } else if (key=='s') {
    backward=true;
  } else if (key=='a') {
    left=true;
  } else if (key=='d') {
    right=true;
  } else if (key==' ') {
    up=true;
  } else if (key=='c') {
    down=true;
  }
  if (key=='r') {
    sceneHandler.generateRandomShapes(10);
    sceneHandler.generateRandomLights(4);
  }
  if(key=='p'){
     capMouse=!capMouse; 
  }
}
void keyReleased() {
  if (key == 'w') {
    forward=false;
  } else if (key=='s') {
    backward=false;
  } else if (key=='a') {
    left=false;
  } else if (key=='d') {
    right=false;
  } else if (key==' ') {
    up=false;
  } else if (key=='c') {
    down=false;
  }
}
/*void touchStarted(){
 println("touch started");
 background(255);
}
void touchMoved(){
 println("touch started");
 background(0);
}*/
