/*---------------------------------------------------------------------------------------------
*
*    GUI FILE, due to limitations with the processing IDE this hasn't been put into a class as of yet
*    
*    creates GUI and controls 
*
*    Ben Jack 12/4/2014 
*
*---------------------------------------------------------------------------------------------*/

  import java.awt.Frame;
  import java.awt.BorderLayout;
  import controlP5.*;
  
  
  
  
  
  //--------------------GLOBAL VARIABLES-------------------
  
  public final String[] gridTypes = {"HEX", "TRI", "SQUARE", "VORONOI", "DELAUNAY"}; 
  public final int HEXAGONGRID = 0;
  public final int TRIANGLEGRID = 1;
  public final int SQUAREGRID = 2;
  public final int VORONOIGRID = 3;
  public final int DELAUNAYGRID = 4;
  public int currentGridType;
  
  Frame ImageWindowFrame, vdGUIFrame;
  
  private ControlP5 cp5;
  private ImageSelectionWindow imageWindow;
  private VoronoiDelaunayGUIWindow voronoiDelaunayWindow;
  
  RadioButton gridTypeButton;
  Textfield printWidthField, printHeightField;
  Button maskImageBtn;
  Group globalControls, gridControls;
  
  private int printWidthValue = 1000;
  private int printHeightValue = 1000;
  private float cellRadius = 100;
  private boolean drawGrid = false;
  private boolean triggerGeneration = false;
  
  private PImage textureImage, maskImage, backgroundImage;
  
  
  
  
  
  
  
  //-----------------------------------PUBLIC METHODS--------------------------------------
  
  
  /*
  *   initialize GUI
  */
  
  public void setupTileExplorerGUI() {
    cp5 = new ControlP5(this);
  
    gridControlGroup();
    globalControlGroup();
  
    imageWindow = addImageWindow("patternImage", 600, 600);
    voronoiDelaunayWindow = addVdGUIWindow("voronoi controls", 600, 600);
    toggleWindows(HEXAGONGRID);
    
    backgroundImage = createCheckerBackground();
  }
  
 
  /*
  *   draw GUI and images (main draw function)
  */
  
  public void drawGui(){
    
    update();
    
    image(backgroundImage, 0, 0);
    PImage patternImage = gridGenerator.getPreviewImage();
    image(patternImage, (width-patternImage.width)/2,  (height-patternImage.height)/2);
   
    if(drawGrid){
      PImage gridImage = gridGenerator.getGridImage();  
      image(gridImage, (width-gridImage.width)/2,  (height-gridImage.height)/2);
    }
   
    fill(180, 200);
    noStroke();
    rect(0,490, 160, height-490);
    
    PImage previewImage = gridGenerator.getUnitImage();
    image(previewImage, 20, 500);

  }
  
  
  
  /*
  *   flag program to generate the pattern. This is seperated from
  *   the actual code to generate the pattern because openGL calls
  *   can only be in the main thread and the GUI button calls run in
  *   a second thread.
  */
  
  public void generate() { 
    triggerGeneration = true;
  }
  
  
  
  /* 
  *   set whether to use a mask or not (1=use mask, 0=dont use. not boolean due to controlP5 limitations). 
  */
  
  public void useMask(int i_useMask){
    gridGenerator.useMask(i_useMask==1);
  }
  
  
  
  /* 
  *   set missing odds (chance a grid tile will not be drawn)
  */
  
  public void missingOdds(float i_odds){
   gridGenerator.setMissingOdds(i_odds); 
  }
  
  
  
  /* 
  *   returns current render mode. possible values are currently JAVA2D or P2D.
  */
  
  public String getRenderMode(){
    return gridGenerator.getRenderMode();
  }
  
  
  
  /* 
  *   image save. Images are saved in nested folders ordered by date and time
  */
  
  String[] months = {
      "january", "febuary", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"
  };
  
  public void saveImage(int guiJunk) { 
    String path = "images/"+year()+"/"+months[month()-1]+"/"+day()+"/images/"+hour()+"_"+minute()+"_"+second()+"--"+gridTypes[currentGridType];
    gridGenerator.saveImage(path, ".png", drawGrid);
  }  
  
  
  /* 
  *   tile save. Images are saved in nested folders ordered by date and time
  */
  
  public void saveTile() { 
    
    String path = "images/"+year()+"/"+months[month()-1]+"/"+day()+"/tiles/"+hour()+"_"+minute()+"_"+second()+"--"+gridTypes[currentGridType];
    gridGenerator.saveTile(path+".png");

  } 
  
  
  
  /*
  *   choose grid type. current possibilities are HEXAGONGRID, TRIANGLEGRID, SQUAREGRID, VORONOIGRID, or DELAUNAYGRID
  */
  
  public void changeGridType(int i_type) {
  
    toggleWindows(i_type);
    
    switch(i_type) {
    case HEXAGONGRID:
      gridGenerator = new HexGrid(gridGenerator);
      break;
  
    case TRIANGLEGRID:
      gridGenerator = new TriGrid(gridGenerator);
      break;
  
    case SQUAREGRID:
      gridGenerator = new SquareGrid(gridGenerator);
      break;
      
    case VORONOIGRID:
      irregularGridGenerator = new VoronoiDelaunayGrid(gridGenerator);
      gridGenerator = irregularGridGenerator;
      irregularGridGenerator.setType(irregularGridGenerator.VORONOI);
      voronoiDelaunayWindow.setGridType(VORONOIGRID);
      imageWindow.showTriSelectButton();
      break;

    case DELAUNAYGRID:
      irregularGridGenerator = new VoronoiDelaunayGrid(gridGenerator);
      gridGenerator = irregularGridGenerator;
      irregularGridGenerator.setType(irregularGridGenerator.DELAUNAY);
      voronoiDelaunayWindow.setGridType(DELAUNAYGRID);
      imageWindow.showTriSelectButton();
      break;
  
    default:
      gridGenerator = new HexGrid(gridGenerator);
      break;
    }
   
    currentGridType = i_type;
    
  }
  
  
  
  
  /*
  *   data update function
  */
  
  public void update(){
    
    if(triggerGeneration){
      
       if(currentGridType == VORONOIGRID || currentGridType == DELAUNAYGRID){
         irregularGridGenerator.clearPoints();
         irregularGridGenerator.addNormalizedPoints(gridGenerator.getRenderSize(), voronoiDelaunayWindow.getNormalizedPoints());
       }
       
       generatePattern(); 
    }
   
  }
  
  

  /*
  *   open mask selection filepicker
  */
  
  public void loadMask(int val) {
    selectInput("Select an image", "maskSelected");
  }
  
  
  
  //--------------------------------------PRIVATE METHODS----------------------------------------
  //although some of these are public due to controlP5 needs or otherwise, they shouldn't be used 
  
  
  /*
  *   creates image selection GUI window
  */

  private ImageSelectionWindow addImageWindow(String theName, int theWidth, int theHeight) {
    ImageWindowFrame = new Frame(theName);
    ImageSelectionWindow p = new ImageSelectionWindow(this, theWidth, theHeight);
    ImageWindowFrame.add(p);
    p.init();
    ImageWindowFrame.setTitle(theName);
    ImageWindowFrame.setSize(p.width, p.height);
    ImageWindowFrame.setLocation(0, 0);
    ImageWindowFrame.setResizable(false);
    ImageWindowFrame.setVisible(true);
    return p;
  }
  
  
  /*
  *   creates voronoi/delaunay grid interface window
  */

  private VoronoiDelaunayGUIWindow addVdGUIWindow(String theName, int theWidth, int theHeight) {
    vdGUIFrame = new Frame(theName);
    VoronoiDelaunayGUIWindow p = new VoronoiDelaunayGUIWindow(this, irregularGridGenerator, theWidth, theHeight);
    vdGUIFrame.add(p);
    p.init();
    vdGUIFrame.setTitle(theName);
    vdGUIFrame.setSize(theWidth, theHeight);
    vdGUIFrame.setLocation(0, 650);
    vdGUIFrame.setResizable(false);
    vdGUIFrame.setVisible(true);
    return p;
  }
  
  
  
  /*
  *   callback function for mask selection filepicker
  */
  
  public void maskSelected(File selection) {
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } 
    else {
      maskImage = loadImage(selection.getAbsolutePath());
      gridGenerator.setMask(maskImage);
    }
  
    PImage tempImg = maskImage.get();
    if (tempImg.width > tempImg.height)
      tempImg.resize(120, 0);
    else
      tempImg.resize(0, 120);
  
    maskImageBtn.setImage(tempImg);
  }  
  
  

  
  /*
  *   draws a grey and white checker pattern to a PGraphics object
  */
  
  private PImage createCheckerBackground(){
   
    int checkerCount = 100;
    PGraphics checkerGfx = createGraphics(width, height);
    
    float boxWidth = width/(checkerCount+0.0);
    
    checkerGfx.beginDraw();
    checkerGfx.background(255);
    checkerGfx.fill(200);
    checkerGfx.noStroke();
    
    for(int i = 0; i < checkerCount; ++i){
      for(int j = 0; j < checkerCount; ++j){
       if((i % 2 == 0 && j % 2 == 0) || (i % 2 == 1 && j % 2 == 1)){
         checkerGfx.rect(i*boxWidth, j*boxWidth, boxWidth, boxWidth);
       }
      }
    }
    
    checkerGfx.endDraw();  
    
    return checkerGfx;
  }
  
  
  
  /*
  *   the function that actually generates the pattern. This is
  *   seperated from generate() because openGL calls can only be
  *   in the main thread and the GUI button calls run in a second thread.
  */
  
  private void generatePattern(){
   
    printWidthField.submit();
    printHeightField.submit();
    gridGenerator.setTexture(imageWindow.getCropSection());
    gridGenerator.setTextureCoords(imageWindow.getTextureCoords());
    gridGenerator.setCellRadius(cellRadius);
  
    gridGenerator.generate();
    
    triggerGeneration = false;
    
  }
  
  
  /*
  *   helper functions to turn textbox input into integers
  */
  
  private void printWidth(String i_value) {
    printWidthValue = Integer.parseInt(i_value);  
    gridGenerator.setRenderSize(new PVector(printWidthValue, printHeightValue));
  }
  
  private void printHeight(String i_value) {
    printHeightValue = Integer.parseInt(i_value);
    gridGenerator.setRenderSize(new PVector(printWidthValue, printHeightValue));
  }
  
  
  private void toggleWindows(int i_type){
   
   switch(i_type){
    case HEXAGONGRID:
    case TRIANGLEGRID:
    case SQUAREGRID:
        vdGUIFrame.setVisible(false);
    break;
    
    case VORONOIGRID:
    case DELAUNAYGRID:
        vdGUIFrame.setVisible(true);
    break;
    
    default:
    break;
    
   } 
    
  }
  
  
  
  //------------------------------------------ACTUAL GUI CREATION------------------------------------------
  
  void globalControlGroup() {
        
    cp5.addToggle("drawGrid")
      .setPosition(1000-40, 20)
        .setSize(20, 20);
  
    globalControls = cp5.addGroup("globalControls")
      .setPosition(0, 10)
        .setBackgroundHeight(210)
          .setWidth(160)
            .setBackgroundColor(color(0, 90));
  
    printWidthField = cp5.addTextfield("printWidth")
      .setPosition(20, 20)
        .setSize(50, 14)
          .setValue("1000")
            .setAutoClear(false)
              .setGroup(globalControls)
                .setInputFilter(ControlP5.INTEGER);
  
    printHeightField = cp5.addTextfield("printHeight")
      .setPosition(90, 20)
        .setSize(50, 14)
          .setValue("1000")
            .setAutoClear(false)
              .setGroup(globalControls)
                .setInputFilter(ControlP5.INTEGER);  
  
    gridTypeButton = cp5.addRadioButton("changeGridType")
      .setPosition(20, 80)
        .setSize(10, 10)
          .setItemsPerRow(3)
            .setSpacingColumn(30)
              .setSpacingRow(20)
                .addItem("Hex", HEXAGONGRID)
                  .addItem("Tri", TRIANGLEGRID)
                    .addItem("Square", SQUAREGRID)
                      .addItem("Voronoi", VORONOIGRID)
                        .addItem("Delaunay", DELAUNAYGRID)
                          .setGroup(globalControls);
  
    gridTypeButton.activate(0);
  
    cp5.addNumberbox("cellRadius")
      .setPosition(20, 140)
        .setSize(50, 14)
          .setScrollSensitivity(1.1)
            .setValue(100)
              .setRange(10, 5000)
                .setGroup(globalControls);
  
    cp5.addNumberbox("svgScale")
      .setPosition(90, 140)
        .setSize(50, 14)
          .setRange(0.1, 50)
            .setMultiplier(0.1)
              .setScrollSensitivity(0.1)
                .setValue(1.0)
                  .setGroup(globalControls);
  
    cp5.addButton("generate")
      .setPosition(20, 180)
        .setSize(50, 20)
          .setGroup(globalControls);
  
    cp5.addButton("saveImage")
      .setPosition(90, 180)
        .setSize(50, 20)
          .setGroup(globalControls);
          
          
    cp5.addButton("save Tile")
      .setPosition(20, 600)
        .setSize(50, 20)
        .plugTo(this,"saveTile");

        
    cp5.addButton("save Image")
      .setPosition(90, 600)
        .setSize(50, 20)
          .plugTo(this,"saveImage");
  }
  
  
  //GRID GUI SETUP
  void gridControlGroup() {
  
    gridControls = cp5.addGroup("gridControls")
      .setPosition(0, 230)
        .setBackgroundHeight(250)
          .setWidth(160)
            .setBackgroundColor(color(0, 90));  
  
  
    cp5.addSlider("missingOdds")
      .setPosition(20, 20)
        .setSize(80, 20)
          .setRange(0, 1)
            .setGroup(gridControls);
  
  
    cp5.addToggle("useMask")
      .setPosition(20, 60)
        .setSize(20, 20)
          .setGroup(gridControls);
  
  
    maskImageBtn = cp5.addButton("loadMask")
      .setPosition(20, 100)
        .setSize(120, 120)
          .setGroup(gridControls);
  }
  
  void keyPressed(){
    
   if(key == 'r'){
     
     if(getRenderMode() == P2D){
      gridGenerator.setRenderMode(JAVA2D); 
      imageWindow.hideTriSelectButton();
     }else{
      gridGenerator.setRenderMode(P2D); 
      imageWindow.showTriSelectButton();
     }
     
   }
   
  }

