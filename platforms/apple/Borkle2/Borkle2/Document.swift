import Cocoa
import Yams

class Document: NSDocument {

    var soup: BubbleSoup = BubbleSoup()

    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override var windowNibName: NSNib.Name? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return NSNib.Name("Document")
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    @IBAction func splunge(_ sender: NSControl) {
        Swift.print("hello")
        
        let bubbles =
          [
            Bubble(ID: 0, title: "Spoon", body: "Once upon a midnight dreary etc etc etc", tags: ["#first", "#splunge"], asset: nil),
            Bubble(ID: 1, title: "Greeble Bork", body: "blah blah blah blah blah blah blah", tags: [], asset: nil),
            Bubble(ID: 2, title: "Hoover fnord ekky", body: "Folks who are even a tiny bit crafty know the name Singer.  Back in the day, they had a nationwide chain of 175 stores selling the machines, fabrics, patterns, and associated goodies.  They needed automation", tags: ["#singer", "#system-ten", "#exhibit"], asset: nil),
          ]

        soup.bubbles = bubbles
    }

    @IBAction func saveYaml(_ sender: NSControl) {
        Swift.print("SAVE")
        let encoder = YAMLEncoder()
        var options = encoder.options
        options.indent = 2
        options.width = -1
        options.explicitStart = true
        options.explicitEnd = true
        options.sortKeys = true
        encoder.options = options
        let encodedYAML = try! encoder.encode(soup)
        let data = encodedYAML.data(using: .utf8)!
        let place = URL(fileURLWithPath: "/Users/markd/Downloads/blargh.yaml")
        try! data.write(to: place)
    }
 
    @IBAction func loadYaml(_ sender: NSControl) {
        Swift.print("LOAD")
        let place = URL(fileURLWithPath: "/Users/markd/Downloads/blargh.yaml")
        let data = try! Data(contentsOf: place, options: [])
        let decoder = YAMLDecoder()
        let decoded = try! decoder.decode(BubbleSoup.self, from: data)
        soup = decoded
    }

    @IBAction func verify(_ sender: NSControl) {
        soup.verify()
    }
}

