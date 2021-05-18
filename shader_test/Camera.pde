class Camera {
  public PVector Forward;
  public PVector Pos;
  public PVector Right;
  public PVector Up;
  private float camSpeed=0.01;
  public int scale = 1;
  Boolean needsUpdating=true;
  PGraphics pg;

  public Camera(PVector pos, PVector lookAt) {
    MoveCamera(pos, lookAt);
  }
  public void MoveCamera(PVector pos, PVector lookAt) {
    this.Forward = PVector.sub(lookAt, pos).normalize();
    this.Pos = pos;
    PVector Down = new PVector(0, -1, 0);
    this.Right = PVector.mult(this.Forward.cross(Down).normalize(), 1.5f);
    this.Up = PVector.mult(this.Forward.cross(this.Right).normalize(), 1.5f);
  }

  public void Render(PShader shader, SceneHandler sh) {
    shader.set("pos", sh.getPos(), 3);
    shader.set("size", sh.getSize(), 3);
    shader.set("colour", sh.getColour(), 3);
    shader.set("shapeType", sh.getShapeType());
    shader.set("lightspos", sh.getLightsPos(), 3);
    shader.set("lightsintensity", sh.getLightsIntensity(), 3);
    needsUpdating=false;
    shader.set("camPos", new float[]{c.Pos.x, c.Pos.y, c.Pos.z}, 3);
    shader.set("lookAt", new float[]{c.Pos.x+(cos(rotX)*cos(rotY)), c.Pos.y+sin(rotY), c.Pos.z+(sin(rotX)*cos(rotY))}, 3);
    shader.set("u_mouse", new PVector(mouseX, mouseY));
    shader.set("u_time", millis());
    this.pg.beginDraw();
    this.pg.filter(shader);
    this.pg.endDraw();
  }
}
