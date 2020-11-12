import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;

int sizeX = 1280;
int sizeY = 720;

long start;
long reset;
int i;
int p;
int timeNextPulse;
int pulseCounter;
boolean skip;

String query;
String time;
String userBusy;
int dayBusy;
int proficiency;

ControlP5 p5;
JSONArray teledata;
JSONObject data;
ArrayList<CallerTiming> callerTimings;
PriorityQueue<SimEvent> soundEvents;

Textlabel freeCount;

SamplePlayer call;
SamplePlayer ftj;
WavePlayer queue;
TextToSpeechMaker ttsMaker;

Gain callGain;
Gain ftjGain;
Gain ftjToggle;
Gain queueGain;
Gain queueToggle;
Gain masterGain;

Glide rateGlide;
Glide panGlide;
Glide callGlide;
Glide ftjGlide;
Glide ftjToggleGlide;
Glide queueToggleGlide;
Glide duckGlide;
Glide masterGlide;

Panner callPan;
Envelope queueEnvelope;
BiquadFilter duckFilter;


void settings() {
  size(sizeX, sizeY);
}

void setup() {
  i = 0;
  p = 0;
  timeNextPulse = 1;
  pulseCounter = 1;
  skip = false;
  query = "";
  time = "Afternoon";
  userBusy = "Free";
  dayBusy = 2;
  proficiency = 1;
  
  ac = new AudioContext();
  p5 = new ControlP5(this);
  teledata = loadJSONArray("teledata.json");
  callerTimings = new ArrayList<CallerTiming>();
  soundEvents = new PriorityQueue<SimEvent>(new Comparator<SimEvent>() {
    @Override
    public int compare(SimEvent s1, SimEvent s2) {
      return s1.getEvent().getPriority() - s2.getEvent().getPriority();
    }
  });
  
  // Create ugens and connect
  panGlide = new Glide(ac, 0, 1);
  rateGlide = new Glide(ac, 1, 1);
  queueEnvelope = new Envelope(ac, 0.0);
  
  callGlide = new Glide(ac, 0, 500);
  ftjGlide = new Glide(ac, 0, 500);
  ftjToggleGlide = new Glide(ac, 0, 500);
  queueToggleGlide = new Glide(ac, 0, 500);
  duckGlide = new Glide(ac, 0, 500);
  masterGlide = new Glide(ac, 1, 500);
  
  callGain = new Gain(ac, 1, callGlide);
  ftjGain = new Gain(ac, 1, ftjGlide);
  ftjToggle = new Gain(ac, 1, ftjToggleGlide);
  queueGain = new Gain(ac, 1, queueEnvelope);
  queueToggle = new Gain(ac, 1, queueToggleGlide);
  masterGain = new Gain(ac, 1, masterGlide);
  
  callPan = new Panner(ac, panGlide);
  duckFilter = new BiquadFilter(ac, BiquadFilter.HP, duckGlide, 0.5);
  
  call = getSamplePlayer("ring.wav");
  ftj = getSamplePlayer("chatter.wav");
  queue = new WavePlayer(ac, 440, Buffer.SINE);
  ttsMaker = new TextToSpeechMaker();
  
  call.pause(true);
  call.setRate(rateGlide);
  ftj.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  
  callPan.addInput(call);
  callGain.addInput(callPan);
  duckFilter.addInput(callGain);
  
  ftjGain.addInput(ftj);
  ftjToggle.addInput(ftjGain);
  duckFilter.addInput(ftjToggle);
  
  queueGain.addInput(queue);
  queueToggle.addInput(queueGain);
  duckFilter.addInput(queueToggle);
  
  masterGain.addInput(duckFilter);
  ac.out.addInput(masterGain);
  
  int len = (int) ((sizeX/1.2 - sizeX/4) / 3);
  int wid = (int) ((sizeY/1.2 - sizeY/4) / 3);
  
  // Controls what events get played, associated with the time of day
  p5.addDropdownList("Time")
  .setPosition(sizeX / 2, wid)
  .setSize(sizeX/8, sizeY/4)
  .setBarHeight(sizeY/8)
  .setItems(new String[]{"Morning", "Afternoon", "Night"})
  .setLabel("Time of day");
  
  // Controls speed at which events are read from JSON file
  p5.addDropdownList("DayBusyness")
  .setPosition(sizeX - 1.5 * len, wid)
  .setSize(sizeX/8, sizeY/4)
  .setBarHeight(sizeY/8)
  .setItems(new String[]{"Relaxed Day", "Normal Day", "Eventful Day"})
  .setLabel("Busyness of Day");
  
  // If busy, calls will go directly to contact queue
  p5.addDropdownList("UserBusyness")
  .setPosition(sizeX / 2, (2 * wid) + (sizeY/1.2/4))
  .setSize(sizeX/8, sizeY/4)
  .setBarHeight(sizeY/8)
  .setItems(new String[]{"Busy", "Free"})
  .setLabel("Busyness of User");
  
  // Controls how many sonifications can be heard at once
  p5.addDropdownList("Comfort")
  .setPosition(sizeX - 1.5 * len, (2 * wid) + (sizeY/1.2/4))
  .setSize(sizeX/8, sizeY/4)
  .setBarHeight(sizeY/8)
  .setItems(new String[]{"Low", "Medium", "High"})
  .setLabel("Sonification Comfort");
  
  // Where the text editor will be overlain (ControlP5 doesn't natively support editable textareas)
  p5.addTextarea("Coding Interface")
  .setPosition((sizeX - sizeX/1.2)/2 + 10, (sizeY - sizeY/1.2)/2 + 10)
  .setSize((int) (sizeX/3 - 20), (int)(sizeY/1.2 - 20))
  .setFont(createFont("arial", 12))
  .setLabel("Coding Interface")
  .setColor(color(0))
  .setColorBackground(color(192))
  .setText("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n      [Insert Notepad here and fit to grey box]");
  
  // No current functionality outside of aesthetics
  p5.addTextfield("Search")
  .setPosition(0,0)
  .setSize((int)((sizeX - sizeX/1.2)/2), (int)((sizeY - sizeY/1.2)/2))
  .setLabel("");
  
  p5.addTextlabel("SearchLabel")
  .setPosition(0,0)
  .setValue("Search:");
  
  p5.addSpacer("Free")
  .setPosition(0,(int)((sizeY - sizeY/1.2)))
  .setSize((int)((sizeX - sizeX/1.2)/2), (int)((sizeY - sizeY/1.2)/2))
  .setColor(color(0,160,100));
  
  p5.addTextlabel("FreeLabel")
  .setPosition((int)((sizeX - sizeX/1.2)/6),(int)((sizeY - sizeY/1.2)/1.2))
  .setValue("Free \r\nJoin:");
  
  p5.addSpacer("Queue")
  .setPosition((int) (sizeX - sizeX/1.2),0)
  .setSize(5, (int)((sizeY - sizeY/1.2)/2))
  .setColor(color(0,160,100));
  
  p5.addTextlabel("QueueLabel")
  .setPosition((int)((sizeX - sizeX/1.2)/1.7), (int)((sizeY - sizeY / 1.2)/5))
  .setValue("Contact Queue:");
  
  p5.addSpacer("Callers")
  .setPosition(0, sizeY - (int)((sizeY - sizeY/1.2)))
  .setSize((int)((sizeX - sizeX/1.2)/2), (int)((sizeY - sizeY/1.2)/2))
  .setColor(color(0,160,100));
  
  p5.addTextlabel("CallersLabel")
  .setPosition((int)((sizeX - sizeX/1.2)/6), sizeY - (int)((sizeY - sizeY / 1.2)/1.65))
  .setValue("Callers:");
  
  ac.start();
  
  start = System.currentTimeMillis();
  reset = System.currentTimeMillis();
}


void draw() {
  background(0);
  rect((sizeX - sizeX/1.2)/2, (sizeY - sizeY/1.2)/2, sizeX/1.2, sizeY/1.2);
  
  // Callers stay on the caller tab for a limited period of time
  if (callerTimings.size() > 0 && (System.currentTimeMillis() - start) / 1000F - callerTimings.get(0).getTime() > 5) {
    Coworker toQueue = callerTimings.remove(0).getCoworker();
    SimEvent removeCaller = new SimEvent(EventType.CALLREMOVE, toQueue.getName(), p5);
    SimEvent goToQueue = new SimEvent(EventType.QUEUEADD, toQueue.getName(), p5);
    execute(removeCaller);
    execute(goToQueue);
    sonify(removeCaller);
    soundEvents.add(goToQueue);
  }
  
  if (i < teledata.size()) {
    data = teledata.getJSONObject(i); 
  } else {
    printScoreCard();
    delay(500);
    exit();
  }
  
  if (data != null && (EventType.valueOf(data.getString("EVENT").toUpperCase()) != EventType.CALLGET && (time.equals("Morning") || time.equals("Evening")))) {
    skip = true;
    i++;
  }
  
  // Execute events immediately, delay sonification based on priority to prevent too much sound overlap
  if (!skip && data != null && (System.currentTimeMillis() - start) / 1000F > data.getInt("BASELINETIME") * dayBusy) {
    SimEvent toExecute = new SimEvent(EventType.valueOf(data.getString("EVENT").toUpperCase()), data.getString("COWORKER").toLowerCase(), p5);
    float[] position = toExecute.getPosition();
    println("Name: " + toExecute.getCoworker().getName());
    println("Priority: " + toExecute.getEvent().getPriority());
    print("Sound Position: " + position[0] + ", " + position[1]);
    println("\r\n");
    if ((userBusy.equals("Busy") || eventBusy) && toExecute.getEvent() == EventType.CALLGET) {
      toExecute.setEvent(EventType.QUEUEADD);
    }
    if (toExecute.getEvent() == EventType.CALLGET) {
      callerTimings.add(new CallerTiming(toExecute.getCoworker(), (System.currentTimeMillis() - start) / 1000F));
    }
    execute(toExecute);
    soundEvents.add(toExecute);
    i++;
  }
  
  if (skip) {
    skip = false;
  }
  
  // Increase pulsing based on amount of callers in queue
  if (timeNextPulse > 0 && pulseCounter < 100 / dayBusy) {
    queueEnvelope.addSegment(0.1, 100);
    queueEnvelope.addSegment(0.0, 300/timeNextPulse);
    pulseCounter++;
  }
  
  // The amount of dequeues at a given time is based on sonification comfort level
  if (soundEvents.size() > 0 && p > 0) {
    sonify(soundEvents.poll());
    p--;
  }
  
  // Reset all sounds at certain increments of time, to prevent them from playing too long
  if ((System.currentTimeMillis() - reset) / 1000F > 2 * dayBusy) {
    p = proficiency;
    callGlide.setValue(0);
    ftjToggleGlide.setValue(0);
    queueToggleGlide.setValue(0);
    queueEnvelope.setValue(0);
    pulseCounter = 0;
    reset = System.currentTimeMillis();
  }
}


void Time(int n) {
  time = p5.get(DropdownList.class, "Time").getItem(n).get("text").toString();
  println("Time of day: " + time);
}

void DayBusyness(int n) {
  dayBusy = 4 - (parseInt(p5.get(DropdownList.class, "DayBusyness").getItem(n).get("value").toString()) + 1);
  println("Busyness of day: " + p5.get(DropdownList.class, "DayBusyness").getItem(n).get("text").toString());
}

void UserBusyness(int n) {
  userBusy = p5.get(DropdownList.class, "UserBusyness").getItem(n).get("text").toString();
  println("Busyness of User: " + userBusy);
}

void Comfort(int n) {
  proficiency = parseInt(p5.get(DropdownList.class, "Comfort").getItem(n).get("value").toString()) + 1;
  println("Sonification Comfort of User: " + p5.get(DropdownList.class, "Comfort").getItem(n).get("text"));
}

void Search(String theText) {
  query = theText;
  println("User searched for: " + query); 
}
