import Foundation


struct Bubble : Codable {
    var ID: Int32     // should match the index in the bubble soup
    var title: String?
    var body: String?
    var tags: [String]?
    var asset: String?   // path into bundle
}

