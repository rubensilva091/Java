class Mob {
    private float posX;
    private float posY;
    private float radius;
    private int id;
    private float speedX; 
    private float speedY;
    private float r=100;
    private float g=100;
    private float b=100;

    public Mob(int id,float x, float y,float r,float speedX, float speedY) {
        this.id = id;
        this.radius = r;
        this.posX = x;
        this.posY = y;
        this.speedX = speedX;
        this.speedY = speedY;
    }
  public synchronized int getId()
  {
    return this.id;
  }
   public synchronized  void update(float x, float y) {
        this.posY = y;
        this.posX = x;
    }

    public synchronized  void render() {
        pushMatrix();
        translate(posX, posY);
        stroke(0); //preto
        strokeWeight(2);
        fill(this.r, this.g, this.b);
        ellipse(0, 0, radius*2, radius*2);
        popMatrix();
    }
    
  public void renderSun()
  {
        pushMatrix();
        translate(width/2, height/2);
        stroke(0); //preto
        strokeWeight(2);
        fill(255, 174, 66);
        ellipse(0, 0, 150, 150);
        popMatrix();
  }
}
