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
    
    private var viewingCardList = [Int]()
    
    // 차례대로 애니메이션 적용을 위해서 타이머가 필요함.
    private var timer = Timer()
    private var startTimer = false
    
    private var cardNumber = 0
    private var matchingFlag = false
    lazy var grid = Grid(layout: .aspectRatio(0.9), frame: cardViewSpace.bounds)
    
    func addSubViewToGrid() {
        print("클릭한 카드 = \(clickCardNumbers)")
        // grid의 cellFrames 배열에 cardViewSpace를 추가.
        grid.frame = cardViewSpace.bounds
        grid.cellCount = game.viewCards.count
        
        for cardView in cardViewSpace.subviews {
            cardView.removeFromSuperview()
        }
        
        identifierTag = 0
        
        for index in 0..<grid.cellCount {
            
            if let card = grid[index]{
                let gamingCard = game.viewCards[index]
                let subView = CardView(rect: card.insetBy(dx: 4.0, dy: 4.0))
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapedCard(_:)))
                subView.addGestureRecognizer(tapRecognizer)
                subView.tag = identifierTag
                
                subView.symbol = gamingCard.suitSymbol
                subView.color = gamingCard.suitColor
                subView.count = gamingCard.suitCount.rawValue
                subView.opacity = gamingCard.suitOpacity
                
                // 기존에 그린적이 있는 카드일 떄.
                if viewingCardList.contains(identifierTag) {
                    subView.isFaceUp = true
                    subView.alpha = 1
                }
                
                // 매칭된 카드 자리는 flyDeckToCard()와 flipCardAnimation()을 따로 적용하기 위해서 걸러냄.
                if clickCardNumbers.count == 3, clickCardNumbers.contains(identifierTag){
                    subView.isFaceUp = false
                    //subView.afterMatch = true
                    subView.alpha = 0
                    
//                    if let wherePos = clickCardNumbers.firstIndex(of: identifierTag){
//                        clickCardNumbers.remove(at: wherePos)
//                    }
                }
                cardViewSpace.addSubview(subView)
                
                // 아직 3장 선택 다 안했는데, more card 눌렀을 떄 선택 중인 카드의 highlight 유지하기 위함.
                if clickCount < 4 && clickCardNumbers.contains(subView.tag)
                {
                    subView.layer.borderColor = UIColor.yellow.cgColor
                    subView.layer.borderWidth = 2
                }
                
                if !viewingCardList.contains(subView.tag){
                    viewingCardList.append(subView.tag)
                }
                
                identifierTag += 1
            }
        }
        
        print("viewingCardList = \(viewingCardList)")
        cardFlipTimer()
        //flyDeckToCard()
        
    }
    
    // 카드를 순서대로 애니메이션화하기 위해 추가한 timer.
    private func cardFlipTimer() {
        
        //cardEnable()
        
        
        if cardNumber < game.viewCards.count{
            print("timer ok")
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(flyDeckToCard), userInfo: nil, repeats: true)
        }
        else if cardNumber == game.viewCards.count {
            print("!!")
            timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(flyDeckToCard), userInfo: nil, repeats: true)
        }
    }
    
    // 새로운 카드를 나타낼 때, 뒤집는 애니메이션 함수.
    @objc private func flipCardAnimation() {
        
        if matchingFlag {
            print("매칭된 카드만 뒤집어야함")
            
            let tempValue = clickCardNumbers[0]
            if let currentAnimatedCard = cardViewSpace.subviews[tempValue] as? CardView, !currentAnimatedCard.isFaceUp{
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: [],
                    animations: {
                        currentAnimatedCard.alpha = 1
                    },
                    completion: { finished in
                        UIView.transition(
                            with: currentAnimatedCard,
                            duration: 0.3,
                            options: [.transitionFlipFromLeft],
                            animations: {
                                //currentAnimatedCard.alpha = 1;
                                currentAnimatedCard.isFaceUp = !currentAnimatedCard.isFaceUp
                                
                            }
                        )
                        
                    }
                )
                
                clickCardNumbers.removeFirst()
            }
            
            if clickCardNumbers.count == 0 {
                matchingFlag = false
                timer.invalidate()
            }
        }else {
            if let currentAnimatedCard = cardViewSpace.subviews[cardNumber] as? CardView, !currentAnimatedCard.isFaceUp{
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: [],
                    animations: {
                        currentAnimatedCard.alpha = 1
                    },
                    completion: { finished in
                        UIView.transition(
                            with: currentAnimatedCard,
                            duration: 0.3,
                            options: [.transitionFlipFromLeft],
                            animations: {
                                //currentAnimatedCard.alpha = 1;
                                currentAnimatedCard.isFaceUp = !currentAnimatedCard.isFaceUp
                                
                            }
                        )
                        
                    }
                )
                
                cardNumber += 1
            }
            
            if cardNumber == game.viewCards.count {
                print("stop timer please!")
                //cardEnable()
                timer.invalidate()
            }
        }
        
        
        
    }
    
    // 카드가 Deck에서 자기 자리로 날아가는 애니메이션.
    @objc private func flyDeckToCard(timer: Timer) {
        
        let cardFromDeck = UIView(frame: CGRect(origin: moreCardButton.frame.origin, size: moreCardButton.bounds.size))
        cardFromDeck.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        view.addSubview(cardFromDeck)
        
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.4,
            delay: 0.0,
            options: [.curveLinear],
            animations: {
                
                if self.matchingFlag {
                    
                    cardFromDeck.bounds.size = self.cardViewSpace.subviews[self.clickCardNumbers[0]].bounds.size
                    cardFromDeck.frame.origin.x = self.cardViewSpace.frame.origin.x + self.cardViewSpace.subviews[self.clickCardNumbers[0]].frame.origin.x;
                    cardFromDeck.frame.origin.y = self.cardViewSpace.frame.origin.y + self.cardViewSpace.subviews[self.clickCardNumbers[0]].frame.origin.y;
                    
                    //self.clickCardNumbers.removeFirst()
                    
                }else {
                    cardFromDeck.bounds.size = self.cardViewSpace.subviews[self.cardNumber].bounds.size
                    cardFromDeck.frame.origin.x = self.cardViewSpace.frame.origin.x + self.cardViewSpace.subviews[self.cardNumber].frame.origin.x;
                    cardFromDeck.frame.origin.y = self.cardViewSpace.frame.origin.y + self.cardViewSpace.subviews[self.cardNumber].frame.origin.y;
                }
            },
            completion: { current in
                cardFromDeck.removeFromSuperview()
                self.flipCardAnimation()
                
            }
        )
        
        
    }
    
    @objc func tapedCard(_ recognizer: UITapGestureRecognizer){
        
        
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
                    
                    matchingFlag = true
                    
                    for index in 0..<3{
                        cardViewSpace.subviews[clickCardNumbers[index]].layer.borderColor = UIColor.green.cgColor
                        
                        // MARK: 나중에 여기서 cardFlyAnimation 함수 호출해야함.
                        
                    }
                    
                    // 더이상에 deck이 카드가 없을 땐, 매칭된 자리의 카드를 hidden함.
                    if game.deckHasMoreCard == false && waitLastHighlight {
                        for index in 0..<3{
                            cardViewSpace.subviews[clickCardNumbers[index]].isHidden = true
                        }
                        
                        waitLastHighlight = false
                    }
                    
                    clickCount = 0
                    timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(offCardHighlight), userInfo: nil, repeats: false)
                    addSubViewToGrid()
                    
                    
                }else{
                    for index in 0..<3{
                        cardViewSpace.subviews[clickCardNumbers[index]].layer.borderColor = UIColor.red.cgColor
                    }
                    
                    // 일정시간이 지나면 카드의 red highlight가 꺼지게 하기 위함.
                    clickCount = 0
                    timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(offCardHighlight), userInfo: nil, repeats: false)
                    //clickCardNumbers.removeAll()
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
            
            if game.viewCards.count < cardViewSpace.subviews.count+1 {
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
    
    @objc func offCardHighlight(timer: Timer) {
        
        clickCardNumbers.forEach {
            cardViewSpace.subviews[$0].layer.borderColor = UIColor.clear.cgColor
            cardViewSpace.subviews[$0].layer.borderWidth = 0
        }
        
        if !matchingFlag {
            clickCardNumbers.removeAll()
        }
        
    }
    
    // 각종 애니메이션 실행 시, 각종 버튼을 선택을 불가하게 하거나, 다시 선택할 수 있게 해주는 함수.
    func cardEnable() {
        
        moreCardButton.isEnabled = !moreCardButton.isEnabled
        
        cardViewSpace.subviews.forEach {
            $0.isUserInteractionEnabled = !$0.isUserInteractionEnabled
        }
    }
    
}



