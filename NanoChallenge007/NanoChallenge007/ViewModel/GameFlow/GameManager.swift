//
//  GameManager.swift
//  NanoChallenge007
//
//  Created by Henrique Assis on 06/02/23.
//

import Foundation
import SwiftUI

public enum PlayerIds : Int {
    case p1 = 1
    case p2 = 2
    case none = 0
}

public class GameManager : ObservableObject {
    //MARK: VARS
    @Published var playerOne: PlayerHand
    @Published var playerTwo: PlayerHand
    @Published var deck: ShuffleModel
    
    var deckUtils: DeckUtils
    
    private var deckId: String
    private var startPlayer: PlayerIds
    private var roundNumber: Int
    
    //MARK: GETTERS SETTERS
    var StartPlayer: PlayerIds {
        get { return self.startPlayer }
    }
    
    var RoundNumber: Int {
        get { return self.roundNumber }
    }
    
    var DeckId: String {
        get { return self.deckId }
    }
    
    //MARK: INIT
    /**
     * Inicializa o game manager, já atribuindo os dois players e o player um começando a jogar na primeira rodada, além da rodada de número 1.
     */
    init(deckUtils: DeckUtils, completion: @escaping () -> ()) {
        self.playerOne = PlayerHand(id: PlayerIds.p1.rawValue)
        self.playerTwo = PlayerHand(id: PlayerIds.p2.rawValue)
        self.deckUtils = deckUtils
        self.startPlayer = .p1
        self.roundNumber = 1
        
        self.deck = ShuffleModel(success: false, deck_id: "", shuffled: false, remaining: 0)
        self.deckId = ""
        
        deckUtils.getShuffle { shuffle in
            self.deck = shuffle
            self.deckId = shuffle.deck_id
        }
    }
    
    //MARK: START ROUND
    /**
     * Começa o round, distribuindo 2 cartas para cada jogador, e já informando qual jogador começa a rodada
     */
    public func startRound(completion: @escaping () -> ()) {
        DispatchQueue.main.async {
            // distribui as 2 primeiras cartas para ambos os jogadores
            self.deckUtils.drawCard(deckId: self.deckId, drawCount: 2) { draw in
                self.playerOne.hand.append(contentsOf: draw.cards)
            }
            self.deckUtils.drawCard(deckId: self.deckId, drawCount: 2) { draw in
                self.playerTwo.hand.append(contentsOf: draw.cards)
            }
            
            // inicializa qual jogador comeca na rodada
            if self.roundNumber % 2 != 0 { self.startPlayer = .p1 } // se for round numero impar, comeca com o player 1
            else { self.startPlayer = .p2 } // se for round numero par, comeca com player 2
        }
    }
    
    //MARK: HIT
    public func hit(completion: @escaping () -> ()) {
        
    }
    
    //MARK: STAND
    public func stand(completion: @escaping () -> ()) {
        
    }
    
    //MARK: FINISH ROUND
    /**
     * Finaliza o round, resetando as cartas dos players, atribuindo o placar do vencedor, reembaralhando deck e aumentando o numero do round
     */
    public func finishRound(completion: @escaping () -> ()) {
        DispatchQueue.main.async {
            var winner = PlayerIds.none
            let isDraw = self.checkDraw()
            
            // checa se empatou e da o vencedor
            if !isDraw { winner = self.checkWinner() }
            
            // atribui o vencedor se nao tiver dado empate
            if winner == .p1 { self.playerOne.score += 1 }
            else if winner == .p2 { self.playerTwo.score += 1 }
            
            // reembaralhando cartas
            self.deckUtils.getReshuffle(deckId: self.deckId) { reshuffle in
                self.deck = reshuffle
            }
            
            // aumentando numero do round
            self.roundNumber += 1
            
            // resetando maos dos jogadores
            self.playerOne.hand = []
            self.playerTwo.hand = []
        }
    }
    
    private func checkDraw() -> Bool {
        // dois estouram
        if playerOne.score > 21 && playerTwo.score > 21 { return true }
        // dois igualam
        else if playerOne.score == playerTwo.score { return true }
        // nao empata
        else { return false }
    }
    
    private func checkWinner() -> PlayerIds {
        // p1 ganha
        if (self.playerOne.score > self.playerTwo.score && self.playerOne.score <= 21) || self.playerTwo.score > 21 { return .p1 }
        else { return .p2 }
    }
}
