//
//  CGSize+KNKesher.swift
//  KesherDemo
//
//  Created by PETRUS VAN DE PUT on 21/12/14.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import UIKit

extension CGSize {
    
    func aspectFillSize(size: CGSize) -> CGSize {
        let scaleWidth = size.width / self.width
        let scaleHeight = size.height / self.height
        let scale = max(scaleWidth, scaleHeight)
        
        let resultSize = CGSizeMake(self.width * scale, self.height * scale)
        return CGSizeMake(ceil(resultSize.width), ceil(resultSize.height))
    }
    
    func aspectFitSize(size: CGSize) -> CGSize {
        let targetAspect = size.width / size.height
        let sourceAspect = self.width / self.height
        var resultSize = size
        
        if (targetAspect > sourceAspect) {
            resultSize.width = size.height * sourceAspect
        }
        else {
            resultSize.height = size.width / sourceAspect
        }
        return CGSizeMake(ceil(resultSize.width), ceil(resultSize.height))
    }
}
