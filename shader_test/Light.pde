class Light {
  public PVector position;
  public PVector intensity;
  public String name;

  public Light(PVector position, PVector intensity, String name) {
    this.position=position;
    this.intensity=intensity;
    this.name=name;
  }
  public Light(PVector position, PVector intensity) {
    this.position=position;
    this.intensity=intensity;
    this.name="anonymous";
  }
  public String toString(int val) {
    return position.x + "-" + position.y+"-"+position.z + " intensity:"+intensity.x + "-" + intensity.y+"-"+intensity.z;
  }
}
