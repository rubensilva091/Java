class Player {
    private float posX;
    private float posY;
    private float radius;
    private float angle;
    private float size;
    private float speedX;
    private float speedY;
    private float r;
    private float g;
    private float b;
    private int id;
    private float fuel;
    private float rotation;

    public Player(int id, float x, float y,float size, float speedX,float speedY, float angle,float r, float g, float b, float fuel, float rot) {
        this.id = id;
        this.radius = 25;
        this.posX = x;
        this.posY = y;
        this.angle = (float) (angle * Math.PI / 180.0);
        this.r = r;
        this.g=g;
        this.b=b;
        this.speedX = speedX;
        this.speedY = speedY;
        this.size = size;
        this.fuel = fuel;
        this.rotation = rot;
    }

   public synchronized  int getId()
   {
     return this.id;
   }
   
   public synchronized  void update(float x, float y, float angle, float fuel, float rot) {
        this.posY = y;
        this.posX = x;
        this.angle = (float) (angle * Math.PI / 180.0);
        this.fuel = fuel;
        this.rotation = rot;
    }

    public synchronized  void render() {
        pushMatrix();
        translate(posX, posY);
        rotate(angle);
        stroke(0); //preto
        strokeWeight(2);
        fill(this.r, this.g, this.b);
        ellipse(0, 0, radius*2, radius*2);
        line(0, 0, radius, 0);
        popMatrix();
    }
    
    public synchronized float getFuel ()
    {
      return this.fuel;
    }
    public synchronized void renderFuelBar() {
    float fuelBarWidth = 150;
    float fuelBarHeight = 15;
    float fuelBarX = width - fuelBarWidth - 10; 
    float fuelBarY = fuelBarHeight + 10;

    pushMatrix();
    translate(fuelBarX, fuelBarY);
    stroke(0); //preto
    strokeWeight(2);
    fill(255);
    float fuelBarFillWidth = fuelBarWidth * (fuel / 100);

    fill(this.r, this.g, this.b, 30);
    rect(0, 0, fuelBarFillWidth, fuelBarHeight);

    popMatrix();
}

}
