//
//  TextInputStyle.swift
//  GroupLeader
//
//  Created by Gavin Normand on 7/18/26.
//

import SwiftUI

struct TextInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension View {
    func textInputStyle() -> some View {
        modifier(TextInputStyle())
    }
}
