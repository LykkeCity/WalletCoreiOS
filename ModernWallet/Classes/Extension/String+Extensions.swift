//
//  String+Extensions.swift
//  ModernMoney
//
//  Created by Ivan Stoykov on 31.07.18.
//  Copyright © 2018 Lykkex. All rights reserved.
//

import Foundation

extension String {
    mutating func addCSSToHtml(html: String){
        self = """
        <style>
        body {
        font-size: 4.5vw;
        color: white;
        }
        a {
        color: #E4E4E4;
        }
        </style>
        """
        + html
    }
}
