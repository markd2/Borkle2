// SoupAspect.swift: provide a different view into the contents of a soup.
//    I came _this_ close to calling it SoupAspic.  

import Foundation


class SoupAspect {

    typealias BubbleFilter = (Bubble) -> Bool

    let baseSoup: BubbleSoup
    var predicate: BubbleFilter = { _ in true } {
        didSet {
            refilter()
        }
    }

    private(set) var indices: [Int] = []

    static var identity: BubbleFilter = { _ in true }

    init(_ soup: BubbleSoup) {
        self.baseSoup = soup
        refilter()
    }

    func refilter() {
        let filteredIndicies = baseSoup.bubbles.indices.filter {
            predicate(baseSoup.bubbles[$0])
        }
        indices = filteredIndicies
        print(indices)
    }
    
}
