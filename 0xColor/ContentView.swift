//
//  ContentView.swift
//  0xColor
//
//  Created by Ryan McKenzie on 8/22/20.
//  Copyright © 2020 Ryan McKenzie. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    // State variables for red, green, blue slider
    @State var redSliderValue: Double = 0.00
    @State var greenSliderValue: Double = 0.00
    @State var blueSliderValue: Double = 0.00
    
    // State variable for hex alert
    @State var hexShown: Bool = false
    @State var saveShown = false
    
    @State var savedColors = [ColorSave]()
    @State var nav: Int? = 0

    struct sliderStyle: ViewModifier {
        //Basic slider styling struct, in case styling needs to be changed en masse
        func body(content: Content) -> some View {
            return content
                .shadow(color: Color.black, radius: 4)
            .padding()
        }
    }
    var body: some View {
        NavigationView {
            VStack {

                // Main VStack contains 3 sliders, one for each RGB color
                Spacer()
                HStack {

                    Spacer()
                    Slider(value: self.$redSliderValue, in: 0...255).accentColor(Color.red)
                        .modifier(sliderStyle()).padding(.top, 100)
                    Spacer()

                }
                Spacer()
                    
                HStack {
                    Spacer()
                    Slider(value: self.$greenSliderValue, in: 0...255).accentColor(Color.green)
                        .modifier(sliderStyle())
                    Spacer()
                }
                Spacer()
                    
                HStack {
                    Spacer()
                    Slider(value: self.$blueSliderValue, in: 0...255).accentColor(Color.blue)
                        .modifier(sliderStyle())
                    Spacer()
                }
                Spacer()
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        self.hexShown = true
                    }) {
                        Text("Get Hex")
                            .multilineTextAlignment(.center)
                        }.buttonStyle(newButtonStyle())
                        .alert(isPresented: self.$hexShown) { () -> Alert in
                            // Button alert action displays hexadecimal value for current color
                        return Alert(title: Text("Hexadecimal"), message: Text("Your color's hex is \(self.getHex(red: Int(self.redSliderValue), green: Int(self.greenSliderValue), blue: Int(self.blueSliderValue)))"), dismissButton: .default(Text("Done")))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.saveShown = true
                        // Button enables CoreData saving of hexCode, rbg values
                        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                        let newColor = ColorSave(context: context)
                        newColor.red = Int16(self.redSliderValue)
                        newColor.blue = Int16(self.blueSliderValue)
                        newColor.green = Int16(self.greenSliderValue)
                        newColor.redFraction = self.redSliderValue/255.0
                        newColor.blueFraction = self.blueSliderValue/255.0
                        newColor.greenFraction = self.greenSliderValue/255.0
                        newColor.hexCode = self.getHex(red: Int(self.redSliderValue), green: Int(self.greenSliderValue), blue: Int(self.blueSliderValue))
                        
                        self.savedColors.append(newColor)
                        do {
                            try context.save()
                        } catch {
                            print("Save error")
                        }
                    }) {
                        Text("Save Color")
                            .multilineTextAlignment(.center)
                        }.buttonStyle(newButtonStyle())
                        .alert(isPresented: self.$saveShown) { () -> Alert in
                            return Alert(title: Text("Color Saved"), message: Text(""), dismissButton: .default(Text("Done")))
                    }
                    
                    Spacer()
                    Button(action: {
                        // Button navigates to saved colors pane
                        self.nav = 1
                    }) {
                        Text("Saved Colors")
                        }.buttonStyle(newButtonStyle())
                

                    NavigationLink(destination: saveView(colors: getSavedColors(),redSliderValue: self.$redSliderValue, greenSliderValue: self.$greenSliderValue, blueSliderValue: self.$blueSliderValue), tag: 1, selection: $nav) {
                        Text("").navigationBarTitle("0xColor", displayMode: .inline).navigationBarBackButtonHidden(true)
                    }

                    
                    Spacer()
                }
                
                Spacer()
                //Dynamic background color changing
            }.background(Color.init(red: self.redSliderValue / 255.0,
            green: self.greenSliderValue / 255.0,
            blue: self.blueSliderValue / 255.0))
        }
    }
    
    func getHex(red: Int, green: Int, blue: Int) -> String {
        // getHex function returns hexadecimal string for current color selected
        var out: String = "0x"
        out += String(format: "%02x", red).uppercased()
        out += String(format: "%02x", green).uppercased()
        out += String(format: "%02x", blue).uppercased()
        return out
    }
    
    func getSavedColors() -> [ColorSave] {
        // getSavedColors fills all none-empty color objects for rendering to list
        let request: NSFetchRequest<ColorSave> = ColorSave.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var savedColors = [ColorSave]()
        do {
            savedColors = try context.fetch(request)
        } catch {
            print("Error fetching \(error)")
        }
        return savedColors
    }

    struct saveView: View {
        // saveView renders all saved colors to the list
        @State var colors = [ColorSave]()
        @Environment(\.presentationMode) var presentation
        @Binding var redSliderValue: Double
        @Binding var greenSliderValue: Double
        @Binding var blueSliderValue: Double
        
        var body: some View {
                VStack{
                    List {
                        ForEach(colors, id: \.hexCode) { color in
                            HStack {
                                Text("\(color.hexCode ?? "")")
                                Rectangle()
                                    .fill(Color.init(red: color.redFraction,
                                                     green: color.greenFraction,
                                                     blue: color.blueFraction))
                                    .frame(width: 40, height: 40)
                                Button("") {
                                    // Selecting a color resets mainscreen, dismisses save screen
                                    self.$redSliderValue.wrappedValue = color.redFraction * 255.0
                                    self.$greenSliderValue.wrappedValue = color.greenFraction * 255.0
                                    self.$blueSliderValue.wrappedValue = color.blueFraction * 255.0
                                    self.presentation.wrappedValue.dismiss()
                                }
                            }
                        }.onDelete(perform: removeRow)
                    }
                }
            }
        
        func removeRow(at offsets: IndexSet) {
            // removeRow removes the specified row to delete from the list
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            var cols = self.colors
            for index in offsets {
                let col = cols[index]
                context.delete(col)
                cols.remove(at: index)
            }
            do {
                try context.save()
            } catch {
                print("Whoops")
            }
            self.colors = cols
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
