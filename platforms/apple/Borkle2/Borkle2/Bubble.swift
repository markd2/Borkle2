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

    init(title: String?, body: String?,
         tags: [String]?, asset: String?) {
        self.ID = -1
        self.title = title
        self.body = body
        self.tags = tags
        self.asset = asset
    }

    func tagsContainsString(_ string: String) -> Bool {
        if let tags {
            for tag in tags {
                if tag.contains(string) { return true }
            }
        }
        return false
    }

    func containsString(_ string: String) -> Bool {
        if let title, title.contains(string) { return true }
        if let body, body.contains(string) { return true }
        if tagsContainsString(string) { return true }
        return false
    }
}
