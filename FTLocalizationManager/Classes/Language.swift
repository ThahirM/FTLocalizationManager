//
//  Language.swift
//  LocalizationHandler
//
//  Created by Abdulla Kunhi on 4/25/18.
//  Copyright © 2018 Abdulla Kunhi. All rights reserved.
//

import UIKit

enum Language: String {
    case english = "en"
    case arabic = "ar"
    case french = "fr"
    
    var locale: String {
        return rawValue
    }
    
    var title: String {
        switch self {
        case .english: return "English"
        case .arabic: return "Arabic"
        case .french: return "French"
        }
    }
    
    var isRTL: Bool {
        return self == .arabic
    }
    
    static func language(from code: String) -> Language {
        return Language(rawValue: code) ?? .english
    }
    
    static var all: [Language] {
        return [.english, .arabic, .french]
    }
}

extension Language {
    fileprivate struct Keys {
        static let preferred = "UserPreferedAppLanguage"
        static let device = "AppleLanguages"
    }
}

extension Language {
    /// current language if user has preferred one or the device language
    static var current: Language {
        get {
            guard let preferred = UserDefaults.standard.string(forKey: Keys.preferred) else {
                
                // save device language as preferred
                Language.current = Language.device
                
                return Language.device
            }
            
            return Language(rawValue: preferred) ?? .english
        }
        set {
            UserDefaults.standard.set(newValue.locale, forKey: Keys.preferred)
            UserDefaults.standard.synchronize()
            
            // update app for new language
            newValue.updateView()
        }
    }
    
    /// returns the device language. returns arabic if device language is arabic, else returns english
    static var device: Language {
        guard let deviceLanguages = UserDefaults.standard.object(forKey: Keys.device) as? [String],
            let deviceLanguage = deviceLanguages.first else { return .english }
       return Language(rawValue: deviceLanguage) ?? .english
    }
}

extension Language {
    fileprivate func updateView() {
        
        // update semanticContentAttribute
        UIView.appearance().semanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight

        restart()
    }
    
    private func restart() {
        guard let wrappedWindow = UIApplication.shared.delegate?.window else { return }
        guard let window = wrappedWindow else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        
        UIView.transition(with: window, duration: 0.6, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }
}