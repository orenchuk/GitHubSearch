//
//  Binding+Extensions.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 09.09.2022.
//

import Foundation
import SwiftUI

extension Binding {
    
    func isPresent<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
        .init(
            get: { self.wrappedValue != nil },
            set: { isPresented in
                if !isPresented {
                    self.wrappedValue = nil
                }
            }
        )
    }
    
}

extension View {
    
    @ViewBuilder
    func alert<A: View, M: View, T: Identifiable>(
        title: (T) -> Text,
        presenting data: Binding<T?>,
        @ViewBuilder actions: @escaping (T) -> A,
        @ViewBuilder message: @escaping (T) -> M
    ) -> some View {
        self.alert(
            data.wrappedValue.map(title) ?? Text(""),
            isPresented: data.isPresent(),
            presenting: data.wrappedValue,
            actions: actions,
            message: message
        )
    }
    
}
