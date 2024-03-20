//
//  ContentView.swift
//  player
//
//  Created by Ilya on 09.04.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var audioPlayerViewModel = AudioPlayerViewModel()
       @StateObject var store = URLStore() 
       
       var body: some View {
           AudioPlayerView(store: store, audioPlayerViewModel: audioPlayerViewModel)
               .environmentObject(store)
       }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
