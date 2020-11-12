import java.util.*;

// Each event is associated with a priority
public enum EventType {
    CALLGET(1), CALLIN(2), CALLREMOVE(3), QUEUEADD(4), QUEUEREMOVE(5), FTJACTIVE(6), FTJINACTIVE(7), FTJIN(8), FTJJOIN(9), FTJLEAVE(10), VIDEOOUT(11);
    private final int priority;
    private EventType(int priority) {
      this.priority = priority;
    }
    public int getPriority() {
        return priority;
    }
}

public class SimEvent {
  
  private EventType event;
  private String coworker;
  private ControlP5 p5;
  
  public SimEvent(EventType event, String coworker, ControlP5 p5) {
    this.event = event;
    this.coworker = coworker;
    this.p5 = p5;
  }
  
  // Get event type of an event
  public EventType getEvent() {
    return event;
  }
  
  // Change the event type of an event
  public void setEvent(EventType event) {
    this.event = event;
  }
  
  // get coworker of a type associated with the event
  public Coworker getCoworker() {
    if (coworker == null) {
      return null;
    }
    if (event == EventType.FTJACTIVE || event == EventType.FTJINACTIVE || event == EventType.FTJJOIN || event == EventType.FTJLEAVE || event == EventType.FTJIN) {
      return new FreeCoworker(coworker, p5);
    } else if (event == EventType.CALLGET || event == EventType.CALLIN || event == EventType.CALLREMOVE) {
      return new CallerCoworker(coworker, p5);
    } else if (event == EventType.QUEUEADD || event == EventType.QUEUEREMOVE) {
      return new ContactCoworker(coworker, p5);
    }
    return null;
  }
  
  // get audio "position" for coworker
  public float[] getPosition() {
    if (coworker == null) {
      return new float[]{1, 1};
    }
    float nameX = coworker.charAt(0);
    float nameY = coworker.charAt(coworker.length() - 1);
    float x = -1.0 + (2.0 / 25.0) * (nameX - 97.0);   // x: [-1, 1] = panning
    float y = 0.75 + (0.5 / 25.0) * (nameY - 97.0);   // y: [0.75, 1.25] = playback rate
    return new float[]{x, y};
  }
}
