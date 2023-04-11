// Developed by Ben Dodson (ben@bendodson.com)

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var bluetoothMaster: BluetoothMaster
    
    @State private var text = ""
    
    var body: some View {
        VStack {
            
            if let printer = bluetoothMaster.connectedPrinter {
                
                ZStack {
                    Text("Connected to \(printer.name ?? "")")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    HStack {
                        Spacer()
                        Button("Print") {
                            guard !text.isEmpty else { return }
                            bluetoothMaster.print(text)
                        }
                        .keyboardShortcut("p", modifiers: .command)
                    }
                    .padding(.horizontal)
                }

                TextEditor(text: $text)
                    .font(.system(size: 20, weight: .semibold))
                    .background(Color.clear)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                
            } else if let printer = bluetoothMaster.selectedPrinter {
                Text("Connecting to \(printer.name ?? "")")
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Text("No printer connected")
            }
            
        }
        .padding()
    }
}
