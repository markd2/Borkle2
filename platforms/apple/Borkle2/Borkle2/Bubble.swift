import Foundation


class Bubble : Codable {

    // Technically not needed, but handy for figuring out if we have
    // index issues.  This should match the array index in the bubble
    // soup.
    var ID: Int32
    var title: String?
    var body: String?
    var tags: [String]?
    var asset: String?   // path into bundle

    init(ID: Int32, title: String?, body: String?,
         tags: [String]?, asset: String?) {
        self.ID = ID
        self.title = title
        self.body = body
        self.tags = tags
        self.asset = asset
    }
}
