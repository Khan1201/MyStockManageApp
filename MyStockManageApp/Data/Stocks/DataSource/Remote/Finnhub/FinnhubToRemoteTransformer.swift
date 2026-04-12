import Foundation

struct FinnhubToRemoteTransformer: Sendable {
    func makeQuote(from quote: FinnhubQuoteDTO) -> StockQuoteRemoteModel {
        StockQuoteRemoteModel(
            currentPrice: quote.currentPrice,
            changePercent: quote.changePercent
        )
    }

    func makeProfile(from profile: FinnhubProfileDTO) -> StockProfileRemoteModel {
        StockProfileRemoteModel(
            name: profile.name,
            logoURL: profile.logoURL
        )
    }

    func makeRecommendation(from recommendation: FinnhubRecommendationDTO) -> StockRecommendationRemoteModel {
        StockRecommendationRemoteModel(
            buy: recommendation.buy,
            hold: recommendation.hold,
            period: recommendation.period,
            sell: recommendation.sell,
            strongBuy: recommendation.strongBuy,
            strongSell: recommendation.strongSell
        )
    }

    func makePriceTarget(from priceTarget: FinnhubPriceTargetDTO) -> StockPriceTargetRemoteModel {
        StockPriceTargetRemoteModel(
            targetHigh: priceTarget.targetHigh,
            targetLow: priceTarget.targetLow,
            targetMean: priceTarget.targetMean,
            targetMedian: priceTarget.targetMedian
        )
    }

    func makeSentimentArticle(from article: FinnhubNewsDTO) -> SentimentArticleRemoteModel {
        SentimentArticleRemoteModel(
            datetime: article.datetime,
            headline: article.headline,
            id: article.id,
            source: article.source,
            summary: article.summary
        )
    }

    func makeFinancialReport(from report: FinnhubFinancialReportDTO) -> FinancialReportRemoteModel {
        FinancialReportRemoteModel(
            filedDate: report.filedDate,
            quarter: report.quarter,
            revenueValue: report.report.incomeStatement.revenueValue,
            dilutedEPSValue: report.report.incomeStatement.dilutedEPSValue,
            year: report.year
        )
    }

    func makeEarningsHistory(from earnings: FinnhubEarningsHistoryDTO) -> EarningsHistoryRemoteModel {
        EarningsHistoryRemoteModel(
            actual: earnings.actual,
            estimate: earnings.estimate,
            quarter: earnings.quarter,
            year: earnings.year
        )
    }

    func makeEarningsCalendar(from earnings: FinnhubEarningsCalendarDTO) -> EarningsCalendarRemoteModel {
        EarningsCalendarRemoteModel(
            date: earnings.date,
            epsEstimate: earnings.epsEstimate,
            quarter: earnings.quarter,
            revenueEstimate: earnings.revenueEstimate,
            year: earnings.year
        )
    }
}
