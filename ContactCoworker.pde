import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

private static ArrayList<ContactCoworker> filledContact = new ArrayList<ContactCoworker>();

public class ContactCoworker extends Coworker {
  
  public ContactCoworker(String name, ControlP5 p5) {
    super(name, p5);
  }
  
  @Override
  public void addToScreen() {
    b = addHelper(this, filledContact.size()); 
    filledContact.add(this);
  }
  
  @Override
  public void removeFromScreen() {
    if (filledContact.contains(this)) {
      int index = filledContact.indexOf(this);
      int i = index + 1;
      String firstName = filledContact.get(index).name;
      p5.remove(firstName + "Contact");
      p5.remove(firstName + "ContactLabel");
      for ( ; i < filledContact.size(); i++) {
        String nameI = filledContact.get(i).name;
        p5.remove(nameI + "Contact");
        p5.remove(nameI + "ContactLabel");
        filledContact.get(i-1).b = addHelper(filledContact.get(i), i-1);
      }
      filledContact.remove(index);
    } else {
      println(name + "not found");
    }
  }
  
  @Override
  public String getType() {
    return "Contact";
  }
  
  private Button addHelper(Coworker worker, int position) {
    final Coworker coworker = worker;
    Button button = p5.addButton(coworker.name + "Contact")
      .setPosition(220 + position * (width/15), 0)
      .setSize(51, 51)
      .setImage(coworker.icon);
    p5.addTextlabel(coworker.name + "ContactLabel")
      .setPosition(227 + position * (width/15), 51)
      .setValue(coworker.name);
     button.onClick(new CallbackListener() { 
      public void controlEvent(CallbackEvent theEvent) {
        SimEvent toExecute = new SimEvent(EventType.QUEUEREMOVE, coworker.name, p5);
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
