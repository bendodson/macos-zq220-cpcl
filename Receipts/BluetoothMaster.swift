// Developed by Ben Dodson (ben@bendodson.com)

import Foundation
import CoreBluetooth

class BluetoothMaster: NSObject, ObservableObject {
    
    static let zebraPrinterUUID = CBUUID(string: "38EB4A80-C570-11E3-9507-0002A5D5C51B")
    static let zebraPrinterWriteCharacteristic = CBUUID(string: "38EB4A82-C570-11E3-9507-0002A5D5C51B")
    
    @Published var printers = [CBPeripheral]()
    @Published var selectedPrinter: CBPeripheral?
    @Published var connectedPrinter: CBPeripheral?
    @Published var writingCharacteristic: CBCharacteristic?
    
    private var centralManager: CBCentralManager!
    
    func turnOn() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func connect(to printer: CBPeripheral) {
        selectedPrinter = printer
        centralManager.connect(printer)
    }
    
    func print(_ text: String) {
        guard let connectedPrinter, let writingCharacteristic else { return }
        guard let data = (text + "\r\n").data(using: .utf8) else { return }
        connectedPrinter.writeValue(data, for: writingCharacteristic, type: .withResponse)
    }
    
    private func scan() {
        printers = []
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
}

extension BluetoothMaster: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            scan()
        default:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name?.trimmingCharacters(in: .whitespaces), !name.isEmpty else { return }
        guard name.hasPrefix("XXZSV") else { return }
        guard !printers.contains(peripheral) else { return }
        printers.append(peripheral)
    }
}

extension BluetoothMaster: CBPeripheralDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPrinter = peripheral
        centralManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([BluetoothMaster.zebraPrinterUUID])
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else { return }
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics([BluetoothMaster.zebraPrinterWriteCharacteristic], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else { return }
        writingCharacteristic = service.characteristics?.filter({ $0.uuid == BluetoothMaster.zebraPrinterWriteCharacteristic }).first
    }
}
