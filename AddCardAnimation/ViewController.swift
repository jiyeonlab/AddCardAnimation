//
//  ViewController.swift
//  AddCardAnimation
//
//  Created by JiyeonKim on 30/09/2019.
//  Copyright © 2019 JiyeonKim. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    var game = setCardGame()
    var clickCount = 0
    
    // 사용자가 클릭한 카드를 넣어둘 배열.
    var clickCardNumbers: Array<Int> = [Int]()
    
    var moreCardOK = true
    var waitLastHighlight = false
    
    @IBOutlet weak var moreCardButton: UIButton!
    
    
    @IBOutlet weak var cardViewSpace: UIView!
    
    private var viewCardCount = 0
    private var identifierTag = 0
    private var tapSubview: Array<UIView> = [UIView]()
    private var moreAdd = false
    private var rememberTapCardTag = 0

    lazy var grid = Grid(layout: .aspectRatio(0.9), frame: cardViewSpace.bounds)
    
    func addSubViewToGrid() {
        
        // grid의 cellFrames 배열에 cardViewSpace를 추가.
        grid.frame = cardViewSpace.bounds
        grid.cellCount = game.viewCards.count
        
        for cardView in cardViewSpace.subviews {
            cardView.removeFromSuperview()
        }
        
        viewCardCount = 0
        identifierTag = 0
        
        for index in 0..<grid.cellCount {
            if let card = grid[index]{
                let gamingCard = game.viewCards[index]
                // 서브뷰로 CardView 클래스 인스턴스를 만들어서 넣음.
                let subView = CardView(frame: card.insetBy(dx: 4.0, dy: 4.0))
                
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapedCard(_:)))
                
                subView.addGestureRecognizer(tapRecognizer)
                subView.tag = identifierTag
                
                subView.symbol = gamingCard.suitSymbol
                subView.color = gamingCard.suitColor
                subView.count = gamingCard.suitCount.rawValue
                subView.opacity = gamingCard.suitOpacity
                
                cardViewSpace.addSubview(subView)
                
                if clickCount < 4 && clickCardNumbers.contains(subView.tag)
                {
                    subView.layer.borderColor = UIColor.yellow.cgColor
                    subView.layer.borderWidth = 2
                }
                
                viewCardCount += 1
                identifierTag += 1
            }
        }
        
    }
    
    @objc func tapedCard(_ recognizer: UITapGestureRecognizer){
        // 선택한 3장의 카드가 매칭 여부를 판단하자 마자 border effect가 사라지는 것이 아니라, 그 다음번 카드를 선택시에 border effect를 끄기 위한 조건문.
        if clickCount == 4 {
            
            // 이 if 안에서 addCardViewToGrid()를 호출하기 때문에, 지금 tap한 카드의 정보를 잃어버린다.
            // 이 다음 if에서 현재 tap 카드의 border effect를 주기 위해 카드 정보를 기억함.
            if let rememberTapCard = recognizer.view {
                rememberTapCardTag = rememberTapCard.tag
            }

            if game.deckHasMoreCard == false && waitLastHighlight {
                for index in 0..<3{
                    cardViewSpace.subviews[clickCardNumbers[index]].isHidden = true
                }
                
                waitLastHighlight = false
            }
            
            offCardHighlight()
            addSubViewToGrid()
            clickCount = 0
            clickCardNumbers.removeAll()
        }
        
        // 총 3장의 카드를 선택할 때까지만 들어가는 코드.
        if let currentTapCard = recognizer.view, !clickCardNumbers.contains(currentTapCard.tag), clickCount < 3{
            
            // 매칭시킬 카드는 3장이므로, clickCard가 3장이 채워질 때까지만 유효한 코드.
            
            if rememberTapCardTag != 0 {
                //currentTapCard = taped.view[rememberTapCardTag]
                cardViewSpace.subviews[rememberTapCardTag].layer.borderColor = UIColor.yellow.cgColor
                cardViewSpace.subviews[rememberTapCardTag].layer.borderWidth = 2
                
                rememberTapCardTag = 0
            }
            
            clickCount += 1
            
            clickCardNumbers.append(currentTapCard.tag)
            
            currentTapCard.layer.borderColor = UIColor.yellow.cgColor
            currentTapCard.layer.borderWidth = 2
            
            // 선택된 3장의 카드 매칭 확인 시작.
            if clickCount == 3 {
                
                clickCount += 1
                let matchingBool = game.checkMatching(at: clickCardNumbers)
                
                if matchingBool {
                    
                    for index in 0..<3{
                        cardViewSpace.subviews[clickCardNumbers[index]].layer.borderColor = UIColor.green.cgColor
                    }
                    
                    if !game.deckHasMoreCard {
                        waitLastHighlight = true
                    }
                    
                }else{
                    for index in 0..<3{
                        cardViewSpace.subviews[clickCardNumbers[index]].layer.borderColor = UIColor.red.cgColor
                    }
                }
                
            }
            
        }else{
            // 선택한 카드를 취소하기 위한 코드
            if let deselectCard = recognizer.view {
                
                deselectCard.layer.borderColor = UIColor.clear.cgColor
                deselectCard.layer.borderWidth = 0
                
                if let findIndex = clickCardNumbers.firstIndex(of: deselectCard.tag) {
                    clickCardNumbers.remove(at: findIndex)
                }
                
                clickCount -= 1
            }
        }
    }
   
    @IBAction func tapMoreCard(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            
            if game.viewCards.count < viewCardCount+1 {
                if clickCount == 4 {
                    for index in 0..<3{
                        cardViewSpace.subviews[clickCardNumbers[index]].layer.borderColor = UIColor.clear.cgColor
                    }
                }
                
                game.moreCardAppend()
                addSubViewToGrid()
                
                if !game.deckHasMoreCard {
                    moreCardButton.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
                    moreCardButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: UIControl.State.normal)
                    moreCardButton.isEnabled = false
                }
                
            }
        default: break
        }
    }
    
    
    // viewDidLoad는 초기화 화면 설정에 해당한다.
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViewToGrid()
    }
    
    func offCardHighlight() {
        for index in game.viewCards.indices{
            cardViewSpace.subviews[index].layer.borderColor = UIColor.clear.cgColor
            cardViewSpace.subviews[index].layer.borderWidth = 0
        }
    }
    
}



