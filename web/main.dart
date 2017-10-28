import 'dart:html' as html;

main() {
  // Clear loading indicator and show content as soon as we're running
  html.document
    ..getElementById('loading-indicator').style.setProperty('display', 'none')
    ..getElementById('post-load').style.setProperty('display', 'initial')
    ..getElementById('type').focus();
}
