class Button {
  PVector pos, rel_pos, size; //pos = current position; rel_pos = input position; size = width and height of button;
  String func, legend; //func = function to be called; legend = button name;
  char letter; //letter to be pressed as shortcut to button
  boolean hover, clicked; //is this button hovered? or clicked? or none?
  color col, col_hovered, col_clicked; //color if at rest, while hovered, and while clicked
  int pad = 20; //extra width
  
  Button(PVector pos, String legend, char letter, String func) {
    this.pos = pos;
    this.rel_pos = pos.copy();
    this.func = func;
    this.legend = legend + "(" + letter + ")";
    this.size = new PVector(0, 0);
    this.letter = letter;
    this.hover = false;
    this.clicked = false;
    col = color(170, 50, 11);
    col_hovered = color(118, 85, 63);
    col_clicked = color(200, 189, 157);
  }
  
  void Update() {
    this.ApplyPosSize();
    float x = pos.x, y = pos.y, w = size.x, h = size.y;
    
    if (mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h){
      hover = true;
    } else {
      hover = false;
    }
  }
  
  void Display() {
    this.ApplyPosSize();
    
    if(IsCurrent()) {
      ButtonShape(col);
      return;
    }
    
    if(clicked) {
      ButtonShape(col_clicked);
    } else if (hover) {
      ButtonShape(col_hovered);
    } else {
      ButtonShape(col);
    }
  }
  
  void ButtonShape(color c) {
    float x = pos.x, y = pos.y, w = size.x, h = size.y; //to shortcut the writting of positions, I'm lazy
    
    stroke(0);
    strokeWeight(2);
    fill(c);
    rect(x, y, w, h);
    
    noStroke();
    fill(0);
    textAlign(CENTER, CENTER);
    textSize(text_size);
    text(legend, x + w/2, y + h/2);
  }
  
  void ApplyPosSize() { //to addapt position and size based on window size and font size
    textSize(text_size);
    this.size = new PVector(textWidth(this.legend) + pad, 50);
    
    //invert in case X or Y pos are negative (adjust based on current width and height
    if (rel_pos.x < 0) {
      pos.x = width + rel_pos.x;
    }
    if (rel_pos.y < 0) {
      pos.y = height + rel_pos.y;
    }
  }
  
  void Click () {//if clicked check if it hovers
    if(hover) {
      this.Activate();
    }
  }
  
  void Activate() { //Calls the function "func"
    clicked = true;
    
    if(IsCurrent()){ //don't call any function if it is only a informative rectangle
      return;
    }
    
    method(func);
  }
  
  void Released () {
    clicked = false;
  }
  
  void LetterPressed (char c_pressed) {
    if(c_pressed == this.letter) {
      this.Activate();
    }
  }
  
  boolean IsCurrent() {
    if(letter == '\'') {
      //split by "(" and get the last iten in the array (should only be the number and extension)
      String[] legend_split = split(legend, "(");
      //split the last iten in the previous array by ")" and get the first iten (should only be the index of the image)
      String[] legend_split2 = split(legend_split[legend_split.length - 1], ")");
      //Replace it by the new index
      legend_split2[0] = str(GetCurrentImageIndex());
      //join the last part of the path back together (index and extention)
      String leg2 = join(legend_split2, ")");
      //Replace the last part of the hole path with the just joined end piece
      legend_split[legend_split.length - 1] = leg2;
      //join the whole path back together
      legend = join(legend_split, "(");
      return true;
    }
    return false;
  }
  
}
