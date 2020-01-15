//
//  ViewController.swift
//  AutoShotFrameworkTestApp
//
//  Created by Tsutomu Yugi on 2019/12/29.
//  Copyright © 2019 Tsutomu Yugi. All rights reserved.
//

import UIKit
import FaceAutoShot 
import AVFoundation
import Photos

// STEP1: 自動撮影後にこのViewControllerに戻す場合にはCameraViewDelegateを継承する
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
                    , FaceAutoShotDelegate {


    var picker: UIImagePickerController! = UIImagePickerController()
    
    @IBOutlet var disableAutoShotView: UIView!
    @IBOutlet var disableLibraryView: UIView!

    @IBOutlet var cameraAuthLabel: UILabel!
    @IBOutlet var folderAuthLabel: UILabel!
    
    // STEP2: CameraViewDelegateを継承した場合には、getResultメソッドを実装する
    //        getResultメソッドの引数にはfreamework内で撮影された画像のファイルパスがstringで格納されている
    var output_path:String?
    func getResult(ret: Bool, path: String?) {
        if ret && path != nil{
            self.output_path = path
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // STEP3: framework内でカメラへのアクセスとDocumentsフォルダへの書き込みを行なっているため
        //        カメラへのアクセス許可とフォルダへの書き込み許可のチェックを行う
        checkAuthorization()
        
        // OPTION: info.plist 内で NSPhotoLibraryAddUsageDescriptionとNSCameraUsageDescriptionが
        //         定義されているかを確認する。確実に定義されている場合には必要ない
        let info_plist = Bundle.main.infoDictionary! as Dictionary
        guard let _ = info_plist["NSPhotoLibraryAddUsageDescription"] else{
            print("photo library access error")
            return
        }
        guard let _ = info_plist["NSCameraUsageDescription"] else{
            print("camera access error")
            return
        }

    }
    
    // STEP 4: AutoShotFrameworkへのアクセス
    @IBAction func btnAutoShot(_ sender: UIButton) {

        // STEP 4-1: AutoShotFramework内で定義されているカメラプレビュー用のview を立ち上げる
        //           class名: CameraViewController
        //           storyboardファイル名: CameraMain.storyboard
        //           storyboard ID: CameraMainID
        let bundle = Bundle(for: FaceAutoShotViewController.self)
        let storyboard = UIStoryboard(name: "FaceAutoShot", bundle:bundle)
        let viewController = storyboard.instantiateViewController(withIdentifier: "FaceAutoShotID") as! FaceAutoShotViewController
        
        
        // STEP 4-2: CameraViewController.nextView に 自動撮影後に遷移するviewを設定する
        //           このデモでは PhotoPreviewPage.storyboard / PhotoPreviewPage.swiftに遷移するように設定している
        //           もしnilを設定した場合には、現在のviewに戻る
        let storyboardResult = UIStoryboard(name: "PhotoPreviewPage", bundle:Bundle(for: PhotoPreviewPage.self))
        viewController.nextView = storyboardResult.instantiateViewController(withIdentifier: "PhotoPreviewID") as! PhotoPreviewPage
//        viewController.nextView = nil
        
        // STEP 4-3: CameraViewDelegateの通知先を設定する
        //           STEP 4-2で撮影後の遷移先を設定した場合には、そのviewを設定する
        //           STEP 4-2でnilを設定した場合には、selfを設定する
        viewController.delegate = viewController.nextView as? FaceAutoShotDelegate
//        viewController.delegate = self // selfにセットすると自分にかえってくる

        // OPTION: 撮影結果を格納するDocuments/*** フォルダを指定する。指定しない場合にはDocuments/outputに保存される
        //        viewController.output_dir = "test"

        // OPTION: framework内のプレビュー画面のナビゲーションバーに表示される戻るボタンのスタイルを設定する
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)



        // STEP 4-4: navigationControllerを使って遷移する。引数にはSTEP 4-1で取得したview controllerを設定する
        self.navigationController?.pushViewController(viewController, animated: true)

    }
    
    
    
    //************************** 以下はデモページ用のオプション***************************//
    
    @IBAction func btnLibrarySelect(_ sender: Any) {
        
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.delegate = self
        picker.navigationBar.tintColor = UIColor.white
        picker.navigationBar.barTintColor = UIColor.gray
        present(picker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image_url = info[.imageURL] as! NSURL

        let storyboardResult = UIStoryboard(name: "PhotoPreviewPage", bundle:Bundle(for: PhotoPreviewPage.self))
        let viewController = storyboardResult.instantiateViewController(withIdentifier: "PhotoPreviewID") as! PhotoPreviewPage
        viewController.output_path = image_url.absoluteString
        
        self.navigationController?.pushViewController(viewController, animated: true)

        self.dismiss(animated: true, completion: nil)

    }
    
    func checkAuthorization(){
        
        checkCameraAuthorization()
        checkFolderWriteAuthorization()
        
    }
    
    func checkCameraAuthorization(){
        
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            print("folder write access authorized")

        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    DispatchQueue.main.async{
                        self.disableAutoShotView.isHidden = false
                        self.cameraAuthLabel.isHidden = false
                        print("camera access denied")
                    }
                }

            }
        case .denied: // The user has previously denied access.
            print("camera access denied")
            self.disableAutoShotView.isHidden = false
            self.cameraAuthLabel.isHidden = false

        case .restricted: // The user can't grant access due to restrictions.
            print("camera access rejected")
            self.disableAutoShotView.isHidden = false
            self.cameraAuthLabel.isHidden = false

        }
        
    }
    
    func checkFolderWriteAuthorization(){
        
        
        switch PHPhotoLibrary.authorizationStatus(){
        
        case .authorized:
            print("folder write access authorized")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization{status in
                if status != .authorized{
                    DispatchQueue.main.async{
                        print("folder write access denied")
                        self.disableAutoShotView.isHidden = false
                        self.folderAuthLabel.isHidden = false
                    }
                }
            }
        case .restricted:
            print("folder write access denied")
            self.disableAutoShotView.isHidden = false
            self.folderAuthLabel.isHidden = false
        case .denied:
            print("folder write access rejected")
            self.disableAutoShotView.isHidden = false
            self.folderAuthLabel.isHidden = false
        }
    
    }

}

