/*


Úkol 3  (5 bodů)

Implementujte v Processingu systém pro interaktivní zobrazování velkých grafů se zvětšeným náhledem na okolí uzlů ve středu obrazovky.

Požadavky:

1) Po spuštění programu se vygenuruje náhodný obecný graf s náhodným rozmístěním uzlů

1) Uzly lze přemísťovat myší

2) Po kliknutí na uzel se zobrazí (dočasně nebo do dalšího kliknutí) jeho identifikace

3) Uzly trvale optimalizují svoji polohu na základě Vámi zvoleného algoritmu, s preferenčním umístěním uzlů s větší vahou ve středu grafu

4) Uzly mají náhodně přidělené váhy, které ovlivňují jejich vzhled a vliv na okolité uzly

5) Zobrazení zahušťuje a zmenšuje uzly daleko od středu obrazovky (např. transformací r = R - k/(sqrt(x^2+y^2) + 1; alfa = arcsin(x/r)), kde x a y jsou karteziánské souřadnice, r a alfa jsou polární souřadnice po transformaci, které je nutné převést na transformované karteziánské xnew = sin(alfa)*r; ynew = cos(alfa)*r)
6) Automaticke rozlozeni grafu musi dovolovat pohyb do stran a nahoru dolu
Termín: 14.11.2018

*/


int WINDOW_WIDTH = 640;
int WINDOW_HEIGHT = 480;

class VertexLabel {

  float x, y;
  String text;

  public boolean isVisible = false;
  public boolean isPersistent = false;

  VertexLabel(String text, float x, float y, boolean visible) {

    this.x = x;
    this.y = y;
    this.text = text;

    this.isVisible = visible;
  }

  VertexLabel(String text, float x, float y) {

    this.x = x;
    this.y = y;
    this.text = text;
  }

  public void draw() {

    if (this.isPersistent) {
      textFont(createFont("Arial Bold", 15));
    } else {
      textFont(createFont("Arial", 13));
    }
    text(this.text, this.x, this.y);
  }

  public void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class Vertex {

  float x, y;
  int radius = 20;
  
  int id;
  String name;

  color colour;

  VertexLabel label;

  Vertex(int id, float x, float y, String name, color col) {
    this.id = id;
    this.name = name;

    this.x = x;
    this.y = y;

    this.colour = col;
    this.label = new VertexLabel(this.name, x - this.radius, y - this.radius, false);

    setLabelPosition();
  }

  public void setPosition(float x, float y) {
    this.x = x;
    this.y = y;

    setLabelPosition();
  }

  public void setLabelPosition() {

      float x, y;

      x = this.x - this.radius;
      y = this.y - this.radius;

      this.label.setPosition(x, y);
  }

  public void draw() {
    stroke(0);
    if (!mouseOver()) {
      fill(this.colour);
    } else {
      // lower alpha value
      float r, g, b;
      r = red(this.colour);
      g = green(this.colour);
      b = blue(this.colour);

      fill(color(r + 30, g + 30, b + 30, 150));
    }

    ellipse(this.x, this.y, this.radius, this.radius);
  }

  public void drawText() {
    fill(10);

    this.label.isVisible = this.label.isPersistent ? true : mouseOver();

    if (this.label.isVisible) {
      this.label.draw();
    }
  }

  public boolean mouseOver() {
    float disX = this.x - mouseX;
    float disY = this.y - mouseY;

    if(sqrt(sq(disX) + sq(disY)) < (this.radius)) {
      return true;
    } else {
      return false;
    }
  }
}

// init values for selected variables
int n_vertices = 10; //number of graph n_vertices
int vertex_size = 20; //size of node symbol

int background = 226; //background color
int foreground = 255; //foreground - line color
color foreground_colour = color(100); // foreground - fill color 

//initialize n_vertices
Vertex[] vertices = new Vertex[n_vertices];

//matrix with values of 1 for n_vertices connected by edges
int[][] edges = new int[n_vertices][n_vertices];

void setup() {
  size(640, 480);
  smooth(); 

  // randomly initialize vertices
  for (int i = 0; i < n_vertices; i++) {

    float x = random(0+vertex_size,width-vertex_size);
    float y = random(0+vertex_size,height-vertex_size); 

    vertices[i] = new Vertex(i, x, y, String.format("Vertex %d", i), color(100));
  }

  fill(foreground_colour); 
  // make this a randomly connected graph, for every pair of n_vertices i and j
  float val = 0;
  for (int i = 0; i < n_vertices; i++) {
    for (int j=i+1; j<n_vertices; j++) {
      //create the edges with probability 0.5
      val = random(0,1);
      if(val > 0.5) { 
        edges[i][j] = 1;
      } else {
        edges[i][j] = 0; 
      }
    }
  }
} 

void mouseDragged() {
  float x = mouseX;
  float y = mouseY;

  for (Vertex v : vertices) {
    if (v.mouseOver()) {
      v.label.isVisible = false;
      v.setPosition(x, y);
      break;
    }
  }
}

void mouseClicked() {
  float x = mouseX;
  float y = mouseY;

  for (Vertex v : vertices) {
    v.label.isPersistent = v.mouseOver();
  }
}

void draw() {
  background(background);
  stroke(0);

  //draw the n_vertices
  for (Vertex v : vertices) {
    v.draw();
    v.drawText();
  }

  stroke(foreground);

  //draw the edges
  for (int i = 0; i < n_vertices; i++) {

    Vertex u = vertices[i];

    for(int j=i+1; j<n_vertices; j++) {

      Vertex v = vertices[j];

      if(edges[i][j] > 0) {
        line(u.x, u.y, v.x, v.y);
      }
    }
  }
}
