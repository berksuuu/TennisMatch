import Toybox.Lang;
import Toybox.WatchUi;

// Farb-Themes für die Spielansicht: linke Hälfte (ich) und rechte Hälfte (Gegner, etwas dunkler)
const THEME_COUNT = 5;

const BALL_COLOR = 0xDFFF4F;      // Neongelb wie ein Tennisball
const TEXT_COLOR = 0xFFFFFF;
const MUTED_COLOR = 0xAAAAAA;

function themeLeftColor(theme as Number) as Number {
    var colors = [0x000000, 0x1E6FD9, 0xC4562A, 0x2E7D32, 0x2B4A8C];
    return colors[theme];
}

function themeRightColor(theme as Number) as Number {
    var colors = [0x1A1A1A, 0x14509E, 0x8E3D1D, 0x1E5A22, 0x1B3163];
    return colors[theme];
}

function themeName(theme as Number) as String {
    var names = [
        Rez.Strings.ThemeClassic,
        Rez.Strings.ThemeMelbourne,
        Rez.Strings.ThemeParis,
        Rez.Strings.ThemeLondon,
        Rez.Strings.ThemeNewYork
    ];
    return tr(names[theme]);
}

// Text aus den Sprachdateien laden (resources/strings bzw. resources-deu/strings)
function tr(id as ResourceId) as String {
    return WatchUi.loadResource(id) as String;
}

// Millisekunden als "m:ss" bzw. ab einer Stunde als "h:mm:ss"
function formatDuration(ms as Number) as String {
    var seconds = ms / 1000;
    var hours = seconds / 3600;
    var minutes = (seconds / 60) % 60;
    var secs = seconds % 60;
    if (hours > 0) {
        return hours.toString() + ":" + minutes.format("%02d") + ":" + secs.format("%02d");
    }
    return minutes.toString() + ":" + secs.format("%02d");
}

// Beendete Sätze als Text, z. B. "6-4  3-6"
function setScoresText(match as MatchState) as String {
    var text = "";
    for (var i = 0; i < match.setScores.size(); i++) {
        var score = match.setScores[i];
        if (i > 0) {
            text += "  ";
        }
        text += score[ME].toString() + "-" + score[OPPONENT].toString();
    }
    return text;
}
