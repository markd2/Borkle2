// Search - search through a soup for bubbles containing a particular string

import AppKit

enum SearchResult {
    case titleRange(BubbleID, NSRange)
    case bodyRange(BubbleID, NSRange)
    case tagRange(BubbleID, String, NSRange)

    var bubbleID: BubbleID {
        switch self {
        case .titleRange(let bubbleID, _): return bubbleID
        case .bodyRange(let bubbleID, _): return bubbleID
        case .tagRange(let bubbleID, _, _): return bubbleID
        }
    }

    var range: NSRange {
        switch self {
        case .titleRange(_, let range): return range
        case .bodyRange(_, let range): return range
        case .tagRange(_, _, let range): return range
        }
    }

}

class Searcher {

    func ranges(of text: String, in string: String?) -> [NSRange] {
        guard let string = string as? NSString else { return [] }

        var results: [NSRange] = []

        var searchRange = string.fullRange

        repeat {
            let range = string.range(of: text,
                                     options: [.caseInsensitive, .diacriticInsensitive],
                                     range: searchRange)

            guard range.length > 0 else { break }
            results.append(range)

            searchRange.location = range.upperBound
            searchRange.length = string.length - searchRange.location

        } while searchRange.length > 0

        return results
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


