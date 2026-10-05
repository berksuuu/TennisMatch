import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Lang;

class MatchRecorder {

    var session as ActivityRecording.Session?;   // null = keine Aufzeichnung vorhanden

    function initialize() {
        session = null;                            // am Anfang gibt es noch keine Session
    }

    // Aufzeichnung starten bzw. nach einer Pause fortsetzen
    function start() as Void {
        if (session == null) {                                // gibt es noch KEINE Session?
            session = ActivityRecording.createSession({
                :name => "Tennis",
                :sport => Activity.SPORT_TENNIS,
                :subSport => Activity.SUB_SPORT_GENERIC
            });
        }
        session.start();
    }

    // Timer anhalten (Session bleibt erhalten)
    function pause() as Void {
        if (session != null && session.isRecording()) {
            session.stop();
        }
    }

    // Läuft die Aufzeichnung gerade?
    function isRecording() as Boolean {
        return  session != null && session.isRecording();                        // Session vorhanden UND sie zeichnet auf (siehe pause)
    }

    // Neue Runde beginnen, z. B. bei neuem Satz
    function addLap() as Void {
        if (isRecording()) {
            session.addLap();
        }
    }

    // Aufzeichnung beenden und als Aktivität speichern
    function save() as Void {
        if (session != null) {
            session.stop();
            session.save();
            session = null;                        // danach gibt es keine Session mehr
        }
    }

    // Aufzeichnung beenden und wegwerfen
    function discard() as Void {
         if (session != null) {
            session.stop();
            session.discard();
            session = null;                        // danach gibt es keine Session mehr
        }                                       // genauso aufgebaut wie save, nur mit discard()
    }
}
