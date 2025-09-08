import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:list_english_words/list_english_words.dart';

class Node {
  Node(String name) {
    val = name;
    edges = {};
  }

  late String val; 
  late Map<int, Node> edges;
}

class SpellData {
  SpellData() {
    init();
  }

  Node? root;
  HashSet wordSet = HashSet();

  void init() async {
    // list_english_words is a pretty large set of words
    // we should only use this to check if the word exists
    // if we want to use word suggestion then we should 
    // use a smaller dictionary
    wordSet = HashSet.from(list_english_words);
    
    // we should have our own dictionary that we can add words to
    // and we can add the words in this dictionary to our wordset
    wordSet.add('limbitless');
    wordSet.add('website');
  }

  // everything below here was used for word suggestion but
  // dart has this weird thing with TextSpan's recognizers
  // where things break. The word suggestion works on the concept
  // of the BK-Tree: https://en.wikipedia.org/wiki/BK-tree and
  // using Levenshtein distances

  // void init() async {
  //   Random rng = new Random();
  //   List myList = all.toList();
  //   List myDictionary = [];
  //   myList.shuffle(rng);
  //   wordSet = myList.toSet();

  //   String randomWords =  await rootBundle.loadString('assets/txt/out.txt');
  //   List dataList = randomWords.split('\n');

  //   for(int i = 0; i < dataList.length; i++) {
  //     List split = dataList[i].split(' ');
  //     if(split.length > 1 && int.parse(split[1]) >= 5) {
  //       wordSet.add(split[0]); 
  //     }
  //   }

  //   myDictionary.add('Limbitless');
  //   myDictionary.add('website');
  //   myDictionary.add('');

  // }

  // void initData() async {
  //   Random rng = new Random();
  //   List myList = all.toList();
  //   myList.shuffle(rng);
  //   print('shuffle done');

  //   print(myList.length);
  //   for(int i = 0; i < wordSet.length; i++) {
  //     addNode(wordSet.elementAt(i));
  //   }

  //   print('done');
  //   //recursiveWalk(root);
  // }

  void recursiveWalk(Node node){
    if(node == null) return;
    for(Node cNode in node.edges.values) {
      recursiveWalk(cNode);
    }
  }

  void addNode(String word) {
    if(root == null) {
      root = Node(word);
      return;
    }

    Node currNode = root!;
    do {
      int lDistance = levenshteinDistance(currNode.val, word);
      if(currNode.edges.containsKey(lDistance)) {
        currNode = currNode.edges[lDistance]!;
        continue;
      } else {
        currNode.edges[lDistance] = Node(word);
        break;
      }

    } while(true);
  }

  int levenshteinDistance(String word1, String word2) {
    word1 = '-' + word1;
    word2 = '-' + word2;
    List matrix = List.generate(word1.length, (index) => List.generate(word2.length, (j) => 0));

    for(int i = 0; i < word1.length; i++) {
      matrix[i][0] = i;
    }

    for(int j = 0; j < word2.length; j++) {
      matrix[0][j] = j;
    }
    
    int subCost = 0;
    for(int i = 1; i < word1.length; i++) {
      for(int j = 1; j < word2.length; j++) {
        if(word1[i] == word2[j]) {
          subCost = 0;
        } else {
          subCost = 1;
        }
        matrix[i][j] = minNum([
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + subCost
        ]);
      }
    }

    // debug stuff
    // String out = '';
    // for(int i = 0; i < word1.length; i++) {  
    //   for(int j = 0; j < word2.length; j++) {
    //     out += matrix[i][j].toString() + ' ';
    //   }
    //   out += '\n';
    // }

    // print(out);

    return matrix[word1.length - 1][word2.length - 1];

  }

  int minNum(List data) {
    int lowestVal = 1000000000000000000;
    for(int i = 0; i < data.length; i++) {
      if(data[i] < lowestVal) {
        lowestVal = data[i];
      }
    }
    return lowestVal;
  }

  void getMatches(String word, int tolerance) {
    Node currNode;
    List<Node> routes = [root!];
    List<String> matches = [];
    int lDistance;
    
    if(word.endsWith('ing') && word.length > 6) {
      word = word.replaceAll('ing', '');
    }

    if(word.endsWith('ed') && word.length > 6) {
      word = word.replaceAll('ed', '');
    }

    do{
      currNode = routes.first;
      routes.removeAt(0);
      lDistance = levenshteinDistance(word, currNode.val);
      if(lDistance <= tolerance) {
        matches.add(currNode.val);
      } 

      currNode.edges.forEach((key, value) {
        if(key > lDistance - tolerance && key < lDistance + tolerance) {
          routes.add(value);
        }
      });

    } while(routes.length > 0);

  }

  TextSpan checkString(String str, TextStyle style) {
    if(str == '') return TextSpan(text: str);
    List<String> words = str.split(' ');
    List<TextSpan> retVal = [];
    int startIndex = 0;

    for(int i = 0; i < words.length; i++) {
      String word = words[i];
      if(word == '') continue;
      if(word.endsWith('ing') && word.length > 6) {
        word = word.replaceRange(word.length - 3, word.length, '');
      } else if(word.endsWith('ed') && word.length > 6) {
        word = word.replaceRange(word.length - 2, word.length, '');
      }
      
      RegExp validWord = RegExp(r'^[a-zA-Z]+$');
      word = word.replaceAll(RegExp(r'[^\w\s]+'), '');
      if(validWord.hasMatch(word) 
          && !wordSet.contains(word.toLowerCase()) 
          && !wordSet.contains(word.substring(0, word.length - 1).toLowerCase()) 
          && !wordSet.contains(word.toLowerCase() + 'e')
        ) {
        retVal.add(TextSpan(text: joinString(words, startIndex, i)));
          startIndex = i + 1;
          retVal.add(
            TextSpan(
            text: words[i] + ' ', 
            style: const TextStyle(
              decoration: TextDecoration.underline, 
              decorationStyle: TextDecorationStyle.wavy,
              decorationColor: Colors.red,
              decorationThickness: 4
        )));
      }
    }
    if(startIndex != words.length) {
      retVal.add(TextSpan(text: joinString(words, startIndex, words.length)));
    }
    return TextSpan(children: retVal, style: style);
  }

  
  String joinString(List<String> list, int startIndex, int endIndex) {
    String ret = '';
    for(int i = startIndex; i < endIndex; i++) {
      if(i != list.length - 1) {
        if(list[i].contains("'")) list[i] = list[i].replaceAll("'", '');
        ret += list[i] + ' ';
      } else {
        ret += list[i];
      }
    }
    return ret;
  }

}
