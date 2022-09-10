//
//  AuthView.swift
//  GitHub-Headway
//
//  Created by Yevhenii Orenchuk on 08.09.2022.
//

import SwiftUI

struct AuthView: View {
    
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Button {
                viewModel.presentGitHubAuthorization()
            } label: {
                Text("Sign in with GitHub")
                    .bold()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.pink)
            .clipShape(Capsule(style: .continuous))
        }
        .padding(.horizontal, 44)
        .padding(.bottom, 64)
        .sheet(item: $viewModel.sheet) { sheet in
            switch sheet {
            case .github(let url):
                SafariWebView(url: url)
                    .ignoresSafeArea()
            }
        }
        .onOpenURL { url in
            viewModel.resolveDeeplink(url: url)
        }
    }
    
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView(viewModel: .mock)
    }
}
