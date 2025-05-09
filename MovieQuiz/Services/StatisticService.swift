import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    var gamesCount: Int {
        return storedGamesCount
    }
    
    var bestGame: GameResult {
        return storedBestGame
    }
    
    private var correctAnswers: Int {
        return storedCorrectAnswers
    }
    
    var totalAccuracy: Double {
        let totalQuestions = gamesCount * 10
        guard totalQuestions > 0 else { return 0 }
        
        return (Double(correctAnswers)  / Double(totalQuestions)) * 100
        
    }
    
    func store(correct count: Int, total amount: Int) {
        storedGamesCount += 1
        storedCorrectAnswers += count
        
        let currentGame = GameResult(correct: correctAnswers, total: amount, date: Date())
        if currentGame.isBetterThan((storedBestGame)) {
            storedBestGame = currentGame
        }
    }
}
