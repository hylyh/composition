import 'dart:convert' as convert;
import 'dart:html' as html;

var numBigrams = 150;
var bigramsPath = './bigrams.json';

Set<String> allBigrams;

initBigrams() async {
  var text = await html.HttpRequest.getString(bigramsPath);
  List<String> bigramsList = convert.JSON.decode(text);
  allBigrams = new Set.from(bigramsList.take(numBigrams));
}

String cleanWord(String word) =>
    word.replaceAll(new RegExp(r'[^a-zA-Z]'), '');

List<String> getBigrams(String word) {
  List<String> bigrams = new List();

  for (var i = 0; i < word.length - 1; i++) {
    // Compare each letter to the letter after it and see if its in the word
    var testBigram = word.substring(i, i + 2);
    if (allBigrams.contains(testBigram.toLowerCase())) {
      bigrams.add(testBigram);
    }
  }

  print(bigrams);
  return bigrams;
}
