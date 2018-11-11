/*


Úkol 3  (5 bodů)

Implementujte v Processingu systém pro interaktivní zobrazování velkých grafů se zvětšeným náhledem na okolí uzlů ve středu obrazovky.

Požadavky:

1) Po spuštění programu se vygenuruje náhodný obecný graf s náhodným rozmístěním uzlů

1) Uzly lze přemísťovat myší

2) Po kliknutí na uzel se zobrazí (dočasně nebo do dalšího kliknutí) jeho identifikace

3) Uzly trvale optimalizují svoji polohu na základě Vámi zvoleného algoritmu, s preferenčním umístěním uzlů s větší vahou ve středu grafu

4) Uzly mají náhodně přidělené váhy, které ovlivňují jejich vzhled a vliv na okolité uzly

5) Zobrazení zahušťuje a zmenšuje uzly daleko od středu obrazovky (např. adjust_positionací r = R - k/(sqrt(x^2+y^2) + 1; alpha = arcsin(x/r)), kde x a y jsou karteziánské souřadnice, r a alpha jsou polární souřadnice po adjust_positionaci, které je nutné převést na adjust_positionované karteziánské xnew = sin(alpha)*r; ynew = cos(alpha)*r)
6) Automaticke rozlozeni grafu musi dovolovat pohyb do stran a nahoru dolu
Termín: 14.11.2018

*/

int sign(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 


class VertexLabel {

  float x, y;
  String text;

  public boolean isVisible = false;
  public boolean isPersistent = false;

  VertexLabel(String text) {
    this.text = text;

    this.x = -1;
    this.y = -1;
  }

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

  int id;

  float x, y;

  public String name;

  public float radius;
  public float weight = 1;

  public color colour;

  public VertexLabel label;

  Vertex(int id, float x, float y, String name, color col, float radius) {
    this.id = id;
    this.radius = radius;

    this.name = name;

    this.colour = col;
    this.label = new VertexLabel(this.name);

    this.setPosition(x, y);
  }

  public void setPosition(float x, float y) {

    if (x + this.radius > WINDOW_WIDTH) {
      x = WINDOW_WIDTH - this.radius;
    } else if (x - this.radius < 0) {
      x = this.radius;
    }

    if (y + this.radius > WINDOW_HEIGHT) {
      y = WINDOW_HEIGHT - this.radius;
    } else if (y - this.radius < 0) {
      y = this.radius;
    }

    this.x = x;
    this.y = y;

    this.setLabelPosition();
  }

  public void setLabelPosition() {

    float x, y;

    float xfact = this.x < this.radius ? -1.0 : 2;
    float yfact = this.y < this.radius ? -1.4 : 1.1;

    x = this.x - this.radius * xfact;
    y = this.y - this.radius * yfact;

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

    ellipse(this.x, this.y, 2 * this.radius, 2 * this.radius);
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


public void adjust_position(Vertex[] vertices, float rate) {

  float k, eps;
  eps = 0.001;

  for (int i = 0; i < N_VERTICES; i++) {

    Vertex u = vertices[i];

    for (int j = 0; j < N_VERTICES; j++) {

      if (i == j) { continue; }

      Vertex v = vertices[j];

      k = 2 * DEFAULT_VERTEX_SIZE / exp(1) * log(exp(u.radius) + exp(v.radius));

      println(k, u.radius + v.radius);

      float disX = u.x - v.x;
      float disY = u.y - v.y;
      float overlap = sqrt(sq(disX) + sq(disY)) - k;
      
      if ((overlap < 1) && (abs(overlap) > eps)) {

        float uX, uY, vX, vY;

        uX = u.x - rate * (overlap) * sign(disX) / sq(u.radius);
        uY = u.y - rate * (overlap) * sign(disY) / sq(u.radius);

        vX = v.x + rate * (overlap) * sign(disX) / sq(v.radius);
        vY = v.y + rate * (overlap) * sign(disY) / sq(v.radius);

        u.setPosition(uX, uY);
        v.setPosition(vX, vY);
      } 
    }
  }
}

int WINDOW_WIDTH = 1080;
int WINDOW_HEIGHT = 720;

// init values for selected variables
int N_VERTICES = 10; //number of graph N_VERTICES
int N_CLUSTERS = 4; 
int DEFAULT_VERTEX_SIZE = 10; //size of node symbol

int BACKGROUND_COLOR = 226; //BACKGROUND_COLOR color
int FOREGROUND_LINE_COLOR = 255; //FOREGROUND_LINE_COLOR - line color
color FOREGROUND_FILL_COLOR = color(100); // FOREGROUND_LINE_COLOR - fill color 

//initialize N_VERTICES
Vertex[] vertices = new Vertex[N_VERTICES];

//matrix with values of 1 for N_VERTICES connected by edges
int[][] edges = new int[N_VERTICES][N_VERTICES];

void setup() {
  size(1080, 720);
  smooth(); 

  float minWeight = 0.5;
  float maxWeight = 3.0;

  // the BOSS
  int root = (int) random(1, N_VERTICES);

  vertices[0] = new Vertex(0, WINDOW_HEIGHT / 2, WINDOW_HEIGHT / 2, "ROOT", color(200), 1.5 * maxWeight * DEFAULT_VERTEX_SIZE);
  vertices[0].weight = 1.5 * maxWeight;
  vertices[0].label.isPersistent = true;

  // randomly initialize rest of the vertices
  for (int i = 1; i < N_VERTICES; i++) {

    float x = random(0+DEFAULT_VERTEX_SIZE,width-DEFAULT_VERTEX_SIZE);
    float y = random(0+DEFAULT_VERTEX_SIZE,height-DEFAULT_VERTEX_SIZE); 

    float weight = random(minWeight, maxWeight);
    float radius = weight * DEFAULT_VERTEX_SIZE;

    vertices[i] = new Vertex(i, x, y, String.format("Vertex %d", i), color(100), radius);
    vertices[i].weight = weight;
  }

  fill(FOREGROUND_FILL_COLOR); 
  // make this a randomly connected graph, for every pair of N_VERTICES i and j
  float val = 0;
  for (int i = 0; i < N_VERTICES; i++) {
    for (int j=i+1; j< N_VERTICES; j++) {
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
    v.label.isPersistent = v.name == "ROOT" ? true : v.mouseOver();
  }
}

void draw() {
  background(BACKGROUND_COLOR);
  stroke(0);

  //draw the N_VERTICES
  for (Vertex v : vertices) {
    v.draw();
    v.drawText();
  }

  stroke(FOREGROUND_LINE_COLOR);

  //draw the edges
  for (int i = 0; i < N_VERTICES; i++) {

    Vertex u = vertices[i];

    for(int j=i+1; j<N_VERTICES; j++) {

      Vertex v = vertices[j];

      if(edges[i][j] > 0) {
        line(u.x, u.y, v.x, v.y);
      }
    }
  }

  // adjust_position
  adjust_position(vertices, 5);
}
