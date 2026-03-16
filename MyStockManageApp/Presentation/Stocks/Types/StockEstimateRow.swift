import SwiftUI

struct StockEstimateRow: Identifiable {
    let id: String
    let yearText: String
    let stageText: LocalizedStringResource
    let stageColor: Color
    let revenueText: String
    let revenueDeltaText: String?
    let revenueDeltaColor: Color?
    let epsText: String
    let epsDeltaText: String?
    let epsDeltaColor: Color?
}
