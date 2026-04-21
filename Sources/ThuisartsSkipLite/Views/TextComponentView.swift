//
//  TextComponentView.swift
//  MiladThuisarts
//
//  Created by Milad Ahmad on 25/02/2026.
//
import Foundation
import SwiftUI

public struct TextComponentView: View {

    @State public private(set) var viewModel: TextComponentViewModel

    public init(viewModel: TextComponentViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        #if os(Android)
        Text(viewModel.text.content)
        #else
        let text = convertHTMLLinks(viewModel.text.content)
        Text(.init(text))
        #endif
    }
    #if !SKIP
    private func convertHTMLLinks(_ html: String) -> String {
        return html.replacingOccurrences(
            of: "<a\\s+[^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>",
            with: "[$2]($1)",
            options: .regularExpression
        )
    }
    #endif
}

//#Preview{
//    TabViews()
//}
