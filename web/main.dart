import 'dart:html' as html;

import './audio.dart' as audio;

var punctuation = '.!?,';
var punctuationRegex = new RegExp('[$punctuation]');
var seperatorsRegex =
    new RegExp('[\\s$punctuation]'); // Punctuation plus whitespace

init() {
  // Clear loading indicator and show content as soon as we're running
  html.document
    ..getElementById('loading-indicator').style.setProperty('display', 'none')
    ..getElementById('post-load').style.setProperty('display', 'initial')
    ..getElementById('type').focus();

  audio.initAudio();
}

/// Split the string with the given pattern but keep the characters that
/// are being split on. They keep appended to the split before them.
List<String> splitKeepChars(String text, Pattern splitChars) {
  var split = new List<String>();
  var textList = text.split('');

  var shouldSplit = (String char) => char.contains(splitChars);

  var curRun = ''; // Accumulates chars between splits
  textList.forEach((char) {
    if (shouldSplit(char)) {
      // Keep the char we're splitting on in the previous split
      split.add(curRun + char);
      curRun = '';
    } else {
      // Nothin special, just keep track of it
      curRun += char;
    }
  });

  // Append whatever was left over
  split.add(curRun);

  return split;
}

onSentence(String sentence) {
  print('Sentence: "$sentence"');
}

onWord(String word) {
  print('Word: "$word"');
  audio.play(word);
}

/// Build the html based on what text is entered
///
/// What happens:
///  * All sentences (text ended by a period) get wrapped in
///    <span class="sentence">
String generateHtml(String text) {
  var builtHtml = text;

  var split = splitKeepChars(text, punctuationRegex);
  if (split.length > 1) {
    var last = split[split.length - 1];
    builtHtml = split.getRange(0, split.length - 1).map((t) {
      return '<span class="sentence">' + t;
    }).toList();

    builtHtml.add(last);
    builtHtml = builtHtml.join('</span>');
  }

  return builtHtml;
}

buildOnTypeFunction(html.Element el) {
  var lastText = '';
  return (html.Event e) {
    if (el.text.length > lastText.length + 1) {
      // Entered in more than one character in a single tick
      // Don't allow this
      // This makes it easier for me to pick characters as they're coming in
      // Copy and pasting text in doesn't make that easy. Hopefully this doesn't
      // Cause other issues
      el.text = lastText;
    } else if (el.text.length == lastText.length + 1) {
      // Typed one character
      var enteredChar = el.text[el.text.length - 1];

      if (enteredChar.contains(punctuationRegex)) {
        // Punctuation, handle sentence
        var split = el.text.split(punctuationRegex);

        // Make sure that they haven't entered *just* a punctuation mark
        if (split.length > 1) {
          var lastSentence = split[split.length - 2].trim();

          if (lastSentence.isNotEmpty) {
            onSentence(lastSentence);
          }
        }
      } else if (enteredChar.contains(seperatorsRegex)) {
        // Seperater, handle a single word
        var split = el.text.split(seperatorsRegex);

        // Make sure that they haven't entered *just* a single space
        if (split.length > 1) {
          var lastWord = split[split.length - 2].trim();

          if (lastWord.isNotEmpty) {
            onWord(lastWord);
          }
        }
      }
    } else {
      // Deleted stuff
    }

    el.setInnerHtml(generateHtml(el.text));

    // Set cursor to end of text
    var range = html.document.createRange()
      ..selectNodeContents(el)
      ..collapse(false);
    html.window.getSelection()
      ..removeAllRanges()
      ..addRange(range);

    lastText = el.text;
  };
}

main() {
  init();

  var el = html.document.getElementById('type');
  el.onInput.listen(buildOnTypeFunction(el));
}
