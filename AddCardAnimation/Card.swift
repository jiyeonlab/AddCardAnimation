//
//  Card.swift
//  AddCardAnimation
//
//  Created by JiyeonKim on 30/09/2019.
//  Copyright © 2019 JiyeonKim. All rights reserved.
//

import Foundation


struct Card: CustomStringConvertible, Hashable, Equatable {
    
    var description: String {
        return "\(suitSymbol)\(" ")\(suitColor)\(" ")\(suitCount)\(" ")\(suitOpacity)"
    }
    
    var isFaceUp = true
    var isMatched = false
    
    var suitSymbol: Symbol
    var suitColor: Color
    var suitCount: Count
    var suitOpacity: Opacity
    
    enum Symbol: Int, Hashable {
        
        case squiggle
        case diamond
        case oval
        
        static var shapeAll = [Symbol.squiggle, .diamond, .oval]
    }
    
    enum Color: Int, Hashable {
        
        case red
        case green
        case purple
        
        static var colorAll = [Color.red, .green, .purple]
    }
    
    enum Count: Int, Hashable {
        
        case one
        case two
        case three
        
        static var countAll = [Count.one, .two, .three]
    }
    
    enum Opacity: Int, Hashable {
        
        case solid
        case unfilled
        case striped
        
        static var opacityAll = [Opacity.solid, Opacity.unfilled, Opacity.striped]
    }
    
}

