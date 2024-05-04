import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.*;

int page_selected = 2;
int ConnctionId=0; 

Login login = new Login();
ClientConnection connection;
List<Player> playerList = new ArrayList<>();
List<Mob> mobList = new ArrayList<>();
Sun sun = new Sun();


void setup() {
    connection = new ClientConnection("localhost", 12345);
    page_selected = connection.connect();
    
    new Thread( () -> {
        try{              
              String message = "";
              System.out.println("Conection Start!");
                try{
                      while((message = connection.in.readLine()) !=null)
                                {
                                  //System.out.println("Server Msn: "+message);
                                  List<String> listWords = splitWords(message);
                                  parser(listWords);
                                }
    }
    catch (IOException e) {
      message = "An error has occured";
    }
    System.out.println("Conection End!");
                 }
                 catch(Exception e){
                   e.printStackTrace();}
               }).start();
    
    size(1280,720);
}

void draw() {
  background(255); // Limpa cada frame
 
  //Window Selector
  switch (page_selected) {
            case 0:
                  PImage img = loadImage("\\images\\noConnection.png");
                  image(img, 300, 80); 
              break;
            case 1:
                  int bool;
                  bool = login.display();
                  login.input(key);  
                  
                  if (bool !=0 && !login.inputTextUsername.isEmpty() && !login.inputTextPassword.isEmpty())
                  {
                    //Button Handler
                    switch (bool){
                    case 1:
                        connection.sendString("CreateAcc "+login.inputTextUsername+" "+login.inputTextPassword);
                        break;
                    case 2:
                        connection.sendString("LoginAcc "+login.inputTextUsername+" "+login.inputTextPassword);
                        break;
                    case 3:
                        connection.sendString("DeleteAcc "+login.inputTextUsername+" "+login.inputTextPassword);  
                      break;
                    default:
                      System.err.println("Botão não existe");
                      break;
                    }
                    login.fieldClear();
                  }
                break;
            case 2:
              sun.render();
              synchronized (playerList) {
              for (Player player : playerList) {
                    
                    player.render();
                    if (player.getId() == ConnctionId && player.getFuel() >0)
                  {
                    player.renderFuelBar();
                  }}
              }
              synchronized (mobList) {      
              for (Mob mob: mobList)
              {
                mob.render();
              }}
              
              if(keyPressed)
              {
              //Send keys to the server
              if (keyCode == UP)
              {
                connection.sendString("key up "+ConnctionId);
                key = '.'; //Reset the key
              }
              else if(keyCode == LEFT)
              {
               connection.sendString("key left "+ConnctionId);
               key = '.'; //Reset the key
              }
              else if(keyCode == RIGHT)
              {
                connection.sendString("key right "+ConnctionId);
                key = '.'; //Reset the key
              }
              }
              break;
            case 3:
                  PImage img2 = loadImage("\\images\\rip.png");
                  image(img2, 500, 100); 
            default:
                //System.out.println("Opção inválida");
                break;
  }
  
  
  key = '.'; //Reset the key
}

void parser(List<String> str)
{
  switch(str.get(0))
  {
    case "game":
    page_selected=2;
       break;
    case "player":
    synchronized (playerList) {
    //Convert all data for the constructer build it
     int id = Integer.parseInt(str.get(1));
     float x = Float.parseFloat(str.get(2));
     float y = Float.parseFloat(str.get(3));
     float siz = Float.parseFloat(str.get(4));
     float spedX = Float.parseFloat(str.get(5));
     float spedY = Float.parseFloat(str.get(6));
     float anglee = Float.parseFloat(str.get(7));
     float r = Float.parseFloat(str.get(8));
     float g = Float.parseFloat(str.get(9));
     float b  = Float.parseFloat(str.get(10));
     float fuel = Float.parseFloat(str.get(11));
     float rot = Float.parseFloat(str.get(12));
     
    boolean idExists = false;
    for (Player player : playerList) {
    if (player.getId() == id) {
        idExists = true;
        player.update(x,y,anglee, fuel,rot);
        break;
        }
     }
     if (idExists == false)
     {
        Player newPlayer  = new Player(id,x,y,siz,spedX, spedY,anglee,r,g,b, fuel,rot);
        playerList.add(newPlayer);
     }
    }
     break;
     case "mob":
       synchronized (mobList) {    
    //Convert all data for the constructer build it
       int idd = Integer.parseInt(str.get(1));
       float posx = Float.parseFloat(str.get(2));
       float posy = Float.parseFloat(str.get(3));
       float size = Float.parseFloat(str.get(4));
       float speedX = Float.parseFloat(str.get(5));
       float speedY = Float.parseFloat(str.get(6));
     
       boolean idExists = false;
    for (Mob mob : mobList) {
    if (mob.getId() == idd) {
        idExists = true;
        mob.update(posx,posy);
        break;
        }
     }
     if (idExists == false)
     {
        Mob newMob  = new Mob(idd,posx,posy,size,speedX,speedY);
         mobList.add(newMob);
     }
    }
       break;
     case "id":
       ConnctionId = Integer.parseInt(str.get(1));
       break;
     case "dead":
       int deadId = Integer.parseInt(str.get(1));
       if (deadId == ConnctionId)
       {
         page_selected=3;
       }
       for (Player player : playerList) {
        if (player.getId() == deadId) {
            playerList.remove(player);
            break;
        }
     }
     default:  
       break;
  }
}

public List<String> splitWords(String texto) {
        // Divida a string em palavras usando os espaços como delimitadores
        String[] words = texto.split(" ");

        // Crie uma lista para armazenar as palavras
        List<String> listWords = new ArrayList<>();

        // Adicione cada palavra à lista
        for (String word : words) {
            listWords.add(word);
        }
        return listWords;
    }
