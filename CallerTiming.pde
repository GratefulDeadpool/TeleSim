// Class used for removing callers based on time in caller tab

public class CallerTiming {
  private Coworker coworker;
  private float time;
  
  public CallerTiming (Coworker coworker, float time) {
    this.coworker = coworker;
    this.time = time;
  }
  
  public Coworker getCoworker() {
    return coworker;
  }
  
  public float getTime() {
    return time;
  }
}
