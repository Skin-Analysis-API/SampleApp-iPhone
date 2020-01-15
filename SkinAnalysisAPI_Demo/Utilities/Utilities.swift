//
//  Utilities.swift
//  CameraForSampling
//
//  Created by Tsutomu Yugi on 2019/12/25.
//  Copyright © 2018年 Sony Network Communications Inc. All rights reserved.
//

import UIKit

class Utilities: NSObject {

    class func getDeviceCode() -> String{

        var size : Int = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)

        return String(cString:machine)

    }


}
