////
////  Home.swift
////  Impulsum
////
////  Created by robert theo on 09/10/24.
////
//
//import SwiftUI
//
//struct HomeView: View {
//    @StateObject private var vm = HomeViewModel()
//    
//    var body: some View {
//        List {
//            ForEach(vm.materials, id:  \.self.id) { material in
//                Text(material.name)
//                AsyncImage(url: material.imageURL)
//            }
//        }
//    }
//}
//
//#Preview {
//    HomeView()
//}

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    
    var body: some View {
        List {
            ForEach(vm.materials, id:  \.self.id) { material in
                Text("\(material.imageURL)").onAppear {
                    print(material.imageURL)
                }
                AsyncImage(url: material.imageURL)
            }
        }
    }
}

#Preview {
    HomeView()
}
