public boolean eventBusy;
private int queueCount = 0;
private int ftjCount = 0;
private int[] scoreCard = new int[]{0, 0, 0};
private HashMap<String, Integer> ftjMap = new HashMap<String, Integer>();

public void execute(SimEvent event) {
  
  Coworker coworker = event.getCoworker();
  EventType eventType = event.getEvent();
  
  // Add or remove coworkers based on event type.
  if (eventType == EventType.FTJACTIVE || eventType == EventType.CALLGET || eventType == EventType.QUEUEADD) {
    coworker.addToScreen();
  } else if (eventType == EventType.FTJINACTIVE || eventType == EventType.CALLIN || eventType == EventType.QUEUEREMOVE || eventType == EventType.CALLREMOVE) {
    coworker.removeFromScreen();
  }
  
  // If user in non-free-to-join call, user is busy
  if (eventType == EventType.CALLIN || eventType == EventType.QUEUEREMOVE || eventType == EventType.FTJIN) {
    eventBusy = true;
  } else if (eventType == EventType.VIDEOOUT) {
    eventBusy = false;
  }
  
  // Scorecard logic and background manipulation of sound variables
  if (eventType == EventType.CALLREMOVE) {
    if (coworker.getName().equals("grace") || coworker.getName().equals("ian") || coworker.getName().equals("orville")) {
      scoreCard[0]++;
    }
  } else if (eventType == EventType.QUEUEADD) {
    queueEnvelope.setValue(0);
    queueCount++;
    timeNextPulse = Math.max(0, queueCount);
    if (queueCount > 5) {
      scoreCard[1]++;
    }
  } else if (eventType == EventType.QUEUEREMOVE) {
    queueCount--;
    timeNextPulse = 0;
    queueToggleGlide.setValue(0);
    queueEnvelope.setValue(0);
  } else if (eventType == EventType.FTJACTIVE) {
    ftjMap.put(coworker.getName(), 1);
    ftjCount = 0; 
    if (ftjMap.size() > 0) {
      ftjCount = Math.min(10, Collections.max(ftjMap.values()));
      freeCount.setText("Biggest room:\r\n" + Collections.max(ftjMap.keySet()) + ", " + ftjCount);
    } else {
      freeCount.setText("Biggest room:");
    }
    ftjGlide.setValue(ftjCount * 0.1);
  } else if (eventType == EventType.FTJJOIN) {
    ftjMap.replace(coworker.getName(), ftjMap.get(coworker.getName()) + 1);
    ftjCount = 0;
    if (ftjMap.size() > 0) {
      ftjCount = Math.min(10, Collections.max(ftjMap.values()));
      freeCount.setText("Biggest room:\r\n" + Collections.max(ftjMap.keySet()) + ", " + ftjCount);
    } else {
      freeCount.setText("Biggest room:");
    }
    ftjGlide.setValue(ftjCount * 0.1);
  } else if (eventType == EventType.FTJLEAVE) {
    ftjMap.replace(coworker.getName(), Math.max(0, ftjMap.get(coworker.getName()) - 1));
    ftjCount = 0; 
    if (ftjMap.size() > 0) {
      ftjCount = Collections.max(ftjMap.values());
      freeCount.setText("Biggest room:\r\n" + Collections.max(ftjMap.keySet()) + ", " + ftjCount);
    } else {
      freeCount.setText("Biggest room:");
    }
    ftjGlide.setValue(ftjCount * 0.1);
  } else if (eventType == EventType.FTJINACTIVE) {
    ftjMap.remove(coworker.getName());
    ftjCount = 0; 
    if (ftjMap.size() > 0) {
      ftjCount = Collections.max(ftjMap.values());
      freeCount.setText("Biggest room:\r\n" + Collections.max(ftjMap.keySet()) + ", " + ftjCount);
    } else {
      freeCount.setText("Biggest room:");
    }
    ftjGlide.setValue(ftjCount * 0.1);
  } else if (eventType == EventType.FTJIN) {
    if (ftjMap.get(coworker.name) > 2) {
      scoreCard[2]++;
    }
  }
}

// Toggle sounds on and off
public void sonify(SimEvent event) {
  
  Coworker coworker = event.getCoworker();
  EventType eventType = event.getEvent();
  
  if (eventType == EventType.CALLIN || eventType == EventType.QUEUEREMOVE || eventType == EventType.FTJIN) {
    duckGlide.setValue(1330);
    masterGlide.setValue(0.20);
  } else if (eventType == EventType.VIDEOOUT) {
    duckGlide.setValue(0);
    masterGlide.setValue(1);
  }
  if (eventType == EventType.CALLGET) {
    float position[] = event.getPosition();
    String ttsFilePath = ttsMaker.createTTSWavFile(coworker.getName() + " is calling");
    SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
    callPan.addInput(sp);
    panGlide.setValue(position[0]);
    rateGlide.setValue(position[1]);
    callGlide.setValue(1);
    sp.setToLoopStart();
    sp.start();
    call.start(0);
  } else if (soundEvents.size() > 0 && (eventType == EventType.CALLIN || eventType == EventType.CALLREMOVE) && soundEvents.peek().getEvent() == EventType.CALLGET) {
    if (coworker.getName().equals(soundEvents.peek().getCoworker().getName())) {
      soundEvents.poll();
    }
  } else if (eventType == EventType.FTJACTIVE || eventType == EventType.FTJJOIN || eventType == EventType.FTJLEAVE) {
    ftjToggleGlide.setValue(1);
  } else if (eventType == EventType.FTJINACTIVE) {
    ftjToggleGlide.setValue(0);
  } else if (eventType == EventType.QUEUEADD) {
    queueToggleGlide.setValue(1);
  } 
}

public void printScoreCard() {
  println("Number of missed important people: " + scoreCard[0]);
  println("Number of contact queue overflow instances: " + scoreCard[1]);
  println("Number of large group joins: " + scoreCard[2]);
}
