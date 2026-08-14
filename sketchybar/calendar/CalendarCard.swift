import AppKit
import Foundation

// Renders the calendar popup as a PNG. sketchybar labels are single-line, so
// the grid and agenda have to be drawn.
//
// stdin: one event per line, "HH:MM<TAB>Title".

// MARK: - Palette (tokyonight)

let bg        = NSColor(srgbRed: 0.102, green: 0.106, blue: 0.149, alpha: 1)   // #1a1b26
let edge      = NSColor(srgbRed: 0.231, green: 0.259, blue: 0.380, alpha: 1)   // #3b4261
let ink       = NSColor(srgbRed: 0.753, green: 0.792, blue: 0.961, alpha: 1)   // #c0caf5
let dim       = NSColor(srgbRed: 0.400, green: 0.435, blue: 0.569, alpha: 1)   // #666f91
let faint     = NSColor(srgbRed: 0.290, green: 0.318, blue: 0.427, alpha: 1)
let accent    = NSColor(srgbRed: 0.478, green: 0.635, blue: 0.968, alpha: 1)   // #7aa2f7
let violet    = NSColor(srgbRed: 0.733, green: 0.604, blue: 0.968, alpha: 1)   // #bb9af7
let onAccent  = NSColor(srgbRed: 0.102, green: 0.106, blue: 0.149, alpha: 1)

// MARK: - Metrics

let scale: CGFloat   = 2.0        // sketchybar scales back down by 0.5
let pad: CGFloat     = 18
let cardW: CGFloat   = 268
let cellW: CGFloat   = (cardW - pad * 2) / 7
let cellH: CGFloat   = 27
let headerH: CGFloat = 46
let dowH: CGFloat    = 20
let agendaRowH: CGFloat = 24

func font(_ size: CGFloat, _ weight: NSFont.Weight) -> NSFont {
    let name = weight >= .bold ? "JetBrainsMonoNF-Bold" : "JetBrainsMonoNF-Regular"
    if let f = NSFont(name: name, size: size) { return f }
    return NSFont.monospacedSystemFont(ofSize: size, weight: weight)
}

// MARK: - Input

struct Event { let time: String; let title: String }

var events: [Event] = []
while let line = readLine(strippingNewline: true) {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    if trimmed.isEmpty { continue }
    let parts = trimmed.components(separatedBy: "\t")
    if parts.count >= 2 {
        events.append(Event(time: parts[0], title: parts[1]))
    } else {
        events.append(Event(time: "", title: trimmed))
    }
}
events = Array(events.prefix(4))

// MARK: - Month maths

let cal = Calendar.current
let now = Date()
let todayDay = cal.component(.day, from: now)
let comps = cal.dateComponents([.year, .month], from: now)
let firstOfMonth = cal.date(from: comps)!
let daysInMonth = cal.range(of: .day, in: .month, for: now)!.count
// firstWeekday is 1-based Sunday; convert to a 0-based column
let leading = (cal.component(.weekday, from: firstOfMonth) - cal.firstWeekday + 7) % 7
let weekRows = Int(ceil(Double(leading + daysInMonth) / 7.0))

let agendaH: CGFloat = events.isEmpty
    ? agendaRowH + 10
    : CGFloat(events.count) * agendaRowH + 14
let gridH = CGFloat(weekRows) * cellH
let cardH = headerH + dowH + gridH + 12 + agendaH + pad

// MARK: - Canvas

let repr = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: Int(cardW * scale), pixelsHigh: Int(cardH * scale),
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
repr.size = NSSize(width: cardW, height: cardH)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: repr)
let ctx = NSGraphicsContext.current!.cgContext

// AppKit origin is bottom-left; every y below is measured from the top.
func flip(_ y: CGFloat) -> CGFloat { cardH - y }

// Centre text on a y measured from the card top. Doing this by hand drifts by
// half a line height, which puts the today numeral off its disc.
func drawCentered(_ s: String, x: CGFloat, centerY: CGFloat, font f: NSFont,
                  color: NSColor, width: CGFloat? = nil,
                  align: NSTextAlignment = .center) {
    let h = f.ascender - f.descender
    draw(s, x: x, top: centerY - h / 2, font: f, color: color,
         width: width, align: align)
}

func draw(_ s: String, x: CGFloat, top: CGFloat, font f: NSFont,
          color: NSColor, width: CGFloat? = nil, align: NSTextAlignment = .left) {
    let para = NSMutableParagraphStyle()
    para.alignment = align
    para.lineBreakMode = .byTruncatingTail
    let attrs: [NSAttributedString.Key: Any] =
        [.font: f, .foregroundColor: color, .paragraphStyle: para]
    let h = f.ascender - f.descender
    let w = width ?? cardW
    (s as NSString).draw(in: NSRect(x: x, y: flip(top) - h, width: w, height: h),
                         withAttributes: attrs)
}

// Card ground
ctx.setFillColor(bg.cgColor)
let card = CGPath(roundedRect: CGRect(x: 0.5, y: 0.5, width: cardW - 1, height: cardH - 1),
                  cornerWidth: 10, cornerHeight: 10, transform: nil)
ctx.addPath(card); ctx.fillPath()
ctx.setStrokeColor(edge.cgColor); ctx.setLineWidth(1)
ctx.addPath(card); ctx.strokePath()

// MARK: - Header

let monthFmt = DateFormatter(); monthFmt.dateFormat = "MMMM"
let yearFmt  = DateFormatter(); yearFmt.dateFormat  = "yyyy"
let month = monthFmt.string(from: now)
draw(month, x: pad, top: 18, font: font(15, .bold), color: ink)

let monthW = (month as NSString)
    .size(withAttributes: [.font: font(15, .bold)]).width
draw(yearFmt.string(from: now), x: pad + monthW + 7, top: 20,
     font: font(12, .regular), color: dim)

// Rule under the month word. Must clear the text box (top 18 + ~19pt).
ctx.setFillColor(accent.cgColor)
ctx.fill(CGRect(x: pad, y: flip(42), width: monthW, height: 2))

// MARK: - Weekday row

let dowFmt = DateFormatter()
let symbols = dowFmt.veryShortStandaloneWeekdaySymbols ?? ["S","M","T","W","T","F","S"]
var ordered: [String] = []
for i in 0..<7 { ordered.append(symbols[(cal.firstWeekday - 1 + i) % 7]) }

for (i, d) in ordered.enumerated() {
    draw(d.uppercased(), x: pad + CGFloat(i) * cellW, top: headerH + 12,
         font: font(9.5, .bold), color: faint, width: cellW, align: .center)
}

// MARK: - Day grid

let gridTop = headerH + dowH
for day in 1...daysInMonth {
    let idx = leading + day - 1
    let col = CGFloat(idx % 7)
    let row = CGFloat(idx / 7)
    let cx = pad + col * cellW + cellW / 2
    let cy = gridTop + row * cellH + cellH / 2

    if day == todayDay {
        // today
        ctx.setFillColor(accent.cgColor)
        ctx.fillEllipse(in: CGRect(x: cx - 12, y: flip(cy) - 12, width: 24, height: 24))
        drawCentered("\(day)", x: pad + col * cellW, centerY: cy,
                     font: font(12, .bold), color: onAccent, width: cellW)
    } else {
        drawCentered("\(day)", x: pad + col * cellW, centerY: cy,
                     font: font(12, .regular), color: ink, width: cellW)
    }
}

// MARK: - Agenda

let sepY = gridTop + gridH + 8
ctx.setFillColor(edge.cgColor)
ctx.fill(CGRect(x: pad, y: flip(sepY), width: cardW - pad * 2, height: 1))

if events.isEmpty {
    drawCentered("Nothing scheduled", x: pad, centerY: sepY + 24,
                 font: font(11.5, .regular), color: faint, width: cardW - pad * 2, align: .left)
} else {
    for (i, ev) in events.enumerated() {
        let rowY = sepY + 26 + CGFloat(i) * agendaRowH
        // marker distinguishes next from later
        let isNext = (i == 0)
        ctx.setFillColor((isNext ? accent : faint).cgColor)
        ctx.fillEllipse(in: CGRect(x: pad + 1, y: flip(rowY) - 2.5, width: 5, height: 5))
        drawCentered(ev.time, x: pad + 13, centerY: rowY, font: font(11.5, .bold),
                     color: isNext ? ink : dim, width: 42, align: .left)
        drawCentered(ev.title, x: pad + 59, centerY: rowY, font: font(11.5, .regular),
                     color: isNext ? ink : dim, width: cardW - pad - 59 - 6, align: .left)
    }
}

NSGraphicsContext.restoreGraphicsState()

// MARK: - Write

let out = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : NSHomeDirectory() + "/.config/sketchybar/calendar/card.png"
if let png = repr.representation(using: .png, properties: [:]) {
    try? png.write(to: URL(fileURLWithPath: out))
    // path and point dimensions; the popup item sizes itself from these
    print("\(out) \(Int(cardW)) \(Int(cardH))")
}
