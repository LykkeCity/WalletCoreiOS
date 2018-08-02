//
//  CustomWebView.swift
//  ModernMoney
//
//  Created by Ivan Stoykov on 27.07.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import UIKit
import WebKit

class WebView: WKWebView {
    required init?(coder: NSCoder) {
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isOpaque = false
    }
}
