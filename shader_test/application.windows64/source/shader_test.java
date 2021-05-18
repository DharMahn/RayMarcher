import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.awt.Robot; 
import java.util.*; 
import controlP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class shader_test extends PApplet {





ControlP5 cp5;
Robot robot;

int max = 12;

boolean forward,backward,left,right,up,down,capMouse;

PShader shader;
class Shape {
  PVector position;
  PVector size;
  PVector colour;
  int shapeType;
}
class Camera{
    PVector Forward;
    PVector Pos;
    PVector Right;
    PVector Up;
};
public Camera createCamera(PVector pos, PVector lookAt){
    Camera c = new Camera();
    c.Forward = PVector.sub(lookAt,pos).normalize();
    c.Pos = pos;
    PVector Down = new PVector(0,-1,0);
    c.Right = PVector.mult(c.Forward.cross(Down).normalize(),1.5f);
    c.Up = PVector.mult(c.Forward.cross(c.Right).normalize(),1.5f);
    return c;
}

float rotX=0f;
float rotY=0f;
float rotUp=0f;

Camera c;

Random r = new Random();

float[] pos=new float[max*3];
float[] size=new float[max*3];
float[] colour=new float[max*3];
int[] shapeType = new int[max];

public void setup() {
  
  //size(1280,720,P3D);
  noStroke();
  frameRate(140);
  try {
    robot = new Robot();
  } 
  catch (Throwable e) {
  }
  c=createCamera(new PVector(0f,0f,-10f),new PVector(0f,0f,1f));
  for(int i = 0; i < max*3; i+=3){
    pos[i]=i*2;
    pos[i+1]=0f;
    pos[i+2]=1f;
    size[i]=2f;
    size[i+1]=1f;
    size[i+2]=1f;
    colour[i]=r.nextFloat();
    colour[i+1]=r.nextFloat();
    colour[i+2]=r.nextFloat();
    shapeType[i/3]=r.nextInt(4);
  }
  shader = loadShader("main.glsl");
}

public void updateCamera(){
 c = createCamera(c.Pos,new PVector(c.Pos.x+cos(rotX),c.Pos.y+tan(rotUp),c.Pos.z+sin(rotX))); 
}

public void draw() {
  if (forward) {
    c.Pos=PVector.add(c.Pos,PVector.div(c.Forward,10f));
  } else if(backward){
    c.Pos=PVector.sub(c.Pos,PVector.div(c.Forward,10f));
  } if(left){
    c.Pos=PVector.sub(c.Pos,PVector.div(c.Right,10f));
  } else if(right){
    c.Pos=PVector.add(c.Pos,PVector.div(c.Right,10f));
  } if(up){
    c.Pos=PVector.add(c.Pos,PVector.div(new PVector(0f,-1f,0f),10f));
  } else if(down){
    c.Pos=PVector.sub(c.Pos,PVector.div(new PVector(0f,-1f,0f),10f));
  }
  println(frameRate);
  if(capMouse){
     int displX=mouseX-(width/2);
     int displY=mouseY-(height/2);
     robot.mouseMove(width/2,height/2);
     rotX-=displX/500f;
     rotY-=displY/500f;
     rotUp=-constrain(rotY,-1,1);
     println(rotX + " - " + rotY);
     updateCamera();
  }
  
  
  shader.set("u_resolution", PApplet.parseFloat(width), PApplet.parseFloat(height));
  shader.set("u_mouse", PApplet.parseFloat(mouseX), PApplet.parseFloat(mouseY));
  shader.set("u_time", millis() / 1000.0f);
  shader.set("pos", pos, 3);
  shader.set("size", size, 3);
  shader.set("colour", colour, 3);
  shader.set("shapeType", shapeType);
  shader.set("camPos",new float[]{c.Pos.x,c.Pos.y,c.Pos.z},3);
  shader.set("lookAt",new float[]{c.Pos.x+cos(rotX),c.Pos.y+tan(rotUp),c.Pos.z+sin(rotX)},3);
  shader(shader);
  rect(0, 0, width, height);
}

public void keyPressed() {
  //print("asd");
  
  if (key == 'w') {
    forward=true;
  } else if(key=='s'){
    backward=true;
  } else if(key=='a'){
    left=true;
  } else if(key=='d'){
    right=true;
  } else if(key==' '){
    up=true;
  } else if(key=='c'){
    down=true;
  }
  if(key=='p'){
    if(!capMouse){
     noCursor(); 
     capMouse=true;
     robot.mouseMove(width/2,height/2);
    }
    else{
     cursor();
     capMouse=false;
    }   
  }
}
public void keyReleased(){
  if (key == 'w') {
    forward=false;
  } else if(key=='s'){
    backward=false;
  } else if(key=='a'){
    left=false;
  } else if(key=='d'){
    right=false;
  } else if(key==' '){
    up=false;
  } else if(key=='c'){
    down=false;
  }
}
  public void settings() {  fullScreen(P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--hide-stop", "shader_test" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
