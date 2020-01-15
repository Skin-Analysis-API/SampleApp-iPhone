//
//  ViewController.swift
//  AutoShotFrameworkTestApp
//
//  Created by Tsutomu Yugi on 2019/12/29.
//  Copyright © 2019 Tsutomu Yugi. All rights reserved.
//

import UIKit
import FaceAutoShot

class PhotoPreviewPage: UIViewController,FaceAutoShotDelegate {
    
    var activityIndicatorView = UIActivityIndicatorView()
    var image_data:Data?
    let api_header =  ["Content-Type": "application/json",
                    "x-api-key": "here is api key"]
    let api_url =  "https://l3p6lrnf73.execute-api.ap-northeast-1.amazonaws.com/dev/result"
    
    
    @IBOutlet weak var previewImage: UIImageView!

    // CameraViewDelegate protocol implementation
    var output_path:String?
    func getResult(ret: Bool, path: String?) {
        if ret && path != nil{
            self.output_path = path
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // activity indicator
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .whiteLarge
        activityIndicatorView.color = .white
        view.addSubview(activityIndicatorView)
        
        
        guard let _output_path = self.output_path else{
            return
        }
        
        var url:URL?
        if !_output_path.contains("file:///"){
            // 自動撮影から遷移してきた場合
            print("contain Documents folder")
            guard let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
                print("failed to get documentDirectory")
                return
            }
            url = NSURL(fileURLWithPath: documentDirectory).appendingPathComponent(_output_path)
        }else{
            // ライブラリ選択から遷移してきた場合
            url = URL(string: _output_path)
        }

        do {
            image_data = try Data(contentsOf: url!)
            
        }catch let err {
            print("Error : \(err.localizedDescription)")
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showPhoto()
        
    }
    
    func showPhoto(){
        guard let _image_data = self.image_data else{
            return
        }
        previewImage.image = UIImage(data: _image_data)
        
    }
    
    @IBAction func btnResultPage(_ sender: Any) {
        
        activityIndicatorView.startAnimating()
        fileUpload() {(data, response, error) in
            if let _response = response as? HTTPURLResponse, let _: Data = data , error == nil {
                if _response.statusCode != 200 {
                    return
                }
                
                guard let _data = data else{
                    return
                }
                guard let html_string = String(data:_data, encoding: .utf8) else{
                    return
                }
                DispatchQueue.main.async {
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    let storyboardResult = UIStoryboard(name: "ResultPage", bundle:Bundle(for: ResultPageViewController.self))
                    let viewController = storyboardResult.instantiateViewController(withIdentifier: "ResultPageID") as! ResultPageViewController
                    viewController.html_string = html_string
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }

    }
    
    func fileUpload(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        guard let _image_data = self.image_data else{
            return
        }
        
        // set image data into http body
        let image_base64 = _image_data.base64EncodedString()

        let json_data:[String:Any] = [
            "image": image_base64,
            "device_type": "iphone",
            "device_code": Utilities.getDeviceCode()]

        let http_body = try! JSONSerialization.data(withJSONObject: json_data)

        // set url request
        var request = URLRequest(url: URL(string: self.api_url)!)
        request.httpMethod = "POST"

        // set url config
        let urlConfig = URLSessionConfiguration.default
        urlConfig.httpAdditionalHeaders = self.api_header
        urlConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        urlConfig.urlCache = nil
        
        // session start
        let session = Foundation.URLSession(configuration: urlConfig)
        let task = session.uploadTask(with: request, from: http_body, completionHandler: completionHandler)
        task.resume()
    }


}
