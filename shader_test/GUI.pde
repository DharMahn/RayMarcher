class GUI {
  public ControlP5 cp5;
  int minY;
  int minX;
  PFont font;
  ScrollableList objectList;
  CallbackListener keyboardCallbackListener = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        //case(ControlP5.PRESSED): openKeyboard();
      }
    }
  };
  public GUI() {
    minY=(displayWidth)+10;
    minX=10;
    font = createFont("Arial", 28);
  }
  public void setControl(ControlP5 cp5) {
    this.cp5 = cp5;
    //cp5.setFont(new ControlFont(
  }
  public void LoadGUI(String[] objects) {
    objectList=cp5.addScrollableList("objectList")
      .setPosition(minX, minY+50)
      .addItems(objects)
      .setOpen(false)
      .setSize(200, displayHeight-minY+50)
      .setFont(font)
      .setBarHeight(50)
      .setItemHeight(50)
      ;
    cp5.addTextfield("X").setPosition(minX, minY).setSize((displayWidth/4)-20, 40).addCallback(keyboardCallbackListener).setAutoClear(true).setFont(font);
    cp5.addTextfield("Y").setPosition(minX+(displayWidth/4), minY).setSize((displayWidth/4)-20, 40).addCallback(keyboardCallbackListener).setAutoClear(true).setFont(font);
    cp5.addTextfield("Z").setPosition(minX+(displayWidth/4)*2, minY).setSize((displayWidth/4)-20, 40).addCallback(keyboardCallbackListener).setAutoClear(true).setFont(font);
    //cp5.addScrollableList("objectList").setPosition(displayWidth-(displayWidth/20),160).setOpen(false);
    AddObjectsToList(objects);
    Button keyboardButton = cp5.addButton("keyboardButton").setPosition(minX+(displayWidth/4)*3, minY).setSize(160, 40).activateBy(ControlP5.PRESS).setCaptionLabel("Keyboard").setFont(font);
    println("asd");
  }
  public void keyboardButton(int val) {
    //openKeyboard(); 
    background(255);
  }
  public void AddObjectsToList(String[] objects) {
    //cp5.getController("objectList").addItems(objects);
    //cp5.remove("objectList");
    
  }
  public void AddObjectToList(String object) {
  }
}
