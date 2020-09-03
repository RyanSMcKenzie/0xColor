//
//  Buttons.swift
//  0xColor
//
//  Created by Ryan McKenzie on 8/22/20.
//  Copyright © 2020 Ryan McKenzie. All rights reserved.
//

import Foundation
import SwiftUI

struct newButtonStyle: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.green, Color.blue]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 1:1.1)
            .animation(.easeInOut)
    }
}
