import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;


public abstract class Coworker {
  
  protected String name;
  protected PImage icon;
  protected ControlP5 p5;
  protected Button b;

  public Coworker(String name, ControlP5 p5) {
    this.name = name;
    this.icon = loadImage(name + ".jpg");
    this.p5 = p5;
  }
  
  // Add coworker to screen
  public abstract void addToScreen();
  
  //remove coworker from screen
  public abstract void removeFromScreen();
  
  // get type of coworker
  public abstract String getType();
  
  // get name of coworker
  public String getName() {
    return name;
  }
  
  @Override
  public boolean equals(Object o) { 
      if (o == this) { 
          return true; 
      } 
      if (!(o instanceof Coworker)) { 
          return false; 
      } 
      Coworker c = (Coworker) o;
      return name.equals(c.name) && getType().equals(c.getType()); 
  } 
}
