PImage img; //working image
String output;
int image_index, current_line_index = 0; //current image from folder, to add button to change image OR ad button to load image manually // Current measurement line
ArrayList<Line> lines; //Where the measurement lines are stored
PVector pos, ori; //Panning position //Center of screen
float scl; //Scaling factor
String path; //Path to current image
ArrayList<Button> buttons; //flexible list with buttons
int text_size = 24;

void setup () {
  size(1000,600);
  surface.setTitle("Let's measure things!");
  surface.setResizable(true);
  smooth(0);
  
  
  
  //Where the measurement lines are stored
  lines = new ArrayList<Line>();
  AddLine(); //First line added
  
  //LOADING 1st image (getting path to image folder)
  selectInput("Select file", "FileSelected");
  
  
  //The vector that stores panning
  pos = new PVector(0, 0);
  
  //Initial image scale
  scl = 0.3;
  
  //Variable to store all the buttons
  buttons = new ArrayList<Button>();
  buttons.add(new Button(new PVector(40, -60), "Add line", 'a', "AddLine"));
  buttons.add(new Button(new PVector(200, -60), "Previous image", 'p', "PreviousImage"));
  buttons.add(new Button(new PVector(450, -60), "Current", '\'', "")); //this uses the button drawing code and art, but is only for information (of the current image index)
  buttons.add(new Button(new PVector(450, -120), "Load image", 'l', "LoadOtherImage"));
  buttons.add(new Button(new PVector(620, -60), "Next image", 'n', "NextImage"));
  buttons.add(new Button(new PVector(820, -60), "Clear lines", 'c', "ClearLines"));
  buttons.add(new Button(new PVector(40, 60), "Save Measurements", 's', "SaveMeasurements"));
}





void draw () {
  if (img == null) {
    DisplayLoading();
    return;
  }
  if (img.width == 0) {
    DisplayLoading();
    return;
  }
  
  PositionScreen ();
  DisplayImage();
  DisplayMeasurements();
  ResetScreen();
  
  UpdateAllButtons();
}


void SaveMeasurements() {
  selectOutput("Select a notepad to write in", "WriterSelected");
}

void WriterSelected(File selection) {
  output = selection.getAbsolutePath();
  
  int number_of_lines = lines.size();
  if (lines.get(lines.size()-1).len == 0) { //this could be a bug because of how selection works, i can be working on a line, or I could be on next line with length 0
    number_of_lines--; //remove 1 line in case the last one is length 0
  }
  
  String[] measurements = new String[number_of_lines + 1]; //measurements String Array to store all lines that will be inputed into the file, and the titles
  measurements[0] = "index" + "\t" + "length" + "\t" + "delta_length" + "\t" + "angle" + "\t" + "area"; //insert the title line
  
  for (int i = 0; i < number_of_lines; i++){
    Line l = lines.get(i);
    String measurement = str(i+1) + "\t" + str(l.len) + "\t" + str(l.delta_len) + "\t" + str(l.alpha) + "\t" + str(l.area);
    measurements[i+1] = measurement;
  }
  
  saveStrings(output, measurements); 
}

void DisplayLoading(){
  background(50);
  strokeWeight(20);
  stroke(255);
  PVector center = new PVector(width / 2, height / 2);
  point(center.x + cos(millis() / 100.0) * 60, center.y + sin(millis() / 100.0) * 60);
  textSize(text_size);
  textAlign(CENTER, CENTER);
  fill(255);
  text("Loading...", center.x, center.y - 100);
  
}

void PositionScreen () {
  //Positioning----------------------------------------------------------------------------------
  pushMatrix();
  //Vector to store center of the screen, needs to be in DRAW function because screen can be resized
  ori = new PVector(width/2, height/2);
  translate(ori.x, ori.y);
  translate(pos.x*scl, pos.y*scl);
  scale(scl);
}

void DisplayImage() {
  background(50);
  //Draw the working image
  imageMode(CENTER);
  image(img, 0, 0);
}

void DisplayMeasurements() {
  //Draw the measurement lines and length values
  for (int i = 0; i < lines.size(); i++){
    int measurement_index = i + 1;
    lines.get(i).show(measurement_index);
  }
}

void ResetScreen() {
  //return Positioning--------------------------------------------------------------------------
  popMatrix();
}

void UpdateAllButtons() {
  for (int i = 0; i < buttons.size(); i++){
    Button b = buttons.get(i);
    b.Update();
    b.Display();
  }
}

void LoadOtherImage() {
  selectInput("Select file", "FileSelected");
}

void FileSelected(File selected){
  path = selected.getAbsolutePath();
  
  ChangeImage(0);
  
  image_index = GetCurrentImageIndex();
  
  ClearLines();
}


int GetCurrentImageIndex(){
  String[] path_split = split(path, "(");
  String[] path_split2 = split(path_split[path_split.length - 1], ")");
  
  return int(path_split2[0]);
}

int GetCurrentLineLength() {
  return lines.get(current_line_index).points.size();
}

void ChangeImage(int index_dif){
  //split by "(" and get the last iten in the array (should only be the number and extension)
  String[] path_split = split(path, "(");
  //split the last iten in the previous array by ")" and get the first iten (should only be the index of the image)
  String[] path_split2 = split(path_split[path_split.length - 1], ")");
  //get the number previsously isolated (the image index)
  int current_index = int(path_split2[0]);
  //Replace it by the new index
  path_split2[0] = str(current_index + index_dif);
  //join the last part of the path back together (index and extention)
  String path2 = join(path_split2, ")");
  //Replace the last part of the hole path with the just joined end piece
  path_split[path_split.length - 1] = path2;
  //join the whole path back together
  path = join(path_split, "(");
  img = requestImage(path);
  //replace the index approprietly
  image_index += index_dif;
  
  
  for (int i = 0; i < buttons.size(); i++){
    buttons.get(i).Released();
  }
}

void NextImage (){
  image_index = GetCurrentImageIndex();
  
  ChangeImage(1);
  
  ClearLines();
}

void PreviousImage (){
  if(image_index<2){
    return;
  }
  image_index = GetCurrentImageIndex();
  
  ChangeImage(-1);
  
  ClearLines();
}


void ClearLines() {
  current_line_index = 0;
  lines = new ArrayList<Line>();
  lines.add(new Line()); //first line added
}


void AddPoint() {
  Line l = lines.get(current_line_index);
  l.AddPoint(new PVector(mouseX - pos.x*scl - ori.x, mouseY - pos.y*scl - ori.y).div(scl));
}


void AddLine() {
  if(lines.size() <= 0) {
    current_line_index = 0;
    lines.add(new Line());
    return;
  }
  if(lines.get(current_line_index).points.size() != 0){
    lines.add(new Line());
    current_line_index++;
  }
}

void RemoveLine() {
  //if no lines exist just skip, to avoid bugs
  if(lines.size() == 0){
    return;
  }
  
  //when removing line first delete current line, but keep it selected. If current line has no length, then 
  if(GetCurrentLineLength() <= 0){
    lines.remove(lines.size() - 1);
    current_line_index--;
  } else {
    lines.remove(lines.size() - 1);
    current_line_index--;
    AddLine();
  }
  
  if (lines.size() <= 0) {
    current_line_index = 0;
    lines.add(new Line());
  }
}

void PanImage() {
  float dx = mouseX - pmouseX;
  float dy = mouseY - pmouseY;
  pos.x += dx/scl;
  pos.y += dy/scl;
}







void mouseWheel(MouseEvent event) {
  float scroll = event.getCount();
  float diff = scroll*0.06*scl;
  scl += diff;
}

void mouseDragged() {
  for (int i = 0; i < buttons.size(); i++){
    if(buttons.get(i).clicked){
      return; //if the drag started at any button this function will get skipped
    }
  }
  
  if(img.width == 0) {
    return;
  }
  
  if(mouseButton == RIGHT) {
    PanImage();
  }
  if(mouseButton == LEFT) { //Add new point to current line
    AddPoint();
  } 
}

void mousePressed() {
  for (int i = 0; i < buttons.size(); i++){
    buttons.get(i).Click();
  }
}

void mouseReleased() {
  for (int i = 0; i < buttons.size(); i++){ //repeated inside the changeimage()
    buttons.get(i).Released();
  }
}

void mouseClicked() {
  if(mouseButton == RIGHT) { //Erase last line added
    RemoveLine();
  }
}

void keyPressed() {
  for (int i = 0; i < buttons.size(); i++){
    buttons.get(i).LetterPressed(key);
  }
}

void keyReleased() {
  for (int i = 0; i < buttons.size(); i++){
    buttons.get(i).Released();
  }
}
