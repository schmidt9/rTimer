//
//  Preferences.swift
//  rTimer
//
//  Created by Alexander Kormanovsky on 18.12.2022.
//

import Foundation

struct Preferences {
    
    private static let defaults: UserDefaults = {
        
        UserDefaults.standard.register(defaults: [
            "interval" : 5,
            "repetitionsCount" : 12,
            "delay" : 40,
            "soundName" : "Безмятежность.mp3",
            "playsSound" : true,
            "vibrates" : true
        ])
        
        return UserDefaults.standard
    }()
    
    static var interval: Int {
        get {
            defaults.integer(forKey: "interval")
        }
        
        set {
            defaults.set(newValue, forKey: "interval")
        }
    }
    
    static var repetitionsCount: Int {
        get {
            defaults.integer(forKey: "repetitionsCount")
        }
        
        set {
            defaults.set(newValue, forKey: "repetitionsCount")
        }
    }
    
    static var delay: Int {
        get {
            defaults.integer(forKey: "delay")
        }
        
        set {
            defaults.set(newValue, forKey: "delay")
        }
    }
    
    static var soundName: String {
        get {
            defaults.string(forKey: "soundName") ?? ""
        }
        
        set {
            defaults.set(newValue, forKey: "soundName")
        }
    }
    
    static var playsSound: Bool {
        get {
            defaults.bool(forKey: "playsSound")
        }
        
        set {
            defaults.set(newValue, forKey: "playsSound")
        }
    }
    
    static var vibrates: Bool {
        get {
            defaults.bool(forKey: "vibrates")
        }
        
        set {
            defaults.set(newValue, forKey: "vibrates")
        }
    }
    
}
