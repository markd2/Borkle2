import Cocoa
import Yams

class Document: NSDocument {

    // A directory file wrapper.
    var documentFileWrapper: FileWrapper?

    var metadataDict = ["frames" : ["frame-1" : "NPCs", "frame-2" : "Kobolds ate my baby!"]] {
        didSet {
            documentFileWrapper?.remove(filename: metadataFilename)
        }
    }
    
    var bubbles: [Bubble] = []

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

        return documentFileWrapper
    }


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

        if let metadataFileWrapper = fileWrappers[bubbleFilename] {
            let metadataData = metadataFileWrapper.regularFileContents!
            let decoder = YAMLDecoder()
            let bubbles = try! decoder.decode([Bubble].self, from: metadataData)
            self.bubbles = bubbles
            Swift.print("GOT \(bubbles.count) BUBBLES")
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
}

