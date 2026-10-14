import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

// Pausenmenü während des Matches: Fortsetzen / Speichern / Verwerfen
function createPauseMenu() as WatchUi.Menu2 {
    var menu = new WatchUi.Menu2({:title => tr(Rez.Strings.Pause)});
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.Resume), null, :resume, null));
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.Save), null, :save, null));
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.Discard), null, :discard, null));
    return menu;
}

// Menü nach Matchende: nur noch Speichern / Verwerfen
function createEndMenu() as WatchUi.Menu2 {
    var menu = new WatchUi.Menu2({:title => tr(Rez.Strings.EndMatch)});
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.Save), null, :save, null));
    menu.addItem(new WatchUi.MenuItem(tr(Rez.Strings.Discard), null, :discard, null));
    return menu;
}

class PauseMenuDelegate extends WatchUi.Menu2InputDelegate {

    var recorder as MatchRecorder;
    var resumeOnBack as Boolean;    // true = Zurück setzt die Aufzeichnung fort (Pausenmenü), false = nur Menü schließen (Matchende)

    function initialize(r as MatchRecorder, resume as Boolean) {
        Menu2InputDelegate.initialize();
        recorder = r;
        resumeOnBack = resume;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == :resume) {
            recorder.start();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (id == :save) {
            recorder.save();
            System.exit();
        } else if (id == :discard) {
            recorder.discard();
            System.exit();
        }
    }

    function onBack() as Void {
        if (resumeOnBack) {
            recorder.start();
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
