//
//  DoOnDataLoadedWatchImpl.swift
//  MyPV WatchKit Extension
//
//  Created by Artur Hellmann on 20.09.22.
//

import Foundation
import ClockKit

class DoOnDataLoadedImpl: DoOnDataLoaded {

    func doOnDataLoaded() {
        let server = CLKComplicationServer.sharedInstance()

        server.activeComplications?.forEach({ complication in
            server.reloadTimeline(for: complication)
        })

        server.reloadComplicationDescriptors()
    }

}
