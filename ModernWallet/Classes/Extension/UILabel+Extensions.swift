//
//  UILabel+Extensions.swift
//  ModernMoney
//
//  Created by Georgi Stanev on 11.05.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import Foundation

extension UILabel {
    func setHTML(html: String) {
        do {
            let at : NSAttributedString = try NSAttributedString(data: html.data(using: .utf8)!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil);
            self.attributedText = at;
        } catch {
            self.text = html;
        }
    }
}
