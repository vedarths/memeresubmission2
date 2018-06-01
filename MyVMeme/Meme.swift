//
//  Meme.swift
//  MyVMeme
//
//  Created by Vedarth Solutions on 4/19/18.
//  Copyright © 2018 Vedarth Solutions. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText: String
    var bottomText: String
    let originalImage: UIImage
    let memedImage: UIImage
    
    var description: String {
        return "topText = \(self.topText), bottomText=\(self.bottomText), originalImage=\(self.originalImage), memedImage=\(self.memedImage)";
    }
}
