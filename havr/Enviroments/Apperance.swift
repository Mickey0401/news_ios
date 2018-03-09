//
//  Apperance.swift
//  havr
//
//  Created by Personal on 4/26/17.
//  Copyright © 2017 Tenton LLC. All rights reserved.
//

import UIKit



class Apperance: NSObject {
    
    
    static var appBlueColor = UIColor(red255: 4, green255: 128, blue255: 229)
    static var textGrayColor = UIColor(red255: 192, green255: 197, blue255: 204)
    static var redColor = UIColor(red255: 226, green255: 104, blue255: 118)
    static var E5E5E5Color = UIColor(red255: 229, green255: 229, blue255: 229)
    static var B1B1B1Color = UIColor(red255: 177, green255: 177, blue255: 177)
    static var F8F8F8Color = UIColor(red255: 143, green255: 143, blue255: 143)
    static var B5B5B5Color = UIColor(red255: 181, green255: 181, blue255: 181)
    static var appGreenColor = UIColor(red255: 36, green255: 189, blue255: 64)
    static var EFEFEFColor = UIColor(red255: 239, green255: 239, blue255: 239)
    static var navTintColor = UIColor(red255: 251, green255: 250, blue255: 250)
    
    static func setup() {
        let nav = UINavigationBar.appearance()
        nav.barStyle = .default
        //nav.barTintColor = UIColor(red255: 251, green255: 250, blue255: 250)
        UINavigationBar.appearance().barTintColor = Apperance.navTintColor
//        nav.barTintColor = UIColor.selectedDirtyBlue
        nav.tintColor = .black
        nav.backgroundColor = .white
        nav.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        nav.shadowImage = UIImage()
        
        if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                NSFontAttributeName: UIFont.helveticaRegualr(30),
                NSForegroundColorAttributeName: UIColor.black ]
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.latoRegular(15), NSForegroundColorAttributeName: UIColor.black]

        } else {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont.latoRegular(15), NSForegroundColorAttributeName: UIColor.black]
        }
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.helveticaRegualr(17)], for: .normal)
        UIApplication.shared.statusBarStyle = .default
//        nav.isTranslucent = false
        
        let barAppearance = UIBarButtonItem.appearance()
        barAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, 0), for:UIBarMetrics.default)
 
//
//        nav.backIndicatorImage = #imageLiteral(resourceName: "back icon")
//        nav.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "back icon")
    }
}

extension UIFont {
    fileprivate static var fontFor: (_ name: String, _ size: CGFloat) -> UIFont = { fontName, size in
        guard let font = UIFont(name: fontName, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    static var navigationTitleFont = UIFont.sfProDisplayMediumFont(16)
    
    static var helveticaRegualr: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("Helvetic-Regular", size)
    }
    
    static var helveticaBold: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("Helvetica-Bold", size)

    }
    
    static var latoRegular: (CGFloat) -> UIFont = { size in //16
        return UIFont.fontFor("Lato-Regular", size)
    }
    
    static var latoMedium: (CGFloat) -> UIFont = { size in //14
        return UIFont.fontFor("Lato-Medium", size)
    }
    
    static var robotoRegularFont: (CGFloat) -> UIFont = { size in //16
        return UIFont.fontFor("Roboto-Regular", size)
    }
    
    static var robotoMediumFont: (CGFloat) -> UIFont = { size in //16
        return UIFont.fontFor("Roboto-Medium", size)
    }
    
    static var robotoBoldFont: (CGFloat) -> UIFont = { size in //16
        return UIFont.fontFor("Roboto-Bold", size)
    }
    
    static var ptSansBoldFont: (CGFloat) -> UIFont = { size in //12
        return UIFont.fontFor("PTSANSB", size)
    }
    
     //SF Pro Display
    static var sfProDisplayHeavyItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-HeavyItalic", size)
    }

    static var sfProDisplayThinItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-ThinItalic", size)
    }

    static var sfProDisplayUltralightFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Ultralight", size)
    }

    static var sfProDisplayHeavyFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Heavy", size)
    }

    static var sfProDisplayBoldItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-BoldItalic", size)
    }

    static var sfProDisplaySemiboldItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-SemiboldItalic", size)
    }

    static var sfProDisplayRegularFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Regular", size)
    }

    static var sfProDisplayBoldFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Bold", size)
    }

    static var sfProDisplayMediumItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-MediumItalic", size)
    }

    static var sfProDisplayThinFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Thin", size)
    }

    static var sfProDisplaySemiboldFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Semibold", size)
    }

    static var sfProDisplayBlackItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-BlackItalic", size)
    }

    static var sfProDisplayLightFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Light", size)
    }

    static var sfProDisplayUltralightItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-UltralightItalic", size)
    }

    static var sfProDisplayItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Italic", size)
    }

    static var sfProDisplayLightItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-LightItalic", size)
    }

    static var sfProDisplayBlackFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Black", size)
    }

    static var sfProDisplayMediumFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProDisplay-Medium", size)
    }
     
//     SF Pro Text
    static var sfProTextHeavyFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-Heavy", size)
    }

    static var sfProTextLightItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-LightItalic", size)
    }

    static var sfProTextHeavyItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-HeavyItalic", size)
    }

    static var sfProTextMediumFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-Medium", size)
    }

    static var sfProTextItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-Italic", size)
    }

    static var sfProTextBoldFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-Bold", size)
    }

    static var sfProTextSemiboldItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-SemiboldItalic", size)
    }

    static var sfProTextLightFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-Light", size)
    }

    static var sfProTextMediumItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-MediumItalic", size)
    }

    static var sfProTextBoldItalicFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-BoldItalic", size)
    }

    static var sfProTextRegularFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-Regular", size)
    }
    
    static var sfProTextSemiboldFont: (CGFloat) -> UIFont = { size in
        return UIFont.fontFor("SFProText-Semibold", size)
    }
}

