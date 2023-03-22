class Line {
  //info to export ---> len, delta_len and alpha
  ArrayList<PVector> points = new ArrayList<PVector>();
  PVector first, last; //first point of the curve, and last point of the curve
  float len = 0; //length of the measuring curve
  float delta_len = 0; //distance from root tip to stem
  color color_selected, color_unselected, delta_len_color; //Color or the lines when selected = current (bright red), unselected (dark red) and the delta_len line (green)
  float alpha = 0; //angle of the delta_len line 0º is horizontal pointing RIGHT, 90 is pointing DOWN, 180 LEFT and 270 pointing UP
  float area = 0;
  
  Line() {
    color_selected = color(255, 0, 0);
    color_unselected = color(180, 0, 0);
    delta_len_color = color(30, 250, 30);
    first = new PVector();
    last = new PVector();
  }
  
  void AddPoint(PVector p){
    points.add(p);
  }
  
  void show (int _measurement_index) {
    if(current_line_index == _measurement_index - 1) { //if the line is the currently working line, calculate length, angle and area
      calculate_length();
    }
    
    
    //deslta_len LINE
    if(points.size() > 2) {
      strokeWeight(3);
      stroke(delta_len_color);
      int last_point_index = points.size() - 1;
      PVector p1 = points.get(0), p2 = points.get(last_point_index);
      line(p1.x, p1.y, p2.x, p2.y);
    }
    
    
    //Measurement CURVE
    strokeWeight(4);
    if(current_line_index == _measurement_index - 1) { //if the line is the currently working line, paint bright red
      stroke(color_selected);
    } else { //of not working line paint darker red
      stroke(color_unselected);
    }
    for(int i = 1; i < points.size(); i++) {
      PVector p1 = points.get(i-1), p2 = points.get(i);
      line(p1.x, p1.y, p2.x, p2.y);
    }
    
    
    //Index of the CURVE
    if (points.size() > 0) {
      textSize(64);
      fill(color_selected);
      textMode(CENTER);
      text(_measurement_index, points.get(0).x, points.get(0).y - 50);
    }
  }
  
  void calculate_length () { //Self explanatory
    if (points.size()<2) {
      return;
    }
    //Length of the curve
    len = 0;
    for(int i = 1; i < points.size(); i++) {
      PVector p1 = points.get(i-1), p2 = points.get(i);
      len += (PVector.sub(p1, p2)).mag();
    }
    
    //Distance from root tip to stem
    int last_point_index = points.size() - 1;
    first = points.get(0);
    last = points.get(last_point_index);
    delta_len = PVector.sub(last, first).mag();
    
    CalculateAngle();
    CalculateArea();
  }
  
  void CalculateAngle() {
    PVector diff = PVector.sub(last, first);
    alpha = degrees(atan2(diff.y, diff.x) + 2*PI) % 360;
  }
  
  void CalculateArea () {
    //Gauss' Shoelace Formula
    area = 0;
    for(int i = 0; i < points.size(); i++) {
      PVector p1 = points.get(i), p2 = points.get((i + 1) % points.size());
      area += p1.x * p2.y - p1.y * p2.x;
    }
    area /= 2;
    area = abs(area);
  }
}
