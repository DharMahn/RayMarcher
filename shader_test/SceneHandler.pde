class SceneHandler {
  final int maxObj=10;
  final int maxLights=2;
  private float[] pos = new float[maxObj*3];
  private float[] size = new float[maxObj*3];
  private float[] colour = new float[maxObj*3];
  private int[] shapeType = new int[maxObj];
  private float[] lightspos = new float[maxLights*3];
  private float[] lightsintensity = new float[maxLights*3];
  ArrayList<Shape> shapes = new ArrayList<Shape>();
  ArrayList<Light> lights = new ArrayList<Light>();
  Random r = new Random();


  public void rebuildScene() {
    int index = 0;
    for (Shape shape : shapes) {
      pos[index] = shape.position.x;
      pos[index+1]=shape.position.y;
      pos[index+2]=shape.position.z;
      size[index] = shape.size.x;
      size[index+1]=shape.size.y;
      size[index+2]=shape.size.z;
      colour[index] = shape.colour.x;
      colour[index+1]=shape.colour.y;
      colour[index+2]=shape.colour.z;
      shapeType[index/3] = shape.shapeType;
      index+=3;
    }
    index=0;
    for (Light light : lights) {
      lightspos[index] = light.position.x;
      lightspos[index+1]=light.position.y;
      lightspos[index+2]=light.position.z;
      lightsintensity[index] = light.intensity.x;
      lightsintensity[index+1]=light.intensity.y;
      lightsintensity[index+2]=light.intensity.z;
      println(light.toString(1));
      //println(lightspos[index] + "-" + lightspos[index+1] + "-"+ lightspos[index+2]);
      index+=3;
    }
  }
  public void LoadScene() {
  }

  public void generateRandomShapes(int shapeCount) {
    shapes=new ArrayList<Shape>();
      shapes.add(new Shape(new PVector(0, -4, 0), new PVector(50f, 1f, 50f), new PVector(r.nextFloat(), r.nextFloat(), r.nextFloat()), 3));
    for (int i = 1; i < shapeCount; i++) {
      float slice = PI/shapeCount;
      shapes.add(new Shape(new PVector((cos(slice*i))*i*8f, 0, (sin(slice*i))*i*8f), new PVector(2f, 1f, 1f), new PVector(r.nextFloat(), r.nextFloat(), r.nextFloat()), r.nextInt(3)));
    }
    rebuildScene();
  }

  public void generateRandomLights(int lightCount) {
    lights=new ArrayList<Light>();
    for (int i = 0; i < 2; i++) {
      lights.add(new Light(new PVector(r.nextInt(50)-25, r.nextInt(10)+5, r.nextInt(50)-25), new PVector(.5f, .5f, .5f)));
    }
    rebuildScene();
  }

  public float[] getPos() {
    return pos;
  }
  public float[] getSize() {
    return size;
  }
  public float[] getColour() {
    return colour;
  }
  public int[] getShapeType() {
    return shapeType;
  }
  public float[] getLightsPos() {
    return lightspos;
  }
  public float[] getLightsIntensity() {
    return lightsintensity;
  }

  public String[] getShapesList() {
    ArrayList<String> nameList = new ArrayList<String>();
    for (Shape shape : shapes) {
      nameList.add(shape.name);
    }
    return nameList.toArray(new String[0]);
  }
}
