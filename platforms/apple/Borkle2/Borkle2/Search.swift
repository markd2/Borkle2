// Search - search through a soup for bubbles containing a particular string

import AppKit

enum SearchResult {
    case titleRange(BubbleID, NSRange)
    case bodyRange(BubbleID, NSRange)
    case tagRange(BubbleID, String, NSRange)
}

class Searcher {

    func ranges(of text: String, in string: String?) -> [NSRange] {
        guard let string = string else { return [] }
        return [NSRange(location: 1, length: 2)]
    }

    func search(for searchString: String,
                in soup: BubbleSoup) -> [SearchResult] {
        var results: [SearchResult] = []

        for i in 0 ..< soup.bubbles.count {
            let bubble = soup.bubbles[i]
            let bubbleID = BubbleID(i)
            
            let titleRanges = ranges(of: searchString, in: bubble.title)
            results += titleRanges.map { .titleRange(bubbleID, $0) }

            let bodyRanges = ranges(of: searchString, in: bubble.body)
            results += bodyRanges.map { .bodyRange(bubbleID, $0) }

            for tag in bubble.tags ?? [] {
                let tagRanges = ranges(of: searchString, in: tag)
                results += tagRanges.map { SearchResult.tagRange(bubbleID, tag, $0) }
            }
        }
        return results
    }
}


