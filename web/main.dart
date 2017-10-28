import 'dart:html' as html;

init() {
  // Clear loading indicator and show content as soon as we're running
  html.document
    ..getElementById('loading-indicator').style.setProperty('display', 'none')
    ..getElementById('post-load').style.setProperty('display', 'initial')
    ..getElementById('type').focus();
}

/// Build the html based on what text is entered
///
/// What happens:
///  * All sentences (text ended by a period) get wrapped in
///    <span class="sentence">
String generateHtml(String text) {
  var builtHtml = text;

  var split = builtHtml.split('.');
  print('split: $split');
  if (split.length > 1) {
    var last = split[split.length - 1];
    builtHtml = split.getRange(0, split.length - 1).map((t) {
      return '<span class="sentence">' + t;
    }).toList();

    builtHtml.add(last);
    builtHtml = builtHtml.join('.</span>');
  }

  return builtHtml;
}

buildOnTypeFunction(html.Element el) {
  var lastText = '';
  return (html.Event e) {
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
