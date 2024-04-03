//
//  IBeaconManager.swift
//  geber
//
//  Created by mac.bernanda on 03/04/24.
//

import Foundation
import CoreLocation
import Combine

class IBeaconManager : NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var distance : CLProximity
    @Published var minor : Int
    @Published private (set) var permissionGranted = false
    
    private (set) var exists = PassthroughSubject<Void, Never>()
    private let locationManager = CLLocationManager()
    
    override init() {
        distance = .unknown
        minor = -1
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            publish(permissionGranted: true)
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startMonitoring()
                }
                
                return
            }
        }
        
        publish(permissionGranted: false)
    }
    
    func publish(permissionGranted: Bool) {
        DispatchQueue.main.async {
            self.permissionGranted = permissionGranted
        }
    }
    
    func startMonitoring() {
        let uuid = UUID(uuidString: EnvManager.shared.BEACON_UUID)!
        let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid, major: 0)
        let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint, identifier: "Parkiran")
    
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: beaconConstraint)
    }
    
    func update(distance: CLProximity, minor: NSNumber) {
        self.distance = distance
        self.minor = Int(truncating: minor)
        exists.send(())
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown && [0, 1, 2].contains($0.minor)}
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons [0] as CLBeacon
            update(distance: closestBeacon.proximity, minor: closestBeacon.minor)
            return
        }
        
        update(distance: .unknown, minor: -1)
    }
    
}
