//
//  MyStockManageAppApp.swift
//  MyStockManageApp
//
//  Created by 윤형석 on 3/7/26.
//

import SwiftUI

@main
struct MyStockManageAppApp: App {
    private let appDependencyContainer = AppDependencyContainer()

    var body: some Scene {
        WindowGroup {
            TabContainerView(
                tradeHistoryViewModel: appDependencyContainer.makeTradeHistoryViewModel()
            )
        }
    }
}
