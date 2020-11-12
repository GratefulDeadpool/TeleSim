import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

private static ArrayList<CallerCoworker> filledCaller = new ArrayList<CallerCoworker>();

public class CallerCoworker extends Coworker {
  
  public CallerCoworker(String name, ControlP5 p5) {
    super(name, p5);
  }
  
  @Override
  public void addToScreen() {
    float x = 51.0 + ((width - 102.0) / 25.0) * (name.charAt(0) - 97.0);
     b = p5.addButton(name + "Caller")
      .setPosition(x, height - 60)
      .setSize(51, 51)
      .setImage(icon);
     p5.addTextlabel(name + "CallerLabel")
      .setPosition(x + 7, height - 9)
      .setValue(name);
     b.onClick(new CallbackListener() { 
      public void controlEvent(CallbackEvent theEvent) {
        SimEvent toExecute = new SimEvent(EventType.CALLIN, name, p5);
        execute(toExecute);
        sonify(toExecute);
        for (int i = 0; i < callerTimings.size(); i++) {
          if (callerTimings.get(i).getCoworker().getName().equals(name)) {
            callerTimings.remove(i);
            break;
          }
        }
        Button video = p5.addButton("video")
          .setPosition(width/2 - 271/2, height/2 - 120/2)
          .setSize(271, 120)
          .setImage(loadImage("video.jpg"));
        video.onClick(new CallbackListener() { 
          public void controlEvent(CallbackEvent theEvent) {
            SimEvent toExecute = new SimEvent(EventType.VIDEOOUT, name, p5);
            execute(toExecute);
            sonify(toExecute);
            p5.remove("video");
          }
        });
      }
    });
    filledCaller.add(this);
  }
  
  @Override
  public void removeFromScreen() {
    if (filledCaller.contains(this)) {
      p5.remove(name + "Caller");
      p5.remove(name + "CallerLabel");
      filledCaller.remove(this);
    } else {
      println(name + "not found");
    }
  }
  
  @Override
  public String getType() {
    return "Caller";
  }
}
