//
//  ViewController.swift
//  AutoShotFrameworkTestApp
//
//  Created by Tsutomu Yugi on 2019/12/29.
//  Copyright © 2019 Tsutomu Yugi. All rights reserved.
//

import UIKit
import WebKit

class ResultPageViewController: UIViewController {

    var html_string = ""
    @IBOutlet weak var resultWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let urlStr = "http://skin-analysis-api-test.s3-website-ap-northeast-1.amazonaws.com"
//        guard let url = URL(string: urlStr) else { return }
//        let request = URLRequest(url: url)
//        self.resultWebView.load(request)
        self.resultWebView.loadHTMLString(html_string, baseURL: nil)

    }

}
