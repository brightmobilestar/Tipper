//
//  KNBKErrors.swift
//  KNCoreBluetoothKit
//
//  Created by Jianying Shi on 2/5/15.
//  Copyright (c) 2014 Knodeit. All rights reserved.
//

import Foundation

public enum KNBKCharacteristicError : Int {
    case ReadTimeout        = 1
    case WriteTimeout       = 2
    case NotSerializable    = 3
    case ReadNotSupported   = 4
    case WriteNotSupported  = 5
}


public enum KNBKConnectoratorError : Int {
    case Timeout            = 10
    case Disconnect         = 11
    case ForceDisconnect    = 12
    case Failed             = 13
    case GiveUp             = 14
}

public enum KNBKPeripheralError : Int {
    case DiscoveryTimeout   = 20
    case Disconnected       = 21
}

public enum KNBKPeripheralManagerError : Int {
    case IsAdvertising      = 40
}

public struct KNBKError {
    public static let domain = "KNBKUtis"
    
    internal static let characteristicReadTimeout = NSError(domain:domain, code:KNBKCharacteristicError.ReadTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKCharacteristic read timeout"])
    internal static let characteristicWriteTimeout = NSError(domain:domain, code:KNBKCharacteristicError.WriteTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKCharacteristic write timeout"])
    internal static let characteristicNotSerilaizable = NSError(domain:domain, code:KNBKCharacteristicError.NotSerializable.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKCharacteristic not serializable"])
    internal static let characteristicReadNotSupported = NSError(domain:domain, code:KNBKCharacteristicError.ReadNotSupported.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKCharacteristic read not supported"])
    internal static let characteristicWriteNotSupported = NSError(domain:domain, code:KNBKCharacteristicError.WriteNotSupported.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKCharacteristic write not supported"])

    internal static let connectoratorTimeout = NSError(domain:domain, code:KNBKConnectoratorError.Timeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKConnectorator timeout"])
    internal static let connectoratorDisconnect = NSError(domain:domain, code:KNBKConnectoratorError.Disconnect.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKConnectorator disconnect"])
    internal static let connectoratorForcedDisconnect = NSError(domain:domain, code:KNBKConnectoratorError.ForceDisconnect.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKConnectorator forced disconnected"])
    internal static let connectoratorFailed = NSError(domain:domain, code:KNBKConnectoratorError.Failed.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKConnectorator connection failed"])
    internal static let connectoratorGiveUp = NSError(domain:domain, code:KNBKConnectoratorError.GiveUp.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKConnectorator giving up"])

    internal static let peripheralDisconnected = NSError(domain:domain, code:KNBKPeripheralError.DiscoveryTimeout.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKPeripheral disconnected timeout"])
    internal static let peripheralDiscoveryTimeout = NSError(domain:domain, code:KNBKPeripheralError.Disconnected.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKPeripheral discovery Timeout"])
        
    internal static let peripheralManagerIsAdvertising = NSError(domain:domain, code:KNBKPeripheralManagerError.IsAdvertising.rawValue, userInfo:[NSLocalizedDescriptionKey:"KNBKPeripheral Manager is Advertising"])

}

