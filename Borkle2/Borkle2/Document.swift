import Cocoa
import Yams

class Document: NSDocument {

    // A directory file wrapper.
    var documentFileWrapper: FileWrapper?

    var bubbles: [Bubble] = []
    var frames: [Frame] = []

    var metadataDict = ["frames" : ["1" : "NPCs", "2" : "Kobolds ate my baby!"]] {
        didSet {
            documentFileWrapper?.remove(filename: metadataFilename)
        }
    }

    enum FileWrapperError: Error {
        case badFileWrapper
        case unexpectedlyNilFileWrappers
    }
        
    let metadataFilename = "metadata.yaml"
    let bubbleFilename = "bubbles.yaml"
    let frameFilenameTemplate = "frame-%d.yaml"  // e.g. frame-23.jpg
    let assetsDirectoryName = "assets"
    let assetFilenameTemplate = "asset-%d.%s"    // e.g. asset-5.jpg
    let textIndexFilename = "textindex.txt"

    override init() {
        super.init()
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override var windowNibName: NSNib.Name? {
        return NSNib.Name("Document")
    }

    // SAVING
    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        if documentFileWrapper == nil {
            let childrenByPreferredName = [String: FileWrapper]()
            documentFileWrapper = FileWrapper(directoryWithFileWrappers: childrenByPreferredName)
        }

        guard let documentFileWrapper = documentFileWrapper else {
            throw(FileWrapperError.badFileWrapper)
        }

        guard let fileWrappers = documentFileWrapper.fileWrappers else {
            throw(FileWrapperError.unexpectedlyNilFileWrappers)
        }

        if fileWrappers[bubbleFilename] == nil {
             let encoder = YAMLEncoder()

            if let bubbleString = try? encoder.encode(bubbles) {
                let bubbleFileWrapper = FileWrapper(regularFileWithString: bubbleString)
                bubbleFileWrapper.preferredFilename = bubbleFilename
                documentFileWrapper.addFileWrapper(bubbleFileWrapper)
            }
        }
        
        if fileWrappers[metadataFilename] == nil {
            // write the new file wrapper for our metadata
            let encoder = YAMLEncoder()

            if let metadataData = try? encoder.encode(metadataDict).data(using: .utf8) {
                let metadataFileWrapper = FileWrapper(regularFileWithContents: metadataData)
                metadataFileWrapper.preferredFilename = metadataFilename
                documentFileWrapper.addFileWrapper(metadataFileWrapper)
            }
        }

        for frame in frames {
            let encoder = YAMLEncoder()
            
            if let frameData = try? encoder.encode(frame).data(using: .utf8) {
                let filename = String(format: frameFilenameTemplate, frame.identifier)
                documentFileWrapper.remove(filename: bubbleFilename)
                
                let frameFileWrapper = FileWrapper(regularFileWithContents: frameData)
                frameFileWrapper.preferredFilename = filename
                documentFileWrapper.addFileWrapper(frameFileWrapper)
            }
        }
    
        return documentFileWrapper
    }


    // LOADING
    override func read(from fileWrapper: FileWrapper, 
                       ofType typeName: String) throws {
        guard let _ = undoManager else {
            fatalError("We kind of need an undo manager")
        }

        // (comment from apple sample code)
        // look for the file wrappers.
        // for each wrapper, extract the data and keep the file wrapper itself.
        // The file wrappers are kept so that, if the corresponding data hasn't
        // been changed, they can be reused during a save, and so the source
        // file can be reused rather than rewritten.
        // This avoids the overhead of syncing data unnecessarily. If the data
        // related to a file wrapper changes (like a new image is added or text
        // is edited), the corresponding file wrapper object is disposed of
        // and a new file wrapper created on save.

        let fileWrappers = fileWrapper.fileWrappers!

        if let metadataFileWrapper = fileWrappers[metadataFilename] {
            let metadataData = metadataFileWrapper.regularFileContents!
            let decoder = YAMLDecoder()
            let metadata = try! decoder.decode([String:[String:String]].self, from: metadataData)
            self.metadataDict = metadata
        }

        if let bubbleFileWrapper = fileWrappers[bubbleFilename] {
            let bubbleData = bubbleFileWrapper.regularFileContents!
            let decoder = YAMLDecoder()
            let bubbles = try! decoder.decode([Bubble].self, from: bubbleData)
            self.bubbles = bubbles
            Swift.print("GOT \(bubbles.count) BUBBLES")
        }

        for frame in frames {
            let filename = String(format: frameFilenameTemplate, frame.identifier)
            if let frameFileWrapper = fileWrappers[filename] {
                let frameData = frameFileWrapper.regularFileContents!
                let decoder = YAMLDecoder()
                let frame = try! decoder.decode(Frame.self, from: frameData)
                frames.append(frame)
            }
        }

        Swift.print("YEEHAW \(metadataDict)")
        documentFileWrapper = fileWrapper
    }
}

extension Document {
    @IBAction func bubbleBootstreap(_ sender: NSButton) {
        Swift.print("GREEBLE")
        var maxIndex = 1
        
        for bubble in bubbles {
            maxIndex = max(bubble.ID, maxIndex)
        }

        var index = maxIndex + 1
        for _ in 0 ..< 5 {
            let bubble = Bubble(ID: index)
            bubble.text = "This is bubble \(index)"
            bubbles.append(bubble)
            index += 1
        }

        documentFileWrapper?.remove(filename: bubbleFilename)
        updateChangeCount(.changeDone)
    }

    @IBAction func frame1(_ sender: NSButton) {
        let frame = Frame(ID: 1)
        frame.bubbleIDs = [1, 2, 5, 10]
        frame.locations = [
          BubbleLocation(bubbleID: 1,
                         frame: CGRect(x: 10, y: 15, width: 120, height: 15),
                         fillColor: RGB.white),
          BubbleLocation(bubbleID: 2,
                         frame: CGRect(x: 100, y: 30, width: 100, height: 20),
                         fillColor: RGB(nscolor: NSColor.magenta)),
          BubbleLocation(bubbleID: 5,
                         frame: CGRect(x: 30, y: 45, width: 90, height: 15),
                         fillColor: RGB(nscolor: NSColor.orange)),
          BubbleLocation(bubbleID: 10,
                         frame: CGRect(x: 200, y: 60, width: 130, height: 20),
                         fillColor: RGB(nscolor: NSColor.yellow))
        ]
        frame.connections = [
          Connection(start: 1, end: 5, label: "oop"),
          Connection(start: 1, end: 2, label: "ack"),
          Connection(start: 5, end: 10, label: "oopack"),
          Connection(start: 10, end: 1, label: "ackoop")
        ]
        frame.barriers = [
          Barrier(location: 100, vertical: true),
          Barrier(location: 200, vertical: false)
        ]

        frames.append(frame)

        updateChangeCount(.changeDone)
    }

    @IBAction func frame2(_ sender: NSButton) {
        let frame = Frame(ID: 2)
        frame.bubbleIDs = [1, 2, 13, 15, 21]
        frame.locations = [
          BubbleLocation(bubbleID: 1,
                         frame: CGRect(x: 10, y: 15, width: 120, height: 15),
                         fillColor: RGB.white),
          BubbleLocation(bubbleID: 2,
                         frame: CGRect(x: 100, y: 30, width: 100, height: 20),
                         fillColor: RGB(nscolor: NSColor.magenta)),
          BubbleLocation(bubbleID: 13,
                         frame: CGRect(x: 30, y: 45, width: 90, height: 15),
                         fillColor: RGB(nscolor: NSColor.orange)),
          BubbleLocation(bubbleID: 15,
                         frame: CGRect(x: 200, y: 60, width: 130, height: 20),
                         fillColor: RGB(nscolor: NSColor.yellow)),
          BubbleLocation(bubbleID: 21,
                         frame: CGRect(x: 300, y: 120, width: 110, height: 15),
                         fillColor: RGB(nscolor: NSColor.brown))
        ]
        frame.connections = [
          Connection(start: 13, end: 1, label: ""),
          Connection(start: 13, end: 2, label: ""),
          Connection(start: 13, end: 15, label: ""),
          Connection(start: 13, end: 21, label: "")
        ]
        frame.barriers = [
        ]

        frames.append(frame)

        updateChangeCount(.changeDone)
    }
}

