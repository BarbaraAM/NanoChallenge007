//
//  HomeView.swift
//  NanoChallenge007
//
//  Created by Henrique Assis on 03/02/23.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @State var gameDeck: ShuffleModel? = nil
    
    var body: some View {
        
        HStack{
            Button(action: {
                DeckUtils().getShuffle(completion: { (shuffle) in
                    self.gameDeck = shuffle
                })
            
            }, label: {
                Image(systemName: "play.fill")
            })
        }
        
    }
}

