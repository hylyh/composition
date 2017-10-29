import 'dart:html' as html;

init() {
  // Clear loading indicator and show content as soon as we're running
  html.document
    ..getElementById('loading-indicator').style.setProperty('display', 'none')
    ..getElementById('post-load').style.setProperty('display', 'initial')
    ..getElementById('type').focus();
}

/// Split the string at any one of the characters in the given string
/// If includeSplitChars is true, includes the character that was split in the
///  element before it
List<String> splitAny(String text, String splitChars,
    {bool includeSplitChars = false}) {
  var split = new List<String>();
  var textList = text.split('');

  var shouldSplit = (char) => splitChars.contains(char);

  var curRun = ''; // Accumulates chars between splits
  textList.forEach((char) {
    if (shouldSplit(char)) {
      if (includeSplitChars) {
        // Include the char that was split in this run
        curRun += char;
      }
      split.add(curRun);
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

/// Build the html based on what text is entered
///
/// What happens:
///  * All sentences (text ended by a period) get wrapped in
///    <span class="sentence">
String generateHtml(String text) {
  var builtHtml = text;

  var split = splitAny(text, '.!?', includeSplitChars: true);
  print('split: $split');
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
