import processing.serial.*;

Serial myPort;  // Create object from Serial class

int lf = 10;      // ASCII linefeed 
int borderWidth = 2;

int initTime;
int timeLength = 200;

int maxScore = 10000;
ArrayList<Player> players = new ArrayList();


void setup()
{
  initTime = millis();
  
  players.add(new Player(maxScore, false));
  players.add(new Player(maxScore, true));
  players.add(new Player(maxScore, false));
  players.add(new Player(maxScore, true));

  size(1050, 750);

  // Open whatever port is the one you're using.
  String portName = Serial.list()[3]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil(lf); 
}

void draw()
{
  int timePassed = millis() - initTime;
  if (timePassed > timeLength) {
    adjustScores();
    initTime = millis();
  }
    
  int x = 50;
    
  clear();
  background(255);
  noStroke();

  for (Player player: players) {
    drawBar(x, 50, player);
    
    x+=250;
  }
  
  //println(Serial.list()); //print it out in the console
}

void adjustScores() {
  for (Player player: players) {
    player.updateScore();
  }
}

void drawBar(int x, int y, Player player) 
{
  int cornerRadius = 6;
  int barHeight = 600;
  int barWidth = 200;
  
  PFont f = createFont("Arial", 16, true);
  color text = color(0, 0, 0);
  color outside = color(153, 51, 0);
  color inside = color(255, 255, 255);
 
  fill(text);
  textFont(f);
  text("Score: " + player.score, x, y); 
  text("Resets: " + player.resetCount, x, y+20);
  
  float barPercent = (1.0 - player.score/float(maxScore));
  println("barPercent: " + barPercent);
  if( barPercent < .5) {
   outside = color(50,205,50);
   
  } else if( barPercent > .5 && barPercent < .8) {
    outside = color(204,204,0);
    
  } else {
    outside = color(153, 51, 0);
  }
  
  fill(outside);
  int yRec = y + 40;
  rect(x, yRec, barWidth, barHeight + (2*borderWidth) , cornerRadius);

  int inHeight = floor( barPercent * barHeight);
  //println("value: " + value + " inHeight: " + inHeight);
  
  fill(inside);
  rect(x + borderWidth, yRec + borderWidth, barWidth - (2*borderWidth), inHeight, cornerRadius);
}

void serialEvent(Serial p) { 
  //println("serialEvent fired");

  try {
    String data = p.readString();
    if(data != null) {
      //println(data);
      JSONObject json = parseJSONObject(data);  
    
      if (json != null) {
        JSONArray buttons = json.getJSONArray("buttons");
  
        for (int i = 0; i < buttons.size(); i++) {
          JSONObject button = buttons.getJSONObject(i); 
  
          //int id = button.getInt("id");
          boolean state = button.getBoolean("state");
          //println("button: " +  id + " state: " + state);
          Player player = players.get(i);
          player.buttonPressed = state;
        }
      }
    }
  } catch(Exception e) {
    print(e);
  }
} 

void keyReleased() {
  println("keyReleased event fired");
  if(key == 'R' || key == 'r') {
    println("resetting score");
    for (Player player: players) {
      player.clear();
    }
  }
  
  if(key >= '1' && key <= '9') {
    int value = Integer.parseInt(str(key)) - 1;
    println("resetting player " + value + " score");
    
    if( value < players.size() ) {
      players.get(value).resetScore();
    }    
  }
}

class Player {
  public boolean buttonPressed;
  public boolean autoReset;
  public int resetScore = 0;
  public int score;
  public int initScore;
  public int resetCount = 0;
 
  public Player(int score, boolean autoReset) {
    this.buttonPressed = false;
    this.autoReset = autoReset;
    this.initScore = score;
    this.score = score;
    this.resetScore = floor(score * .3);
  }
  
  public void updateScore() {
    if( buttonPressed && score > 0) {
      score -= 65;
    
      if( autoReset == true && score < resetScore) {
        resetScore();
        
      } else if(score < 0 ) {
        score = 0;
      }
    }
  }
  
  public void resetScore() {
    this.score = this.initScore;
    resetCount++;
  }
  
  public void clear() {
    this.score = this.initScore;
    resetCount = 0;
  }
}