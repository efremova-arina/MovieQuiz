import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var questionTitleLabel: UILabel!
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        setupFonts()

        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [ weak self ] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - IBAction
    @IBAction private func yesButtonClicker(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicker(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswer == questionsAmount ?
            "Поздравляем! Вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswer) из 10, попробуйте ещё раз!"
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    self?.startNewGame()
                }
            )
            alertPresenter.show(quiz: alertModel)
        } else {
            currentQuestionIndex += 1

            questionFactory.requestNextQuestion().self
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswer += 1
        }
        
        setButtonsEnabled(false)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.setButtonsEnabled(true)
            self.showNextQuestionOrResults()
            self.imageView.layer.borderWidth = 0
        }
    }
    
    private func setButtonsEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func startNewGame() {
        currentQuestionIndex = 0
        correctAnswer = 0
        
        questionFactory.requestNextQuestion()
    }
    
    private func setupFonts() {
        textLabel.font = UIFont(name: "YSDisplay-Bold", size: 23.0)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20.0)
    }
}
