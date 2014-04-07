//THIS CLASS IS A SECOND PAPPLET THAT FUNCTIONS AS THE IMAGE SELECTION WINDOW 
public class ImageSelectionWindow extends PApplet {

  TileExplorerGUI parent;
  ControlP5 cp5;
  
  PImage previewImage, textureImage;
  
  private int width, height;
  private PVector textureClipRectTL, textureClipRectBR;
  private PVector imageOffset;
  
  private float svgScale;
  
  private int clipBoxWidth, clipBoxHeight, clipBoxX, clipBoxY;
  private float scaleFactor;
  
  
  private Numberbox box_width, box_height, box_x, box_y;
  private float controlHandleRadius = 15; 
  
  private boolean dragging, resizing;
  private PVector mouseDragOffsetTL, mouseDragOffsetBR;
  
  
  
  
  private ImageSelectionWindow() {
  }

  public ImageSelectionWindow(TileExplorerGUI theParent, int theWidth, int theHeight) {
    parent = theParent;
    this.width = theWidth;
    this.height = theHeight;
  }


  
  public void setup() {
    size(this.width, this.height);
    frameRate(25);
   
   
    imageOffset = new PVector(0,0);
   
    createGuiControls();    
    setTextureClipRect(new PVector(0,0), new PVector(0,0));
    
  }
  
  
  void controlEvent(ControlEvent theEvent) {
    if(theEvent.isFrom(box_x) || theEvent.isFrom(box_y) || theEvent.isFrom(box_width) || theEvent.isFrom(box_height)) {
       setTextureClipRect(new PVector(clipBoxX,clipBoxY,0), new PVector(clipBoxX+clipBoxWidth,clipBoxY+clipBoxHeight,0));
       constrainTextureClipRect();
    }
  }
  
  
  public void randomize(int value){
    
    float wdth = clipBoxWidth > 0 ? clipBoxWidth : random(previewImage.width);
    float hght = clipBoxHeight > 0 ? clipBoxHeight : random(previewImage.height);
    float x = random((previewImage.width)-wdth);
    float y = random((previewImage.height)-hght);
    

    clipBoxX = (int)(x);
    clipBoxY = (int)(y);
    box_x.setValue(clipBoxX);
    box_y.setValue(clipBoxY);
    
    setTextureClipRect(new PVector(x,y), new PVector(x+wdth,y+hght));
    
    parent.generate(0);

  }
  
 
  public void setImage(PImage i_img){
     
    textureImage = i_img.get();
    previewImage = textureImage.get();
    
    if(previewImage.width > previewImage.height){
       previewImage.resize(this.width, 0);
    }
    else{
       previewImage.resize(0,this.height-150);
    }
   
    scaleFactor = previewImage.width/(i_img.width+0.0); 
    
    imageOffset = new PVector();
    imageOffset.x = this.width/2-previewImage.width/2;
    imageOffset.y = this.height/2-previewImage.height/2;
    
    setTextureClipRect(new PVector(0,0), new PVector(previewImage.width, previewImage.height, 0));
  }
  
  

  public void draw() {
      background(180);
      
      if(previewImage != null){
       image(previewImage, imageOffset.x, imageOffset.y); 
      }
      
      noFill();
      strokeWeight(2);
      stroke(255,0,0);
      rect(textureClipRectTL.x+imageOffset.x, textureClipRectTL.y+imageOffset.y, textureClipRectBR.x - textureClipRectTL.x, textureClipRectBR.y - textureClipRectTL.y );
      
      fill(255,0,0, 200);
      noStroke();
      ellipse(textureClipRectBR.x+imageOffset.y, textureClipRectBR.y+imageOffset.y, controlHandleRadius, controlHandleRadius);
      
  }
  
  
  
  void mousePressed(){
    if(textureImage != null){
               
      PVector mousePos = getOffsetMousePos();
      
      if(PVector.dist(textureClipRectBR, mousePos) < controlHandleRadius){
        println("BANG");
        resizing = true;
        dragging = false; 
      }else if(mousePos.x > textureClipRectTL.x && mousePos.y > textureClipRectTL.y && mousePos.x < textureClipRectBR.x && mousePos.y < textureClipRectBR.y){
        dragging = true;
        resizing = false;
        mouseDragOffsetTL = new PVector(mousePos.x - textureClipRectTL.x, mousePos.y - textureClipRectTL.y);
        mouseDragOffsetBR = new PVector(mousePos.x - textureClipRectBR.x, mousePos.y - textureClipRectBR.y);
      }
         
    }
  }
  
  
  void mouseDragged(){
    if(textureImage != null){
      
          PVector mousePos = getOffsetMousePos();
      
          if(dragging){
              
              setTextureClipRect(PVector.sub(mousePos, mouseDragOffsetTL), PVector.sub(mousePos, mouseDragOffsetBR));
              
          }else if(resizing){
              
              setTextureClipRect(textureClipRectTL, mousePos);
            
          }

          constrainTextureClipRect();
      
          clipBoxWidth = (int)abs(textureClipRectTL.x-textureClipRectBR.x);
          clipBoxHeight = (int)abs(textureClipRectTL.y-textureClipRectBR.y);
          clipBoxX = (int)min(textureClipRectTL.x,textureClipRectBR.x);
          clipBoxY = (int)min(textureClipRectTL.y,textureClipRectBR.y);
          box_x.setValue(clipBoxX);
          box_y.setValue(clipBoxY);
          box_width.setValue(clipBoxWidth);
          box_height.setValue(clipBoxHeight);
       
    }
  }
  
  PVector getOffsetMousePos(){
   
   PVector offsetMouse = new PVector(mouseX, mouseY);
   offsetMouse.sub(imageOffset);
   return offsetMouse; 
    
  }
  
  void mouseReleased(){
    resizing = false;
    dragging = false;
  }
  
  
  private void setTextureClipRect(PVector i_TL, PVector i_BR){
    textureClipRectTL = i_TL;
    textureClipRectBR = i_BR;
  }
  
  void constrainTextureClipRect(){
    
   textureClipRectTL.x = max(textureClipRectTL.x, 0);
   textureClipRectTL.y = max(textureClipRectTL.y, 0);
   textureClipRectTL.x = min(this.width-imageOffset.x-(textureClipRectBR.x - textureClipRectTL.x), textureClipRectTL.x);
   textureClipRectTL.y = min(this.height-imageOffset.y-(textureClipRectBR.y - textureClipRectTL.y), textureClipRectTL.y);
    
   textureClipRectBR.x = max(textureClipRectBR.x, textureClipRectTL.x+10);
   textureClipRectBR.y = max(textureClipRectBR.y, textureClipRectTL.y+10);
   textureClipRectBR.x = min(previewImage.width, textureClipRectBR.x);
   textureClipRectBR.y = min(previewImage.height, textureClipRectBR.y);
   
  }
  
  public PImage getCropSection(){
   
    return textureImage.get((int)(textureClipRectTL.x/scaleFactor), (int)(textureClipRectTL.y/scaleFactor), (int)((textureClipRectBR.x - textureClipRectTL.x)/scaleFactor), (int)((textureClipRectBR.y - textureClipRectTL.y)/scaleFactor));
    
  }
  
  
  void loadTextureImage(int val) {
    selectInput("Select an image", "loadTextureImage");
  }
  
  void loadTextureImage(File selection) {
    
    if (selection == null) {
      println("Window was closed or the user hit cancel.");
    } 
    else {
      
      PImage chosenImage; 
      String path = selection.getAbsolutePath();
      String suffix = path.substring(path.length()-3);
  
      if (suffix.equals("svg")) {
        PShape iFile =  loadShape(path);
        SVGTile svgTile = new SVGTile(iFile, svgScale);
        chosenImage = svgTile.drawTile();
      }
      else {
        chosenImage = loadImage(path);
      }
  
      this.setImage(chosenImage);
     
    }
  }
 


  public ControlP5 control() {
    return cp5;
  }
  
  
  
  void createGuiControls(){
    cp5 = new ControlP5(this);
        
    cp5.addButton("LoadImage")
    .plugTo(this,"loadTextureImage")
    .setPosition(20,20);
    
    cp5.addButton("generate")
    .plugTo(parent,"generate")
    .setPosition(100,20);
    
    cp5.addButton("randomize")
    .setPosition(180,20);
    
    box_width = cp5.addNumberbox("box_width")
    .setPosition(280, 20)
      .setSize(45, 14)
        .setScrollSensitivity(1.1)
          .setValue(0)
            .setRange(0,10000)
              .plugTo(this,"clipBoxWidth");
            
              
    box_height = cp5.addNumberbox("box_height")
    .setPosition(350, 20)
      .setSize(45, 14)
        .setScrollSensitivity(1.1)
          .setValue(0)
            .setRange(0,10000)
              .plugTo(this,"clipBoxHeight");
              
    box_x = cp5.addNumberbox("box_x")
    .setPosition(450, 20)
      .setSize(45, 14)
        .setScrollSensitivity(1.1)
          .setValue(0)
            .setRange(0,10000)
               .plugTo(this,"clipBoxX");

            
    box_y = cp5.addNumberbox("box_y")
    .setPosition(520, 20)
      .setSize(45, 14)
        .setScrollSensitivity(1.1)
          .setValue(0)
            .setRange(0,10000)
              .plugTo(this,"clipBoxY"); 
    
  }
  
}
//--------------------------------------------------------------------------------------------------------------------------
