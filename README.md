# Skin Analysi API Demo App
Included in this github are sample apps to use skin analysis api. Also this includes FaceAutoShot CocoaPods which is to take a face photo by back camera automatically.

# How to build and install App
#### 1. install FaceAutoShot framework
install FaceAutoShot framework from CocoaPods
```
pod install 
```

#### 2. open workspace
open `SkinAnalysisAPI_Demo.xcodeproj` which is crated after install pod.

#### 3. input build configuration
open project configuration menu via left side project navigator, then input your bundle identifier and provisioning profile.

#### 4. set SkinAnalysisAPI key
correct api key is needed to input in `PhotoPreviewPage.swift` because initial parameter in this file is dummy setting because this is seacret information.

```swift:PhotoPreviewPage.swift
    let api_header =  ["Content-Type": "application/json",
        "x-api-key": "input your api key here"]
```

#### 5. build project 
if you want to try to use face auto shot function, you have to connect iPhone device then build because iOS simulator doesn't support camera function.

# Detail explanation how to support SkinAnalysisAPI for your app
SkinAnalysisAPI can analysis face skin condition from face image only, then also this api will return result page with html file, so you don't need to make UI design by your own.

## API I/O specification

### Response

**basic**
|item|contents|
|----|----|
|http version|1.1|
|protocol|https|
|method|POST|

**header**
|item|contents|
|----|----|
|Content-Type|application/json|
|x-api-key|input your api key|

**body**
|item|type|contents|
|----|----|----|
|image|string|base64 encoded image file|
|device_type|string|iphone or android|
|device_code|string|device code to identify device|

### Response
**header**
|item|contents|
|----|----|
|Content-Type|application/html|

**response class: 200**
|item|contents|
|----|----|
|return|result page html file|

**response class: 4xx**
|item|contents|
|----|----|
|return|error page html file|

## SkinAnalysisAPI I/O sample implementation
you can find sample code in PhotoPreviewPage.swift, and also find how to display result page on webview in ResultPageViewController.swift. following code is pick up code.


**send api as POST**
```swift:PhotoPreviewPage.swift

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

```

**get api response**
```swift:PhotoPreviewPage.swift
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
```

# LICENSE
Licesen is under MIT, please check LICENSE file in details.




