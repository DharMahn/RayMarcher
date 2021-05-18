class Shape {
  public PVector position;
  public PVector size;
  public PVector colour;
  public int shapeType;
  public String name;
  public Shape(PVector position, PVector size, PVector colour, int shapeType, String name){
    this.position = position;
    this.size=size;
    this.colour=colour;
    this.shapeType=shapeType;
    this.name=name;
  }
  public Shape(PVector position, PVector size, PVector colour, int shapeType){
    this.position = position;
    this.size=size;
    this.colour=colour;
    this.shapeType=shapeType;
    this.name="Anonymous";
  }
};
