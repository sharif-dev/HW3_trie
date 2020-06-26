import Foundation

class TrieNode<T: Hashable> {
  var value: T?
  weak var parentNode: TrieNode?
  var children: [T: TrieNode] = [:]
  var isTerminating = false
  var isLeaf: Bool {
    return children.count == 0
  }

  init(value: T? = nil, parentNode: TrieNode? = nil) {
    self.value = value
    self.parentNode = parentNode
  }

  func add(value: T) {
    guard children[value] == nil else {
      return
    }
    children[value] = TrieNode(value: value, parentNode: self)
  }
}

class Trie: NSObject, NSCoding {
  typealias Node = TrieNode<Character>
  public var count: Int {
    return wordCount
  }
  public var isEmpty: Bool {
    return wordCount == 0
  }
  public var words: [String] {
    return wordsInSubtrie(rootNode: root, partialWord: "")
  }
  fileprivate let root: Node
  fileprivate var wordCount: Int

  override init() {
    root = Node()
    wordCount = 0
    super.init()
  }

  required convenience init?(coder decoder: NSCoder) {
    self.init()
    let words = decoder.decodeObject(forKey: "words") as? [String]
    for word in words! {
      self.insert(word: word)
    }
  }

  func encode(with coder: NSCoder) {
    coder.encode(self.words, forKey: "words")
  }
}

extension Trie {    

  func insert(word: String) {
    guard !word.isEmpty else {
      return
    }
    var currentNode = root
    for character in word.lowercased() {
      if let childNode = currentNode.children[character] {
        currentNode = childNode
      } else {
        currentNode.add(value: character)
        currentNode = currentNode.children[character]!
      }
    }

    guard !currentNode.isTerminating else {
      return
    }
    wordCount += 1
    currentNode.isTerminating = true
  }

  func contains(word: String) -> Bool {
    guard !word.isEmpty else {
      return false
    }
    var currentNode = root
    for character in word.lowercased() {
      guard let childNode = currentNode.children[character] else {
        return false
      }
      currentNode = childNode
    }
    return currentNode.isTerminating
  }

  private func findLastNodeOf(word: String) -> Node? {
    var currentNode = root
    for character in word.lowercased() {
      guard let childNode = currentNode.children[character] else {
        return nil
      }
      currentNode = childNode
    }
    return currentNode
  }

  private func findTerminalNodeOf(word: String) -> Node? {
    if let lastNode = findLastNodeOf(word: word) {
      return lastNode.isTerminating ? lastNode : nil
    }
    return nil
  }

  private func deleteNodesForWordEndingWith(terminalNode: Node) {
    var lastNode = terminalNode
    var character = lastNode.value
    while lastNode.isLeaf, let parentNode = lastNode.parentNode {
      lastNode = parentNode
      lastNode.children[character!] = nil
      character = lastNode.value
      if lastNode.isTerminating {
        break
      }
    }
  }

  func remove(word: String) {
    guard !word.isEmpty else {
      return
    }
    guard let terminalNode = findTerminalNodeOf(word: word) else {
      return
    }
    if terminalNode.isLeaf {
      deleteNodesForWordEndingWith(terminalNode: terminalNode)
    } else {
      terminalNode.isTerminating = false
    }
    wordCount -= 1
  }

  fileprivate func wordsInSubtrie(rootNode: Node, partialWord: String) -> [String] {
    var subtrieWords = [String]()
    var previousLetters = partialWord
    if let value = rootNode.value {
      previousLetters.append(value)
    }
    if rootNode.isTerminating {
      subtrieWords.append(previousLetters)
    }
    for childNode in rootNode.children.values {
      let childWords = wordsInSubtrie(rootNode: childNode, partialWord: previousLetters)
      subtrieWords += childWords
    }
    return subtrieWords
  }

  func findWordsWithPrefix(prefix: String) -> [String] {
    var words = [String]()
    let prefixLowerCased = prefix.lowercased()
    if let lastNode = findLastNodeOf(word: prefixLowerCased) {
      if lastNode.isTerminating {
        words.append(prefixLowerCased)
      }
      for childNode in lastNode.children.values {
        let childWords = wordsInSubtrie(rootNode: childNode, partialWord: prefixLowerCased)
        words += childWords
      }
    }
    return words
  }
}

func create_trie(arr: [[String]], trie: Trie, m : Int, n : Int, i: Int, j: Int, is_checked: [[Bool]], string: String){
    var mutable_is_checked = is_checked
    let mutable_string = string
    if(i-1 >= 0 && j-1 >= 0){
        if(!is_checked[i-1][j-1]){
            mutable_is_checked[i-1][j-1] = true
            trie.insert(word: mutable_string + arr[i-1][j-1])
            create_trie(arr: arr, trie: trie, m: m, n: n, i: i-1, j: j-1, is_checked: mutable_is_checked, string: mutable_string + arr[i-1][j-1])
        }
    }
    if(i-1 >= 0){
        if(!is_checked[i-1][j]){
            mutable_is_checked[i-1][j] = true
            trie.insert(word: mutable_string + arr[i-1][j])
            create_trie(arr: arr, trie: trie, m: m, n: n, i: i-1, j: j, is_checked: mutable_is_checked, string: mutable_string + arr[i-1][j])
        }
    }
    if(j-1 >= 0){
        if(!is_checked[i][j-1]){
            mutable_is_checked[i][j-1] = true
            trie.insert(word: mutable_string + arr[i][j-1])
            create_trie(arr: arr, trie: trie, m: m, n: n, i: i, j: j-1, is_checked: mutable_is_checked, string: mutable_string + arr[i][j-1])
        }
    }
    if(j+1 < n){
        if(!is_checked[i][j+1]){
            mutable_is_checked[i][j+1] = true
            trie.insert(word: mutable_string + arr[i][j+1])
            create_trie(arr: arr, trie: trie, m: m, n: n, i: i, j: j+1, is_checked: mutable_is_checked, string: mutable_string + arr[i][j+1])
        }
        
    }
    if(i-1 >= 0 && j+1 < n){
        if(!is_checked[i-1][j+1]){
            mutable_is_checked[i-1][j+1] = true
            trie.insert(word: mutable_string + arr[i-1][j+1])
            create_trie(arr: arr, trie: trie, m: m, n: n, i: i-1, j: j+1, is_checked: mutable_is_checked, string: mutable_string + arr[i-1][j+1])
        }
    }
    if(i+1 < m){
        if(!is_checked[i+1][j]){
            mutable_is_checked[i+1][j] = true
            trie.insert(word: mutable_string + arr[i+1][j])
            create_trie(arr: arr, trie: trie, m: m, n: n, i: i+1, j: j, is_checked: mutable_is_checked, string: mutable_string + arr[i+1][j])
            
        }
        
    }
    if(i+1 < m && j-1 >= 0){
        if(!is_checked[i+1][j-1]){
            mutable_is_checked[i+1][j-1] = true
            trie.insert(word: mutable_string + arr[i+1][j-1])
            create_trie(arr: arr, trie: trie, m: m, n: n, i: i+1, j: j-1, is_checked: mutable_is_checked, string: mutable_string + arr[i+1][j-1])
        } 
    }
    if(i+1 < m && j+1 < n ){
        if(!is_checked[i+1][j+1]){
            mutable_is_checked[i+1][j+1] = true
            trie.insert(word: mutable_string + arr[i+1][j+1])
            create_trie(arr: arr, trie: trie, m: m, n: n, i: i+1, j: j+1, is_checked: mutable_is_checked, string: mutable_string + arr[i+1][j+1])
        }
        
    }
}


let input  = readLine()!
let input_array = input.components(separatedBy: " ")

let dims = readLine()!
let dims_array = dims.components(separatedBy: " ")
let m = Int(dims_array[0])!
let n = Int(dims_array[1])!

var arr = [[String]]()
for _ in 0...(m-1){
    let line  = readLine()!
    let line_array = line.components(separatedBy: " ")
    var row = [String]()
    for j in 0...(n-1){
        row.append(line_array[j])
    }
    arr.append(row)
}
var trie = Trie()
var is_checked = [[Bool]]()
for _ in 0...(m-1){
    var row = [Bool]()
    for _ in 0...(n-1){
        row.append(false)
    }
    is_checked.append(row)
}

for i in 0...(m-1){
    for j in 0...(n-1){
        is_checked[i][j] = true
        trie.insert(word: arr[i][j])
        create_trie(arr: arr, trie: trie, m: m, n: n, i: i, j: j, is_checked: is_checked, string: arr[i][j])
        is_checked[i][j] = false
    }
    
}

for string in input_array{
    if trie.contains(word: string){
        print(string)
    }
}