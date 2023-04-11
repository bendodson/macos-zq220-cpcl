// Developed by Ben Dodson (ben@bendodson.com)

import SwiftUI
import CoreBluetooth

struct PrinterScannerView: View {
    
    @EnvironmentObject var bluetoothMaster: BluetoothMaster
    @State private var selectedPrinter: CBPeripheral?
    
    var body: some View {
        ZStack {
            if bluetoothMaster.printers.count > 0 {
                List {
                    
                    ForEach(bluetoothMaster.printers, id: \.self) { printer in
                        Label(printer.name ?? "", systemImage: "printer.filled.and.paper")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(printer == selectedPrinter ? 0.3 : 0.1))
                            .cornerRadius(4)
                            .onTapGesture(count: 2) {
                                bluetoothMaster.connect(to: printer)
                                NSApplication.shared.keyWindow?.close()
                            }
                            .simultaneousGesture(TapGesture().onEnded({
                                selectedPrinter = printer
                            }))
                    }
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

