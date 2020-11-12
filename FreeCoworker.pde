import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

private static ArrayList<FreeCoworker> filledFree = new ArrayList<FreeCoworker>();

public class FreeCoworker extends Coworker {
  
  Textlabel l;
  
  public FreeCoworker(String name, ControlP5 p5) {
    super(name, p5);
  }
  
  @Override
  public void addToScreen() {
    b = addHelper(this, filledFree.size()); 
    l = p5.addTextlabel(name + "FreeLabel")
      .setPosition(width/50 + 5, 226 + filledFree.size() * (height/7))
      .setValue(name);
    filledFree.add(this);
  }
  
  @Override
  public void removeFromScreen() {
    if (filledFree.contains(this)) {
      int index = filledFree.indexOf(this);
      int i = index + 1;
      String firstName = filledFree.get(index).name;
      p5.remove(firstName + "Free");
      p5.remove(firstName + "FreeLabel");
      for ( ; i < filledFree.size(); i++) {
        FreeCoworker coworker = filledFree.get(i);
        String toChange = coworker.l.getStringValue();
        p5.remove(coworker.name + "Free");
        p5.remove(coworker.name + "FreeLabel");
        filledFree.get(i-1).b = addHelper(coworker, i-1);
        filledFree.get(i-1).l = p5.addTextlabel(coworker.name + "FreeLabel")
          .setPosition(width/50 + 5, 226 + (i-1) * (height/7))
          .setValue(toChange);
      }
      filledFree.remove(index);
    } else {
      println(name + "not found");
    }
  }
  
  @Override
  public String getType() {
    return "Free";
  }
  
  public void updateLabel(String text) {
    FreeCoworker toUpdate = filledFree.get(filledFree.indexOf(this));
    toUpdate.l.setText(text);
  }
  
  private Button addHelper(Coworker coworker, int position) {
    Button button = p5.addButton(coworker.name + "Free")
      .setPosition(width/50, 175 + position * (height/7))
      .setSize(51, 51)
      .setImage(coworker.icon);
     button.onClick(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        SimEvent toExecute = new SimEvent(EventType.FTJIN, name, p5);
        execute(toExecute);
        sonify(toExecute);
        Button video = p5.addButton("video")
          .setPosition(width/2 - 271/2, height/2 - 120/2)
          .setSize(271, 120)
          .setImage(loadImage("video.jpg"));
        video.onClick(new CallbackListener() { 
          public void controlEvent(CallbackEvent theEvent) {
            SimEvent toExecute  = new SimEvent(EventType.VIDEOOUT, name, p5);
            execute(toExecute);
            sonify(toExecute);
            p5.remove("video");
          }
        });
      }
    });
    return button;
  }
}
