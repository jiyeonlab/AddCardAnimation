//
//  setCardGame.swift
//  AddCardAnimation
//
//  Created by JiyeonKim on 30/09/2019.
//  Copyright © 2019 JiyeonKim. All rights reserved.
//

import Foundation

struct SetCardGame {
    
    /// 전체 카드셋이 들어있는 배열. (총 81장)
    var cardDeck: Array<Card> = [Card]()
    
    /// 현재 화면에 보여지는 카드가 들어있는 배열
    var viewCards: Array<Card> = [Card]()
    
    /// 사용자가 선택한 카드가 들어있는 배열
    var checkCards: Array<Card> = [Card]()
    var matchingOK = false
    var deckHasMoreCard = true
    var score = 0
    
    init() {
        createCardDeck()
    } // init
    
    /// 게임에 필요한 총 81장의 카드셋을 만드는 초기화 작업
    mutating func createCardDeck() {
        
        viewCards = []
        cardDeck = []
        
        for shape in Card.Symbol.shapeAll {
            for color in Card.Color.colorAll {
                for count in Card.Count.countAll {
                    for opacity in Card.Opacity.opacityAll {
                        cardDeck.append(Card(isFaceUp: true, isMatched: false, suitSymbol: shape, suitColor: color, suitCount: count, suitOpacity: opacity))
                    }
                }
            }
        }
        
        createFirstViewCards()
    }
    
    /// 맨 처음에 보여줄 12장 카드배열을 생성하는 메소드. 초기 1번만 실행됨.
    mutating func createFirstViewCards() {
        for _ in 0..<12 {
            let rand = cardDeck.count.arc4random
            viewCards.append(cardDeck[rand])
            cardDeck.remove(at: rand)
        }
    }
    
    /// "more card" 버튼을 눌러, 3장의 카드를 더 보여줄 때 실행되는 메소드.
    mutating func moreCardAppend(){
        
        // deck에 남은 카드가 3장 이상 일 때만 가능.
        if cardDeck.count > 2 && deckHasMoreCard{
            for _ in 0..<3 {
                let rand = cardDeck.count.arc4random
                viewCards.append(cardDeck[rand])
                cardDeck.remove(at: rand)
            }
            deckHasMoreCard = true
            
            score -= 1
            
            if cardDeck.count == 0 {
                deckHasMoreCard = false
            }
        }
        
    }
    
    /// view에서 선택한 카드 3장이 matching인지 아닌지를 판단하는 메소드
    mutating func checkMatching(at clickNum: Array<Int>) -> Bool {
     
        for index in 0..<3 {
            checkCards.append(viewCards[clickNum[index]])
        }
        
        // 카드 3장의 property가 모두 다르거나 모두 같아야 매칭이기 때문에 중복을 허락하지 않는 Set에 넣어서 판단하기.
        let checkSymbol: Set = [checkCards[0].suitSymbol.rawValue, checkCards[1].suitSymbol.rawValue, checkCards[2].suitSymbol.rawValue]
        let checkColor: Set = [checkCards[0].suitColor.rawValue, checkCards[1].suitColor.rawValue, checkCards[2].suitColor.rawValue]
        let checkCount: Set = [checkCards[0].suitCount.rawValue, checkCards[1].suitCount.rawValue, checkCards[2].suitCount.rawValue]
        let checkOpacity: Set = [checkCards[0].suitOpacity.rawValue, checkCards[1].suitOpacity.rawValue, checkCards[2].suitOpacity.rawValue]
        
        matchingOK = ((checkSymbol.count == 1 || checkSymbol.count == 3) && (checkColor.count == 1 || checkColor.count == 3) && (checkCount.count == 1 || checkCount.count == 3) && (checkOpacity.count == 1 || checkOpacity.count == 3))
        
        if matchingOK{
            
            score += 3
            
            if deckHasMoreCard {
                // 카드 3장이 matching이면, viewcard의 그 자리에 cardDeck에서 새로 뽑아서 넣어준다.
                for index in 0..<3 {
                    checkCards[index].isMatched = true
                    let rand = cardDeck.count.arc4random
                    viewCards[clickNum[index]] = cardDeck[rand]
                    cardDeck.remove(at: rand)
                }
                
                if cardDeck.count == 0 {
                    deckHasMoreCard = false
                }
            }
            
            checkCards.removeAll()
            
        }else {
            score -= 5
            // 카드 3장이 matching이 아니면, checkCards 배열에서만 삭제한다.
            checkCards.removeAll()
        }
        
        // view에게 매칭 여부를 알려줌.
        return matchingOK
        
    }
    
    // view에서 rotation gesture 사용시, viewcards를 다시 섞어줌.
    mutating func cardRandomlyShuffle() {
        var tempCardView = viewCards
        //viewCards.removeAll()
        
        for index in tempCardView.indices {
            let rand = tempCardView.count.arc4random
            viewCards[index] = tempCardView[rand]
            tempCardView.remove(at: rand)
        }
        
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        }else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        }else {
            return 0
        }
    }
}

