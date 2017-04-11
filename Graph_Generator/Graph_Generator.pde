class Bar {

  String trend;
  int trendVol;
  PVector pos;
  float barWidth = 60;
  float barHeight;
  color col;

  public Bar(String t, int tV, float x, float y, float h, color c) {
    trend = t;
    trendVol = tV;
    pos = new PVector(x,y);
    barHeight = h;
    col = c;
  }

  // Draw the bar, it's trend, and its trend volume
  public void display() {
    rectMode(CORNER);
    strokeWeight(5);
    fill(col);
    rect(pos.x, pos.y, barWidth, barHeight);
    fill(0);
    rectMode(CENTER);
    textAlign(CENTER,CENTER);
    text(trend, (pos.x+barWidth/2)+3, pos.y+barHeight/2, 50, barHeight);
    text(trendVol, (pos.x+barWidth/2)+3, pos.y-9);
  }
}

class Graph {

  Bar[] bars;
  String[] trends;
  int[] trendVols;
  float topVol;
  int maxHeight;

  public Graph(int size) {
    trends = loadStrings("../trend-data/processing-data.txt");
    bars = new Bar[size];
    trendVols = new int[trends.length];
    initializeTrends();

    topVol = findTopVol();
    maxHeight = (int)random(200,250);

    for(int i = 0; i < bars.length; i++) {
      String t = trends[i];
      int tV = trendVols[i];
      float x;
      if(i == 0) {x = 30;}
      else {x = bars[i-1].pos.x+80;}
      float h = compareHeight(trendVols[i]);
      float y = (height-11)-h;
      color c = color(random(50, 255), random(50,255), random(50,255));
      bars[i] = new Bar(t, tV, x, y, h, c);
    }
  }

  public void initializeTrends() {
    for(int i = 0; i < trends.length; i++) {
      String t = "";
      for(int j = 0; j < trends[i].length(); j++) {
        if(trends[i].charAt(j) != ':') {
          t += trends[i].charAt(j);
        }else {
          trendVols[i] = Integer.parseInt(trends[i].substring(j+1, trends[i].length()));
          trends[i] = t;
          break;
        }
      }
    }
  }

  public int findTopVol() {
    int greatest = trendVols[0];
    for(int i = 1; i < trendVols.length; i++) {
      greatest = max(greatest, trendVols[i]);
    }
    return greatest;
  }

  public float compareHeight(int tV) {
    float mult = topVol/tV;
    return maxHeight/mult;
  }

  public void display() {
    strokeWeight(3);
    beginShape();
    vertex(10, 10);
    vertex(10, height-10);
    vertex(width/1.5, height-10);
    endShape();

    // Draw side list of trends
    fill(0);
    textFont(font1);
    text("Top Trends:", (width/1.5)+10, (height/2)+40);
    textFont(font2);
    for(int i = 0; i < bars.length; i++) {
      bars[i].display();
      textAlign(LEFT,CENTER);
      text(i+1+".", (width/1.5)+10, ((height/2)+(i*15)+48));
      rectMode(CENTER);
      strokeWeight(0);
      fill(bars[i].col);
      rect((width/1.5)+30, ((height/2)+(i*15)+50), 10, 10);
      fill(0);
      text(bars[i].trend, (width/1.5)+40, (height/2)+(i*15)+48);
    }

    // Draw list of honorable mentions
    textFont(font1);
    text("Honorable Mentions:", (width/1.5)+10, height-50);
    textFont(font2);
    for(int i = bars.length; i < bars.length+2; i++) {
      text(trends[i], (width/1.5)+10, height-(i*15)+55);
    }
  }
}

PFont font1;
PFont font2;

Graph graph;

void setup() {
  size(640, 360);
  background(255);

  font1 = createFont("Arial Bold",12);
  font2 = createFont("Arial", 12);
  
  graph = new Graph(5);
  graph.display();

  save("output.png");
  exit();
}