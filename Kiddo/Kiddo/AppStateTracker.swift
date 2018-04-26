//
//  AppStateTracker.swift
//  Kiddo
//
//  Created by Filiz Kurban on 4/17/18.
//  Copyright © 2018 Filiz Kurban. All rights reserved.
//

import Foundation

struct AppStateTracker {
    enum State {
        case appWillEnterForegroundFromLocallySpawnedProcess(ProcessName)
        case appWillEnterForegroundFromLongInactivity
        case appInNonTransitionalState
    }

    var state: State
}

extension AppStateTracker {
    enum ProcessName {
        case Settings
        case FacebookLogin
        case Maps
        case Browser
    }
}
