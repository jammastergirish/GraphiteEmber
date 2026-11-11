import Foundation
import Testing
@testable import GraphiteEmber

struct FormatTests {
    let now = Format.formatter("yyyy-MM-dd HH:mm").date(from: "2026-11-10 20:00")!
    func at(_ s: String) -> Date { Format.formatter("yyyy-MM-dd HH:mm").date(from: s)! }

    @Test func dateLabels() {
        #expect(Format.when(at("2026-11-10 19:53"), now: now) == "Today 19:53")
        #expect(Format.when(at("2026-11-09 08:12"), now: now) == "Yesterday 08:12")
        #expect(Format.when(at("2026-11-02 14:03"), now: now) == "Mon 2 Nov 14:03")
        #expect(Format.when(at("2025-11-09 17:45"), now: now) == "9 Nov 2025 17:45")
    }

    @Test func lengthsAndClock() {
        #expect(Format.length(4.6) == "0:05")
        #expect(Format.length(754) == "12:34")
        #expect(Format.length(3723) == "1:02:03")
        #expect(Format.clock(754) == "00:12:34")
    }
}
