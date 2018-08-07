//
//  PopMenuHelper.swift
//  iTunesCodingChallenge
//
//  Created by Caleb Rudnicki on 7/27/18.
//  Copyright © 2018 Caleb Rudnicki. All rights reserved.
//

import Foundation
import PopMenu

enum MovieOptions {
    case top10
    case top25
    case top50
    case top100
}

class PopMenuHelper {
    
    let top10Action = PopMenuDefaultAction(title: "Top 25", didSelect: { action in
        UserDefaults.standard.set(10, forKey: "numberOfMovies")
    })
    let top25Action = PopMenuDefaultAction(title: "Top 25", didSelect: { action in
        UserDefaults.standard.set(25, forKey: "numberOfMovies")
    })
    let top50Action = PopMenuDefaultAction(title: "Top 50", didSelect: { action in
        UserDefaults.standard.set(50, forKey: "numberOfMovies")
    })
    let top100Action = PopMenuDefaultAction(title: "Top 100", didSelect: { action in
        UserDefaults.standard.set(100, forKey: "numberOfMovies")
    })
    
    func presentNumberOptions() -> [PopMenuDefaultAction] {
        var list: [PopMenuDefaultAction] = [top10Action, top25Action, top50Action, top100Action]
        if let numberDefault = UserDefaults.standard.object(forKey: "numberOfMovies") as? Int {
            switch numberDefault {
            case 10:
                list.remove(at: 0)
            case 25:
                list.remove(at: 1)
            case 50:
                list.remove(at: 2)
            case 100:
                list.remove(at: 3)
            default:
                fatalError("Incorrect movie count")
            }
        }
        return list
    }
    
    func translateNumberOptionsForTitle() -> String {
        if let numberDefault = UserDefaults.standard.object(forKey: "numberOfMovies") as? Int {
            switch numberDefault {
            case 10:
                return "Top 10"
            case 25:
                return "Top 25"
            case 50:
                return "Top 50"
            case 100:
                return "Top 100"
            default:
                fatalError("Incorrect movie count")
            }
        }
        return ""
    }
    
}
