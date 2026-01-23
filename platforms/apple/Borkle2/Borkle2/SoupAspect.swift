// SoupAspect.swift: provide a different view into the contents of a soup.
//    I came _this_ close to calling it SoupAspic.  

import Foundation


class SoupAspect {

    typealias BubbleFilter = (Bubble) -> Bool

    let baseSoup: BubbleSoup
    private var predicates: [BubbleFilter] = [] {
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

    func reset() {
        predicates = []
        refilter() // lazy eval this when getting indices?
    }

    func addPredicate(_ predicate: @escaping BubbleFilter) {
        predicates.append(predicate)
        refilter() // lazy eval this when getting indices?
    }

    func refilter() {
         if predicates.count == 0 {
            // no predicates == all the things
            indices = Array(baseSoup.bubbles.indices)
        } else {
            // otherwise, all must pass for the bubble to survive
            let filteredIndicies = baseSoup.bubbles.indices.filter {
                for predicate in predicates {
                    if predicate(baseSoup.bubbles[$0]) == false { return false }
                }
                return true
            }
            indices = filteredIndicies
        }
    }
}
