//
//  ContentView.swift
//  DynamicVision
//
//  Created by 佐藤咲祐 on 2024/01/23.
//

import SwiftUI

struct ContentView: View {
    @Binding var spinSpeed: Double
    @State private var symbols = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    @State private var numbers = [1, 4, 7] // 現在の値
    @State private var score = 0
    @State private var isSpinning = [false, false, false]
    @State private var failureCount = 0
    @State private var showGameOver = false
    @State private var highScore = 0

    init(spinSpeed: Binding<Double>) {
        self._spinSpeed = spinSpeed
    }
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("最高記録: \(highScore)")
                        .font(.headline)
                        .padding()
                    Spacer()
                }
                
                Text("あなたの動体視力は？startをタップ！")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding()
                
                HStack {
                    ForEach(numbers.indices, id: \.self) { index in
                        VStack {
                            Text(symbols[numbers[index] % symbols.count])
                                .font(.system(size: 50))
                                .foregroundColor(numbers[index] % symbols.count == 6 ? .red : .black)
                                .frame(width: 70, height: 70)
                                .border(Color.black)
                            
                            Button(action: { self.stopSpin(slot: index) }) {
                                Text("Stop")
                            }
                            .disabled(!isSpinning[index])
                        }
                    }
                }
                
                HStack {
                    Button(action: { self.spinAll() }) {
                        Text("Start")
                    }
                    .disabled(isSpinning.contains(true))
                    
                    
                    
                    Text("Score: \(score)")
                }
                .padding()
                
                
                .fullScreenCover(isPresented: $showGameOver, onDismiss: {
                    self.reset() // オプション: 必要に応じてリセット処理を行う
                }) {
                    GameOverView(score: score, tryAgainAction: {
                        self.showGameOver = false
                        self.reset()
                    })
                }
            }
            .onAppear {
                loadHighScore()
            }
        }
    }
    
    func spin(slot: Int) {
        isSpinning[slot] = true
        // 回転させる
        DispatchQueue.main.asyncAfter(deadline: .now() + spinSpeed) {
            // 停止しているかを確認し、停止していたら早期リターンする
            if !isSpinning[slot] {
                return
            }
            // 値を更新（9に達したら1に戻る）
            numbers[slot] = numbers[slot] % symbols.count + 1
            if isSpinning[slot] {
                spin(slot: slot)
            }
        }
    }
    
    func spinAll() {
        for i in 0..<3 {
            spin(slot: i)
        }
    }
    
    func stopSpin(slot: Int) {
        isSpinning[slot] = false
        
        // 全て停止したかチェック
        if !isSpinning.contains(true) {
            let didWin = calculateScore()
            if !didWin {
                failureCount += 1
                
                // 3回失敗するとゲームオーバー
                if failureCount >= 3  {
                    showGameOver = true
                    // ゲームオーバーの場合はここでリセットしない
                } else {
                    // 揃わなかった場合、状態をリセット
                    resetSlots()
                }
            } else {
                // 揃った場合も状態をリセット
                resetSlots()
            }
        }
    }



    func reset() {
        score = 0
        numbers = [1, 4, 7]
        isSpinning = [false, false, false]
        failureCount = 0
    }
    
    func resetSlots() {
        numbers = [1, 4, 7]
        isSpinning = [false, false, false]
    }
    
    func calculateScore() -> Bool {
        if numbers[0] == numbers[1] && numbers[1] == numbers[2] {
            if numbers[0] % symbols.count == 6 {
                // Triple 7s
                score += 500
                print("500pt ゲット！素晴らしいです！")
            } else {
                // Other triples
                score += 300
                print("300pt ゲット！ナイスです！")
            }
            
            // Speedが0.10秒の場合に最高記録を更新
            if spinSpeed == 0.10 && score > highScore {
                highScore = score
                saveHighScore()
            }
            
            // 揃ったので true を返す
            return true
        }
        // 揃わなかったので false を返す
        return false
    }
    
    func saveHighScore() {
        UserDefaults.standard.set(highScore, forKey: "HighScore")
    }
    
    func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
    }
}




struct HomeView: View {
    @Binding var spinSpeed: Double
    
    var body: some View {
        VStack(spacing: 20) {
            Text("動体視力鍛錬場へ\nようこそ！")
                .font(.largeTitle)
                .padding()
            
            Text("↓回転スピードを調節↓")
                .foregroundColor(.red)
            
            // スピードコントローラーのスライダー
            HStack {
                Text("Speed:")
                Slider(value: $spinSpeed, in: 0.01...0.3, step: 0.01)
                Text(String(format: "%.2f", spinSpeed) + "s")
            }
            .padding()
            
            // Goボタンで画面に遷移
            NavigationLink(destination: ContentView(spinSpeed: $spinSpeed)) {
                Text("Go!")
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            
            //　ルールボタン
            NavigationLink(destination: RulesView()) {
                Text("ルールを確認する")
                    .font(.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Spacer()
        }
    }
}



// GameOverViewの定義を変更
struct GameOverView: View {
    let score: Int
    let tryAgainAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over!")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Your Score: \(score)")
                .font(.title)
            Button(action: tryAgainAction) {
                Text("Try Again")
                    .font(.title)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}



struct RulesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("ゲームのルール")
                .font(.largeTitle)
                .padding()
            
            Text("""
                 ・3回失敗するとgameover
                 
                 ・7を揃えると500点
                 
                 ・他の数字を揃えると300点
                 
                 ・Speedが0.10sの時のscore
                 　を正式記録として採用
                 
                 ・最高記録を更新できるよう
                 　に頑張ろう！
                 """)
                .font(.title)
                .padding()
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("ルール", displayMode: .inline)
    }
}
