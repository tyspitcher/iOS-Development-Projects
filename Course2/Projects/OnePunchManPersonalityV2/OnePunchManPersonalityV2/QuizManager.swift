//
//  QuizManager.swift
//  OnePunchManPersonalityV2
//
//  Created by Tyson Pitcher on 3/13/26.
//

import Foundation
import SwiftUI
import Observation

enum CharacterType: String {
    case saitama
    case genos
    case mumenRider
    case puriPuri
    case king
    case tatsumaki
    case garou
    case bang
    case fubuki
}

struct Question {
    let text: String
    let answers: [Answer]
    let type: ResponseType
}

struct Answer {
    let text: String
    let points: [CharacterType: Int] /* customized to points instead of type so I can keep track of point values for multiple characters for the different answers */
}

enum ResponseType {
    case single, multiple, ranged
}

struct CharacterResult {
    var character: CharacterType
    var resultStatement: String
    var title: String
    var image: Image
    var blurb: String

}

let characterResults: [CharacterResult] = [
    CharacterResult(character: .saitama,
                    resultStatement: "You are Saitama",
                    title: "The Unbothered Hero",
                    image: Image("saitama"),
                    blurb: "You tend to stay calm while everyone else is panicking, and you rarely feel the need to prove yourself to anyone. While other people chase recognition, you’re usually more interested in keeping life simple and drama-free. You have a quiet confidence that comes from knowing your own strength, even if you don’t feel the need to show it off. People may underestimate you because you seem relaxed or detached, but when it matters most you step up without hesitation. You don’t get caught up in ego, competition, or complicated plans, and you often take on a new challenge just for the fun of it. Underneath that laid-back attitude is someone incredibly reliable. When things get serious, you’re the kind of person who ends the problem in one punch."),
    CharacterResult(character: .genos,
                    resultStatement: "You Are Genos",
                    title: "The Relentless Disciple",
                    image: Image("genos"),
                    blurb: "You approach life with intensity, discipline, and a constant drive to improve yourself. When you commit to something, you throw your whole focus into mastering it, even if the process is difficult or demanding. You take responsibility seriously and often push yourself harder than anyone else around you. Loyalty is a huge part of who you are, and when you respect someone, you stand by them completely. Even when situations look impossible, you refuse to back down or accept defeat. Your determination can sometimes make you overly hard on yourself, but it’s also what makes you powerful. You’re the kind of person who believes that strength is built through effort, sacrifice, and relentless dedication."),
    CharacterResult(character: .mumenRider,
                    resultStatement: "You Are Mumen Rider",
                    title: "The True Hero",
                    image: Image("mumenRider"),
                    blurb: "You believe that doing the right thing matters more than being the strongest person in the room. Even when situations seem overwhelming, your instinct is to step forward and help others rather than stand by and watch. Courage for you isn’t about being fearless—it’s about taking action because someone needs you. You have a strong sense of responsibility and an unwavering moral compass. People trust you because they know your intentions are sincere and your loyalty is genuine. While others might hesitate, you show up when it counts. Your strength comes from your heart and your willingness to stand up for what’s right."),
    CharacterResult(character: .puriPuri,
                    resultStatement: "You Are Puri-Puri Prisoner",
                    title: "The Passionate Protector",
                    image: Image("puriPuri"),
                    blurb: "You bring big energy, big emotions, and absolute loyalty to everything you do. When you care about someone or something, you protect it fiercely and without hesitation. You’re expressive, passionate, and completely unafraid to show how you feel. Your presence tends to fill the room, and people often remember your enthusiasm and intensity. While some might see your dramatic side as over-the-top, it comes from a place of genuine compassion and devotion. You fight with your whole heart, both emotionally and physically. When people need someone bold enough to stand up for them, you are already charging forward."),
    CharacterResult(character: .king,
                    resultStatement: "You Are King",
                    title: "The Accidental Legend",
                    image: Image("king"),
                    blurb: "People may see you as intimidating or impressive, but inside you’re often just trying to keep everything together. You’re highly aware of pressure and expectations, which can make you feel anxious when things spiral out of control. Even so, you often manage to stay composed enough to get through the moment. You may not always feel fearless, but you understand what’s at stake and you try your best anyway. Your self-awareness makes you more thoughtful than people realize. Sometimes your greatest strength is simply holding your ground when everything around you feels overwhelming. And somehow, things tend to work out in your favor."),
    CharacterResult(character: .tatsumaki,
                    resultStatement: "You Are Tatsumaki",
                    title: "The Unstoppable Force",
                    image: Image("tatsumaki"),
                    blurb: "You carry yourself with power, confidence, and a strong need to stay in control of your environment. You trust your own abilities above all else and rarely rely on others to solve problems for you. When challenges appear, your instinct is to take command and deal with them directly. You don’t tolerate weakness, incompetence, or people trying to hold you back. You may come off outwardly as intense, but it's because you are confident and competent. Your strength commands respect, even if it can feel intimidating to others. When things fall apart, you’re the person who steps in and takes control."),
    CharacterResult(character: .garou,
                    resultStatement: "You Are Garou",
                    title: "The Rebel with a Cause",
                    image: Image("garou"),
                    blurb: "You don’t naturally fit into the roles society expects, and you tend to challenge systems that feel unfair or hypocritical. Instead of following the crowd, you trust your instincts and carve your own path forward. You’re intense, determined, and unwilling to let anyone define who you’re supposed to be. Conflict doesn’t scare you— in fact, it often pushes you to grow stronger. You often identify with outsiders and question the way people label others as heroes or villains. Even when people misunderstand you, you continue pushing forward on your own terms. Your rebellious spirit and relentless drive make you a force that refuses to be ignored."),
    CharacterResult(character: .bang,
                    resultStatement: "You Are Bang",
                    title: "The Disciplined Master",
                    image: Image("bang"),
                    blurb: "You move through life with calm, discipline, and a quiet sense of responsibility. You do not need to be the loudest person in the room to command respect, because your presence comes from self-control and experience. People are likely to trust you because you stay steady when things get difficult and rarely lose sight of what matters most. You believe strength should be used with purpose, not just for pride or attention. Even when you carry regrets or burdens, you try to channel them into wisdom rather than bitterness. You have a grounded, mentor-like energy that makes others feel both challenged and supported. At your best, you are the kind of person who leads by example and shows that real power is strongest when guided by discipline and restraint."),
    CharacterResult(character: .fubuki,
                    resultStatement: "You Are Fubuki",
                    title: "The Charismatic Strategist",
                    image: Image("fubuki"),
                    blurb: "You approach life with ambition, awareness, and a strong sense of how people and situations work. You are naturally tuned in to social dynamics, which helps you lead, persuade, and protect in ways that are not always obvious from the outside. You want to be respected, and you are usually willing to put real thought and effort into building your place in the world. Even when you feel uncertain, you know how to carry yourself with confidence and composure. You are not just driven by power — you are also drawn to connection, influence, and the feeling of being someone others can rely on. You understand that strength is not always loud; sometimes it looks like strategy, timing, and knowing exactly how to move people. At your best, you are a magnetic, capable presence who knows how to turn intelligence and charm into real power.")
]

@Observable
class QuizManager {
    let questionList: [Question] = [
        Question(
            text: "You find yourself in a dangerous situation, what do you do first?",
            answers: [
                Answer(
                    text: "Trust my instincts and use the chaos to my advantage.",
                    points: [
                        .garou: 3,
                        .tatsumaki: 1,
                        .genos: 1
                    ]
                ),
                Answer(
                    text: "Hit the problem head-on.",
                    points: [
                        .genos: 3,
                        .garou: 1,
                        .tatsumaki: 1
                    ]
                ),
                Answer(
                    text: "Try to help other people.",
                    points: [
                        .mumenRider: 3,
                        .genos: 1,
                        .puriPuri: 1
                    ]
                ),
                Answer(
                    text: "Stay calm and only act if I have to.",
                    points: [
                        .saitama: 3,
                        .king: 1,
                        .bang: 1
                    ]
                )
                
            ],
            type: .single
        ),

        Question(
            text: "What role do you naturally take around other people?",
            answers: [
                Answer(
                    text: "The glue that keeps people connected and on the same page.",
                    points: [
                        .fubuki: 3,
                        .bang: 1,
                        .mumenRider: 1
                    ]
                ),
                Answer(
                    text: "The steady one people trust when things get serious.",
                    points: [
                        .bang: 3,
                        .mumenRider: 1,
                        .saitama: 1
                    ]
                ),
                Answer(
                    text: "The big-hearted one who gives everything for people they care about.",
                    points: [
                        .puriPuri: 3,
                        .mumenRider: 1
                    ]
                ),
                Answer(
                    text: "The low key one who would rather not be in the spotlight at all.",
                    points: [
                        .king: 3,
                        .saitama: 1
                    ]
                )
            ],
            type: .ranged
        ),

        Question(
            text: "Which interaction with others is most frustrating?",
            answers: [
                Answer(
                    text: "Being underestimated or having someone try to control me.",
                    points: [
                        .tatsumaki: 3,
                        .fubuki: 1,
                        .garou: 1
                    ]
                ),
                Answer(
                    text: "Being forced into a role or label that doesn't fit who I am.",
                    points: [
                        .garou: 3,
                        .king: 1,
                        .tatsumaki: 1
                    ]
                ),
                Answer(
                    text: "Feeling unprepared or not strong enough for a challenge.",
                    points: [
                        .genos: 3,
                        .bang: 1
                    ]
                ),
                Answer(
                    text: "Losing influence or not being taken seriously by the people around me.",
                    points: [
                        .fubuki: 3,
                        .tatsumaki: 1,
                        .king: 1
                    ]
                )
            ],
            type: .ranged
        ),

        Question(
            text: "After a big win, what feels best?",
            answers: [
                Answer(
                    text: "Moving on and going back to a simple life.",
                    points: [
                        .saitama: 3,
                        .king: 1
                    ]
                ),
                Answer(
                    text: "Knowing I helped improve other's lives.",
                    points: [
                        .mumenRider: 3,
                        .puriPuri: 1,
                        .bang: 1
                    ]
                ),
                Answer(
                    text: "Proving no one should look down on me.",
                    points: [
                        .tatsumaki: 3,
                        .garou: 1,
                        .fubuki: 1
                    ]
                ),
                Answer(
                    text: "Seeing discipline and experience pay off.",
                    points: [
                        .bang: 3,
                        .genos: 1
                    ]
                )
            ],
            type: .single
        ),

        Question(
            text: "When people misunderstand you, what bothers you the most?",
            answers: [
                Answer(
                    text: "They think being nervous means I can't handle what's in front of me.",
                    points: [
                        .king: 3,
                        .mumenRider: 1
                    ]
                ),
                Answer(
                    text: "They mistake my strong feelings for me being 'too much.'",
                    points: [
                        .puriPuri: 3,
                        .mumenRider: 1
                    ]
                ),
                Answer(
                    text: "They underestimate me because I’m not showing all my cards.",
                    points: [
                        .fubuki: 3,
                        .tatsumaki: 1,
                        .genos: 1
                    ]
                ),
                Answer(
                    text: "They judge me before understanding what my battles are.",
                    points: [
                        .garou: 3,
                        .king: 1,
                        .bang: 1
                    ]
                )
            ],
            type: .ranged
        ),

        Question(
            text: "Which statement feels most like your philosophy?",
            answers: [
                Answer(
                    text: "Keep it simple. Do what's needed and don't make a spectacle of it.",
                    points: [
                        .saitama: 3,
                        .king: 1
                    ]
                ),
                Answer(
                    text: "Real strength is built through relentless effort and self-improvement.",
                    points: [
                        .genos: 3,
                        .bang: 1,
                        .tatsumaki: 1
                    ]
                ),
                Answer(
                    text: "Do what's right, even if no one rewards you for it.",
                    points: [
                        .mumenRider: 3,
                        .puriPuri: 1,
                        .bang: 1
                    ]
                ),
                Answer(
                    text: "With great power comes great responsibility.",
                    points: [
                        .bang: 3,
                        .tatsumaki: 1,
                        .fubuki: 1
                    ]
                )
            ],
            type: .ranged
        ),

        Question(
            text: "How do you usually respond when fear hits?",
            answers: [
                Answer(
                    text: "I act anyway, even if I'm scared.",
                    points: [
                        .mumenRider: 3,
                        .king: 1,
                        .puriPuri: 1
                    ]
                ),
                Answer(
                    text: "I get sharper and more dangerous.",
                    points: [
                        .garou: 3,
                        .genos: 1,
                        .tatsumaki: 1
                    ]
                ),
                Answer(
                    text: "I focus my energy on finding solutions.",
                    points: [
                        .genos: 3,
                        .bang: 1
                    ]
                ),
                Answer(
                    text: "I try to hide how overwhelmed I feel.",
                    points: [
                        .king: 3,
                        .saitama: 1
                    ]
                )
            ],
            type: .single
        ),
        
        Question(
            text: "Which kind of strength fits you best?",
            answers: [
                Answer(
                    text: "The kind that takes control immediately and doesn't wait for permission.",
                    points: [
                        .tatsumaki: 3,
                        .genos: 1
                    ]
                ),
                Answer(
                    text: "The kind that reads people well and knows how to influence a situation.",
                    points: [
                        .fubuki: 3,
                        .bang: 1
                    ]
                ),
                Answer(
                    text: "The kind fueled by heart, passion, and total commitment.",
                    points: [
                        .puriPuri: 3,
                        .mumenRider: 1,
                        .garou: 1
                    ]
                ),
                Answer(
                    text: "The kind that comes from mastery, patience, and years of refinement.",
                    points: [
                        .bang: 3,
                        .genos: 1
                    ]
                )
            ],
            type: .ranged
        ),

        Question(
            text: "Choose one or two traits that feel most true to you.",
            answers: [
                Answer(
                    text: "I seem calmer on the outside than I feel on the inside.",
                    points: [
                        .king: 2,
                        .saitama: 1
                    ]
                ),
                Answer(
                    text: "I take growth and self-improvement very seriously.",
                    points: [
                        .genos: 2,
                        .bang: 1
                    ]
                ),
                Answer(
                    text: "My emotions are strong, and when I care, I go all in.",
                    points: [
                        .puriPuri: 2,
                        .mumenRider: 1,
                        .fubuki: 1
                    ]
                ),
                Answer(
                    text: "I hate being underestimated, boxed in, or controlled by other people.",
                    points: [
                        .garou: 2,
                        .tatsumaki: 2,
                        .fubuki: 1
                    ]
                )
            ],
            type: .multiple
        )
    ]
    
    var selectAnswers: [Int: [Int]] = [:]
    
    func selectAnswers(forQuestionAt questionIndex: Int, selections: [Int]) {
        selectAnswers[questionIndex] = selections
    }
    
    func clearSelections(forQuestionAt questionIndex: Int) {
        selectAnswers[questionIndex] = []
    }
    
    func calculateResults() -> (winner: CharacterType, totals: [CharacterType: Int]) {
        var totals: [CharacterType: Int] = [:]

        for (questionIndex, answerIndices) in selectAnswers {
            let question = questionList[questionIndex]
            for answerIndex in answerIndices {
                let answer = question.answers[answerIndex]
                for (character, points) in answer.points {
                    totals[character, default: 0] += points
                }
            }
        }
        let winner = totals.max(by: { $0.value < $1.value })?.key ?? .saitama
        return (winner, totals)
    }
}


