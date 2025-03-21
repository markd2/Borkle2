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
            
            /*
            if let bubbleString = try? encoder.encode(bubbleSoup.bubbles) {
                let bubbleFileWrapper = FileWrapper(regularFileWithString: bubbleString)
                bubbleFileWrapper.preferredFilename = legacyBubbleFilename
                documentFileWrapper.addFileWrapper(bubbleFileWrapper)
            }
             */
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
        /*
        guard let undoManager else {
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

        if let bubbleFileWrapper = fileWrappers[legacyBubbleFilename] {
            let bubbleData = bubbleFileWrapper.regularFileContents!
            let decoder = YAMLDecoder()
            do {
                let bubbles = try decoder.decode([Bubble].self, from: bubbleData)
                bubbleSoup.bubbles = bubbles
                defaultPlayfield = Playfield(soup: bubbleSoup, undoManager: undoManager)
                defaultPlayfield.migrateFrom(bubbles: bubbles)

                secondPlayfield = Playfield(soup: bubbleSoup, undoManager: undoManager)
                secondPlayfield.migrateSomeFrom(bubbles: bubbles)
            } catch {
                Swift.print("SNORGLE loading got \(error)")
            }
        }

        if let barrierFileWrapper = fileWrappers[barrierFilename] {
            let barrierData = barrierFileWrapper.regularFileContents!
            let decoder = YAMLDecoder()
            let barriers = try! decoder.decode([Barrier].self, from: barrierData)
            self.barriers = barriers
        }
        
        if let imageFileWrapper = fileWrappers[imageFilename] {
            let imageData = imageFileWrapper.regularFileContents!
            let image = NSImage(data: imageData)
            self.image = image
        }

        if let metadataFileWrapper = fileWrappers[metadataFilename] {
            let metadataData = metadataFileWrapper.regularFileContents!
            let decoder = JSONDecoder()
            let metadata = try! decoder.decode([String:String].self, from: metadataData)
            self.metadataDict = metadata
        }
        
        documentFileWrapper = fileWrapper
         */
    }


    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type, throwing an error in case of failure.
        // Alternatively, you could remove this method and override read(from:ofType:) instead.
        // If you do, you should also override isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }


}

