// Developed by Ben Dodson (ben@bendodson.com)

import SwiftUI

@main
struct ReceiptsApp: App {
    
    @StateObject private var bluetoothMaster = BluetoothMaster()
    @Environment(\.openWindow) var openWindow
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothMaster)
                .onAppear {
                    bluetoothMaster.turnOn()
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(action: {
                    openWindow(id: "printer-scan")
                }, label: {
                    Text("Scan For Printers")
                })
                .keyboardShortcut("s", modifiers: .command)
            }
        }
        
        Window("Discovered Printers", id: "printer-scan") {
            PrinterScannerView()
                .environmentObject(bluetoothMaster)
        }
        
    }
}
