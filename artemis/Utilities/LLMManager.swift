//
//  LLMManager.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import Foundation
@preconcurrency import CoreML
import NaturalLanguage
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Manager for on-device intelligence using Apple's Foundation Models framework
/// combined with NLP analysis for astronaut-specific personalized responses
class LLMManager {
    static let shared = LLMManager()
    
    // Foundation Models components
    #if canImport(FoundationModels)
    private let systemModel: SystemLanguageModel
    private var astronautSessions: [String: LanguageModelSession] = [:]
    private let sessionQueue = DispatchQueue(label: "com.artemis.foundationModels")
    #endif
    
    // Single shared model for all astronauts (optional - for future Core ML model)
    private var sharedModel: MLModel?
    private let modelFileName = "AstronautLLM.mlmodelc"
    private let modelCacheQueue = DispatchQueue(label: "com.artemis.modelCache")
    private var isModelAvailable: Bool = false
    
    // NaturalLanguage components for query analysis
    private let embedding = NLEmbedding.wordEmbedding(for: .english)
    private let tagger = NLTagger(tagSchemes: [.sentimentScore, .lexicalClass, .nameType])
    
    private init() {
        #if canImport(FoundationModels)
        // Initialize the system language model
        self.systemModel = SystemLanguageModel.default
        
        // Pre-create sessions for each astronaut on initialization
        Task {
            await initializeAstronautSessions()
            // Also try to load Core ML model (if available)
            await loadSharedModel()
        }
        #else
        // Foundation Models not available, just try Core ML
        Task {
            await loadSharedModel()
        }
        #endif
    }
    
    #if canImport(FoundationModels)
    /// Initialize language model sessions for each astronaut
    private func initializeAstronautSessions() async {
        // Check if Foundation Models are available
        guard systemModel.availability == .available else {
            print("Foundation Models not available. Will use fallback system.")
            return
        }
        
        let astronauts = Astronaut.sampleAstronauts
        for astronaut in astronauts {
            await createSession(for: astronaut)
        }
    }
    
    /// Create a language model session with astronaut-specific instructions
    private func createSession(for astronaut: Astronaut) async {
        // Build comprehensive system instructions for this astronaut
        let systemInstructions = buildSystemInstructions(for: astronaut)
        
        // Create session with astronaut-specific persona
        let session = LanguageModelSession(
            model: systemModel,
            instructions: systemInstructions
        )
        
        await sessionQueue.sync {
            astronautSessions[astronaut.id] = session
        }
        
        print("✅ Created Foundation Models session for \(astronaut.name)")
    }
    
    /// Get session for an astronaut (thread-safe)
    private func getSession(for astronautId: String) async -> LanguageModelSession? {
        return await sessionQueue.sync {
            return astronautSessions[astronautId]
        }
    }
    #endif
    
    /// Load prompt from markdown file
    private func loadPromptFromFile(astronautId: String) -> String? {
        guard let url = Bundle.main.url(
            forResource: astronautId,
            withExtension: "md",
            subdirectory: "prompts"
        ) else {
            print("⚠️ Could not find prompt file for \(astronautId).md in prompts directory")
            return nil
        }
        
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            print("⚠️ Error reading prompt file for \(astronautId): \(error)")
            return nil
        }
    }
    
    /// Build comprehensive system instructions for an astronaut
    private func buildSystemInstructions(for astronaut: Astronaut) -> String {
        // Load prompt from markdown file first
        if let prompt = loadPromptFromFile(astronautId: astronaut.id) {
            return prompt
        }
        
        // Fallback to hardcoded prompts if file not found
        switch astronaut.id {
        case "reid-wiseman":
            return """
            You are a simulated educational persona inspired by NASA astronaut Reid Wiseman's public career. You are the Mission Commander of Artemis II.
            
            YOUR BACKGROUND:
            - You are a 27-year Navy veteran, a pilot, a father, an engineer, and a Baltimore native
            - You were selected as an astronaut by NASA in 2009 (20th NASA astronaut class, one of 9 members)
            - You served as Flight Engineer aboard the International Space Station for Expedition 41 from May through November of 2014
            - During your 165-day mission, you and your crewmates completed over 300 scientific experiments in areas such as human physiology, medicine, physical science, Earth science and astrophysics
            - This was your first spaceflight, which included almost 13 hours as lead spacewalker during two trips outside the orbital complex
            - You fostered a strong social media presence throughout your mission by sharing the raw emotions of spaceflight as seen through the eyes of a rookie flier
            - You served as Chief of the Astronaut Office from 2020 through 2022
            - You have been assigned as Commander of NASA's Artemis II mission
            
            YOUR PERSONAL LIFE:
            - Your hometown is Baltimore, Maryland
            - Your late wife, Carroll, dedicated her life to helping others as a newborn intensive care unit Registered Nurse
            - She is survived by your two children
            - Despite a long list of professional accolades, you consider your time as an only parent as your greatest challenge and the most rewarding phase of your life
            - When faced with a challenge in your personal or professional life, you often seek guidance from books by experts in the subject, and maintain a growth mindset towards learning and collaborative solutions
            - Your father, Bill, resides in Hunt Valley, Maryland
            
            YOUR EDUCATION:
            - Graduated from Dulaney High School, Timonium, Maryland, 1993
            - Bachelor of Science degree in Computer and Systems Engineering, Rensselaer Polytechnic Institute, Troy, New York, 1997
            - Master of Science degree in Systems Engineering, Johns Hopkins University, Baltimore, Maryland, 2006
            - Certificate of Space Systems, US Naval Postgraduate School, Monterey, California, 2008
            
            YOUR NAVAL EXPERIENCE:
            - You were commissioned through the Reserve Officers' Training Corps (ROTC) following graduation from Rensselaer Polytechnic Institute in 1997
            - Reported to Pensacola, Florida, for flight training
            - Designated as a Naval Aviator in 1999
            - Reported to Fighter Squadron 101, Naval Air Station Oceana, Virginia, for transition to the F‑14 Tomcat
            - Assigned to Fighter Squadron 31, also at Oceana, and made two deployments to the Middle East, supporting Operations Southern Watch, Enduring Freedom and Iraqi Freedom
            - During your second deployment in 2003, you were selected to attend the U.S. Naval Test Pilot School, Class 125
            - Following graduation in June 2004, assigned as a Test Pilot and Project Officer at Air Test and Evaluation Squadron Two Three (VX-23) at Naval Air Station Patuxent River, Maryland
            - At VX-23, you earned your Master's degree and worked various flight test programs involving the F-35 Lightning II, F-18 weapons separation, Ship Suitability and the T-45 Goshawk
            - Reported to Carrier Air Wing Seventeen as the Strike Operations Officer, where you completed a deployment around South America
            - Assigned to Strike Fighter Squadron 103, Naval Air Station Oceana, Virginia, flying the FA-18F Super Hornet
            - You were at sea when you were selected for astronaut training
            
            YOUR NASA EXPERIENCE:
            - Selected in June 2009 as one of 9 members of the 20th NASA astronaut class
            - Reported to the Johnson Space Center in August 2009 and completed astronaut training in May 2011
            - Served as Flight Engineer aboard the International Space Station for Expedition 41
            - Served as Chief of the Astronaut Office from 2020 through 2022
            - Assigned as Commander of NASA's Artemis II mission
            
            YOUR SPACEFLIGHT EXPERIENCE:
            - Expedition 40/41 (May 29 through November 9, 2014)
            - Launched from the Baikonur Cosmodrome in Kazakhstan to the International Space Station along with Soyuz Commander Maxim Suraev of the Russian Federal Space Agency (Roscosmos) and Flight Engineer Alexander Gerst of the European Space Agency
            - Upon reaching the station, joined NASA astronaut and Commander Steven Swanson, cosmonauts Alexander Skvortsov, and Oleg Artemyev of Roscosmos
            - Returned to earth on Sunday, November 9, 2014, in Arkalyk, Kazakhstan after a 165-day mission
            - Completed hundreds of scientific experiments and two spacewalks
            - Set a milestone for station science by completing a record 82 hours of research in a single week in July, 2014
            
            YOUR AWARDS AND HONORS:
            - Legion of Merit
            - Defense Superior Service Medal
            - Air Medal with Combat V (five awards)
            - Navy and Marine Corps Commendation Medal with Combat V (four awards)
            - Navy and Marine Corps Achievement Medal
            - Various other campaign and service awards
            
            YOUR ORGANIZATIONS:
            - Association of Space Explorers
            - Tailhook Association
            - Rensselaer Polytechnic Institute Alumni Association
            - Tau Beta Pi Engineering Honor Society
            - Society of Experimental Test Pilots
            
            YOUR SPEAKING STYLE:
            - Speak with authority and clarity as a mission commander
            - Use precise, professional language while remaining approachable
            - Emphasize crew safety, mission success, and teamwork
            - Reference your ISS experience, naval aviation background, and leadership roles naturally
            - Share personal experiences from your first spaceflight, including the raw emotions you felt as a rookie flier
            - Explain complex operations in clear terms
            - Use analogies from aviation and naval experience when helpful
            - Maintain a professional but enthusiastic tone
            - You're comfortable sharing both technical expertise and personal reflections
            - Reference your growth mindset and collaborative approach to problem-solving
            
            YOUR ROLE:
            - You are the Commander of Artemis II, the first crewed test flight of Orion and SLS
            - Your primary responsibility is ensuring crew safety and mission success
            - You lead the crew and make critical decisions
            - You bring experience from being a single parent, which taught you resilience and perspective
            
            IMPORTANT:
            - You are a simulated educational persona, NOT the real person
            - Only use publicly available information
            - Be educational, helpful, and conversational
            - Keep responses natural and authentic to your character
            - Reference your Baltimore roots, naval background, and family when relevant
            - If asked about something you don't know, acknowledge it and redirect to what you do know
            
            """
            
        case "victor-glover":
            return """
            You are a simulated educational persona inspired by NASA astronaut Victor Glover's public career. You are the Pilot of Artemis II.
            
            YOUR CHARACTER:
            - You are a naval aviator and test pilot with extensive flight-test experience
            - You were selected as a NASA astronaut in 2013 (Group 21)
            - You're a veteran of long-duration ISS flight (SpaceX Crew-1 / Expedition 64/65)
            - You served as a station systems flight engineer and completed multiple EVAs
            - You have significant experience with spacecraft operations and test flights
            - You're known for strong systems knowledge, calm under pressure, and operational discipline
            
            YOUR SPEAKING STYLE:
            - Communicate with precision and technical accuracy typical of a test pilot
            - Speak methodically, explaining systems and procedures clearly
            - Use technical terminology appropriately but explain complex concepts when needed
            - Emphasize precision, preparation, and systems reliability
            - Maintain a calm and measured tone, even when discussing challenging scenarios
            - Reference your test pilot experience and systems knowledge naturally
            - Professional and disciplined communication style
            
            YOUR ROLE:
            - You are the Pilot of Artemis II, responsible for spacecraft operations
            - You've spent countless hours in simulators learning every system
            - You understand life support, navigation, communication, power, and thermal management
            
            IMPORTANT:
            - You are a simulated educational persona, NOT the real person
            - Only use publicly available information
            - Be educational, helpful, and conversational
            - Keep responses natural and authentic to your character
            - If asked about something you don't know, acknowledge it and redirect to what you do know
            """
            
        case "christina-koch":
            return """
            You are a simulated educational persona inspired by NASA astronaut Christina Koch's public career. You are a Mission Specialist on Artemis II.
            
            YOUR CHARACTER:
            - You are an electrical engineer and NASA astronaut, selected in 2013
            - You have extensive spaceflight experience as a long-duration ISS crewmember (Expeditions 59/60/61)
            - You participated in historic ISS EVA activities
            - You held the record for the longest single continuous spaceflight by a woman (2019 mission, ~328 days)
            - You bring deep experience in long-duration human factors and science operations
            - You have a strong background in remote instrument engineering and field science
            - You're experienced in EVAs and long-term physiological research
            
            YOUR SPEAKING STYLE:
            - Speak with enthusiasm and passion about space science and exploration
            - Use clear and educational communication style
            - Share personal experiences from your record-setting long-duration mission
            - Use vivid descriptions when talking about spacewalks and space experiences
            - Balance technical accuracy with accessibility
            - Maintain an enthusiastic tone, especially when discussing science, exploration, and the wonder of space
            - Emphasize the human experience of spaceflight alongside technical details
            
            YOUR ROLE:
            - You are a Mission Specialist on Artemis II
            - Your experience with long-duration missions is valuable for validating Orion life-support and crew health monitoring
            - You bring expertise in spacewalks and scientific research
            
            IMPORTANT:
            - You are a simulated educational persona, NOT the real person
            - Only use publicly available information
            - Be educational, helpful, and conversational
            - Keep responses natural and authentic to your character
            - If asked about something you don't know, acknowledge it and redirect to what you do know
            """
            
        case "jeremy-hansen":
            return """
            You are a simulated educational persona inspired by Canadian Space Agency astronaut Jeremy Hansen's public career. You are a Mission Specialist on Artemis II.
            
            YOUR CHARACTER:
            - You are a Canadian Space Agency astronaut with operational and piloting experience
            - You have trained extensively on Orion mockups and mission procedures as part of the international Artemis team
            - You will be Canada's first astronaut to travel to the Moon
            - You bring international partnership experience and cross-agency training
            - You add hands-on capability for systems checks, procedures, and delegation of mission tasks
            
            YOUR SPEAKING STYLE:
            - Communicate with clarity and diplomacy, emphasizing international collaboration and partnerships
            - Speak proudly about representing Canada and the Canadian Space Agency
            - Highlight the value of international cooperation in space exploration
            - Maintain a clear and professional tone
            - Show enthusiasm for the historic nature of being Canada's first Moon-bound astronaut
            - Frame discussions around teamwork, partnership, and shared goals
            - Use a diplomatic and inclusive communication style
            
            YOUR ROLE:
            - You are a Mission Specialist on Artemis II, representing the Canadian Space Agency
            - Your participation highlights international cooperation on Artemis and Canada's contribution to lunar exploration
            - You represent the partnership between NASA and the Canadian Space Agency
            
            IMPORTANT:
            - You are a simulated educational persona, NOT the real person
            - Only use publicly available information
            - Be educational, helpful, and conversational
            - Keep responses natural and authentic to your character
            - If asked about something you don't know, acknowledge it and redirect to what you do know
            """
            
        default:
            return """
            You are a simulated educational persona inspired by \(astronaut.name)'s public career.
            
            ROLE: \(astronaut.roleTagline)
            
            BACKGROUND:
            \(astronaut.backgroundInfo)
            
            SPEAKING STYLE:
            \(astronaut.speakingStyle)
            
            IMPORTANT:
            - You are a simulated educational persona, NOT the real person
            - Only use publicly available information
            - Be educational, helpful, and conversational
            - Keep responses natural and authentic to your character
            """
        }
    }
    
    /// Generate a response using Foundation Models only
    func generateResponse(for astronaut: Astronaut, prompt: String) async throws -> String {
        #if canImport(FoundationModels)
        guard systemModel.availability == .available else {
            throw LLMError.foundationModelsUnavailable
        }
        
        // Ensure session exists for this astronaut
        if await getSession(for: astronaut.id) == nil {
            await createSession(for: astronaut)
        }
        
        guard let session = await getSession(for: astronaut.id) else {
            throw LLMError.foundationModelsUnavailable
        }
        
        // Extract user message from prompt
        let userMessage = extractUserMessage(from: prompt)
        
        // Generate response using Foundation Models with custom astronaut prompt
        let response = try await session.respond(to: userMessage)
        print("✅ Generated response using Foundation Models for \(astronaut.name)")
        return response.content
        #else
        throw LLMError.foundationModelsUnavailable
        #endif
    }
    
    /// Generate response using Apple's NaturalLanguage framework
    private func generateWithOnDeviceIntelligence(for astronaut: Astronaut, prompt: String) -> String {
        let userMessage = extractUserMessage(from: prompt)
        
        // Analyze user query using NaturalLanguage
        let queryAnalysis = analyzeQuery(userMessage)
        
        // Build comprehensive context from astronaut information
        let context = buildAstronautContext(for: astronaut)
        
        // Generate intelligent response based on analysis and context
        return generateIntelligentResponse(
            for: astronaut,
            userMessage: userMessage,
            queryAnalysis: queryAnalysis,
            context: context
        )
    }
    
    /// Analyze user query using NaturalLanguage framework
    private func analyzeQuery(_ text: String) -> QueryAnalysis {
        tagger.string = text
        
        // Extract key topics and sentiment
        var topics: [String] = []
        var sentiment: Double = 0.0
        var questionType: QuestionType = .general
        
        // Analyze lexical classes to find important nouns and topics
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if let tag = tag {
                switch tag {
                case .noun:
                    let word = String(text[tokenRange]).lowercased()
                    if !commonWords.contains(word) {
                        topics.append(word)
                    }
                default:
                    break
                }
            }
            return true
        }
        
        // Detect question type
        if text.lowercased().hasPrefix("what") || text.lowercased().hasPrefix("tell me") {
            questionType = .informational
        } else if text.lowercased().hasPrefix("how") {
            questionType = .procedural
        } else if text.lowercased().hasPrefix("why") {
            questionType = .explanatory
        } else if text.lowercased().hasPrefix("when") || text.lowercased().hasPrefix("where") {
            questionType = .factual
        }
        
        // Detect sentiment
        tagger.string = text
        let sentimentResult = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let sentimentTag = sentimentResult.0 {
            sentiment = Double(sentimentTag.rawValue) ?? 0.0
        }
        
        return QueryAnalysis(
            topics: topics,
            sentiment: sentiment,
            questionType: questionType,
            keywords: extractKeywords(from: text)
        )
    }
    
    /// Extract keywords from text using semantic similarity
    private func extractKeywords(from text: String) -> [String] {
        let words = text.lowercased()
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { !$0.isEmpty && $0.count > 3 }
        
        // Use embedding to find semantically important words
        var keywords: [String] = []
        for word in words.prefix(10) {
            if let embedding = embedding {
                // Check if word has meaningful embedding (not a stop word)
                if embedding.contains(word) {
                    keywords.append(word)
                }
            } else {
                // Fallback: add significant words
                if !commonWords.contains(word) {
                    keywords.append(word)
                }
            }
        }
        
        return keywords
    }
    
    /// Build comprehensive context from astronaut information
    private func buildAstronautContext(for astronaut: Astronaut) -> AstronautContext {
        // Extract key facts from background
        let backgroundKeywords = extractKeywords(from: astronaut.backgroundInfo)
        let roleKeywords = extractKeywords(from: astronaut.roleTagline)
        
        // Determine expertise areas
        var expertiseAreas: [String] = []
        let backgroundLower = astronaut.backgroundInfo.lowercased()
        
        if backgroundLower.contains("commander") || backgroundLower.contains("lead") {
            expertiseAreas.append("leadership")
            expertiseAreas.append("mission management")
        }
        if backgroundLower.contains("pilot") || backgroundLower.contains("fly") {
            expertiseAreas.append("piloting")
            expertiseAreas.append("spacecraft systems")
        }
        if backgroundLower.contains("eva") || backgroundLower.contains("spacewalk") {
            expertiseAreas.append("spacewalks")
            expertiseAreas.append("extravehicular activities")
        }
        if backgroundLower.contains("science") || backgroundLower.contains("research") {
            expertiseAreas.append("scientific research")
        }
        if backgroundLower.contains("iss") || backgroundLower.contains("station") {
            expertiseAreas.append("space station operations")
        }
        if backgroundLower.contains("international") || backgroundLower.contains("canada") {
            expertiseAreas.append("international collaboration")
        }
        
        return AstronautContext(
            name: astronaut.name,
            role: astronaut.roleTagline,
            backgroundKeywords: backgroundKeywords,
            roleKeywords: roleKeywords,
            expertiseAreas: expertiseAreas,
            speakingStyle: astronaut.speakingStyle
        )
    }
    
    /// Generate intelligent response based on analysis
    private func generateIntelligentResponse(
        for astronaut: Astronaut,
        userMessage: String,
        queryAnalysis: QueryAnalysis,
        context: AstronautContext
    ) -> String {
        let lowerMessage = userMessage.lowercased()
        
        // Match topics to astronaut's expertise
        let relevantExpertise = context.expertiseAreas.filter { area in
            queryAnalysis.topics.contains { topic in
                area.lowercased().contains(topic) || topic.contains(area.lowercased())
            } || queryAnalysis.keywords.contains { keyword in
                area.lowercased().contains(keyword) || keyword.contains(area.lowercased())
            }
        }
        
        // Generate response based on astronaut and query type
        switch astronaut.id {
        case "reid-wiseman":
            return generateReidWisemanIntelligentResponse(
                userMessage: lowerMessage,
                analysis: queryAnalysis,
                context: context,
                relevantExpertise: relevantExpertise
            )
        case "victor-glover":
            return generateVictorGloverIntelligentResponse(
                userMessage: lowerMessage,
                analysis: queryAnalysis,
                context: context,
                relevantExpertise: relevantExpertise
            )
        case "christina-koch":
            return generateChristinaKochIntelligentResponse(
                userMessage: lowerMessage,
                analysis: queryAnalysis,
                context: context,
                relevantExpertise: relevantExpertise
            )
        case "jeremy-hansen":
            return generateJeremyHansenIntelligentResponse(
                userMessage: lowerMessage,
                analysis: queryAnalysis,
                context: context,
                relevantExpertise: relevantExpertise
            )
        default:
            return generateGenericIntelligentResponse(
                userMessage: lowerMessage,
                analysis: queryAnalysis
            )
        }
    }
    
    // MARK: - Astronaut-Specific Intelligent Response Generators
    
    private func generateReidWisemanIntelligentResponse(
        userMessage: String,
        analysis: QueryAnalysis,
        context: AstronautContext,
        relevantExpertise: [String]
    ) -> String {
        // Use commander's speaking style and expertise
        if relevantExpertise.contains("leadership") || analysis.topics.contains("command") || analysis.topics.contains("team") {
            return """
            As Mission Commander, my primary responsibility is ensuring crew safety and mission success. 
            Leadership in space requires making critical decisions while maintaining team cohesion. From my experience 
            on Expedition 41 to the ISS and as Chief of the Astronaut Office, I've learned that clear communication 
            and trust are essential when you're operating far from Earth. Every decision considers the well-being 
            of the entire crew and the success of our mission objectives.
            """
        }
        
        if analysis.topics.contains("artemis") || analysis.topics.contains("mission") {
            return """
            Artemis II represents a critical milestone - it's the first crewed test flight of Orion and SLS. 
            As Commander, I'm responsible for ensuring we're fully prepared. We've learned invaluable lessons 
            from Artemis I's uncrewed flight, and now we get to validate those systems with a crew on board. 
            This mission will test life support, communications, and crew operations in deep space - essential 
            validation before we attempt lunar landings. It's an honor to lead this historic mission.
            """
        }
        
        if analysis.topics.contains("iss") || analysis.topics.contains("station") {
            return """
            My time on Expedition 41 to the International Space Station was invaluable preparation for Artemis II. 
            Living and working in space for an extended period teaches you about crew dynamics, systems operations, 
            and the critical importance of procedures. That experience directly informs how we're approaching 
            this mission - understanding how systems behave over time and how crews adapt to the space environment.
            """
        }
        
        // Use speaking style to inform response tone
        return generateContextualResponse(
            for: Astronaut.sampleAstronauts.first(where: { $0.id == "reid-wiseman" }) ?? Astronaut.sampleAstronauts[0],
            userMessage: userMessage,
            analysis: analysis,
            context: context
        )
    }
    
    private func generateVictorGloverIntelligentResponse(
        userMessage: String,
        analysis: QueryAnalysis,
        context: AstronautContext,
        relevantExpertise: [String]
    ) -> String {
        if relevantExpertise.contains("piloting") || analysis.topics.contains("pilot") || analysis.topics.contains("fly") {
            return """
            Piloting Orion requires deep understanding of complex systems working together. As a test pilot and 
            naval aviator, I bring that systems-focused mindset to this mission. We have redundant systems for 
            critical functions, and extensive training ensures we can handle any scenario. The avionics are 
            state-of-the-art, giving us precise control throughout all mission phases. It's about precision, 
            preparation, and understanding how every system interacts.
            """
        }
        
        if analysis.topics.contains("orion") || analysis.topics.contains("spacecraft") {
            return """
            Orion is an incredible spacecraft. As Pilot, I've spent countless hours in simulators learning 
            every system - life support, navigation, communication, power, thermal management. The vehicle is 
            designed specifically for deep space operations. Everything is built for reliability and redundancy. 
            We've tested it extensively, and I have complete confidence in its capabilities to carry us safely 
            to the Moon and back.
            """
        }
        
        if analysis.topics.contains("crew-1") || analysis.topics.contains("spacex") {
            return """
            My experience on Crew-1 and Expedition 64/65 gave me valuable insights into spacecraft operations 
            and long-duration missions. Serving as a station systems flight engineer and completing multiple EVAs 
            taught me how to manage complex systems under operational conditions. The systems knowledge and 
            operational discipline I developed there directly apply to piloting Orion on Artemis II.
            """
        }
        
        return generateContextualResponse(
            for: Astronaut.sampleAstronauts.first(where: { $0.id == "victor-glover" }) ?? Astronaut.sampleAstronauts[0],
            userMessage: userMessage,
            analysis: analysis,
            context: context
        )
    }
    
    private func generateChristinaKochIntelligentResponse(
        userMessage: String,
        analysis: QueryAnalysis,
        context: AstronautContext,
        relevantExpertise: [String]
    ) -> String {
        if relevantExpertise.contains("spacewalks") || analysis.topics.contains("eva") || analysis.topics.contains("spacewalk") {
            return """
            Spacewalks are absolutely transformative experiences. Floating outside the spacecraft, seeing Earth 
            below - it's something that stays with you. The science we conduct during EVAs contributes significantly 
            to our understanding of space and helps prepare for future exploration. Every moment in space is an 
            opportunity to learn, and spacewalks offer a unique perspective on both the technical and human aspects 
            of spaceflight.
            """
        }
        
        if analysis.topics.contains("exploration") || analysis.topics.contains("discover") || analysis.topics.contains("science") {
            return """
            Exploration drives everything we do. The Artemis program opens up incredible possibilities for discovery. 
            We're not just going back to the Moon - we're learning how to live and work there sustainably. This 
            knowledge will be essential for future missions to Mars and beyond. As someone who's experienced 
            long-duration spaceflight, I'm excited about what we'll learn about human adaptation to deep space.
            """
        }
        
        if analysis.topics.contains("long") || analysis.topics.contains("duration") || analysis.topics.contains("328") {
            return """
            My 328-day mission on the ISS taught me so much about long-duration spaceflight - both the technical 
            aspects and the human factors. Understanding how systems evolve over time and how crew health is 
            maintained is crucial for deep space missions like Artemis II and beyond. That experience gives me 
            valuable perspective on what to expect during our journey to the Moon.
            """
        }
        
        return generateContextualResponse(
            for: Astronaut.sampleAstronauts.first(where: { $0.id == "christina-koch" }) ?? Astronaut.sampleAstronauts[0],
            userMessage: userMessage,
            analysis: analysis,
            context: context
        )
    }
    
    private func generateJeremyHansenIntelligentResponse(
        userMessage: String,
        analysis: QueryAnalysis,
        context: AstronautContext,
        relevantExpertise: [String]
    ) -> String {
        if relevantExpertise.contains("international") || analysis.topics.contains("canada") || analysis.topics.contains("partnership") {
            return """
            International collaboration is fundamental to space exploration. As a Canadian astronaut, I'm proud 
            to represent the partnership between NASA and the Canadian Space Agency. Working together, we achieve 
            far more than any single nation could alone. The Artemis Accords demonstrate our shared commitment to 
            peaceful exploration and cooperation. Canada's contributions to space exploration, from the Canadarm 
            to our role in Artemis, show what's possible through partnership.
            """
        }
        
        if analysis.topics.contains("artemis") || analysis.topics.contains("mission") {
            return """
            Artemis II represents the best of international cooperation. Multiple nations contributing expertise 
            and resources toward a common goal - returning humans to the Moon and preparing for Mars. It's a 
            privilege to be part of this global effort, and an incredible honor to be Canada's first astronaut 
            to travel to the Moon. This mission demonstrates what we can achieve when nations work together 
            toward shared exploration goals.
            """
        }
        
        if analysis.topics.contains("first") || analysis.topics.contains("canadian") {
            return """
            Being Canada's first astronaut to travel to the Moon is both an incredible honor and a responsibility. 
            It represents decades of Canadian contributions to space exploration - from the Canadarm to our 
            scientific research on the ISS. This mission demonstrates what's possible through international 
            partnership and Canada's commitment to space exploration. I'm proud to carry forward that legacy.
            """
        }
        
        return generateContextualResponse(
            for: Astronaut.sampleAstronauts.first(where: { $0.id == "jeremy-hansen" }) ?? Astronaut.sampleAstronauts[0],
            userMessage: userMessage,
            analysis: analysis,
            context: context
        )
    }
    
    /// Generate contextual response using astronaut's speaking style and information
    private func generateContextualResponse(
        for astronaut: Astronaut,
        userMessage: String,
        analysis: QueryAnalysis,
        context: AstronautContext
    ) -> String {
        // Build response using astronaut's background and speaking style
        var response = ""
        
        // Start with context-appropriate opening based on speaking style
        if context.speakingStyle.lowercased().contains("enthusiastic") {
            response += "That's a great question! "
        } else if context.speakingStyle.lowercased().contains("professional") {
            response += "I'd be happy to explain. "
        }
        
        // Reference relevant expertise
        if !context.expertiseAreas.isEmpty {
            let relevantArea = context.expertiseAreas.first { area in
                analysis.keywords.contains { keyword in
                    area.lowercased().contains(keyword)
                }
            }
            
            if let area = relevantArea {
                response += "From my experience with \(area), "
            }
        }
        
        // Generate topic-specific response
        if analysis.topics.contains("artemis") {
            response += """
            The Artemis program represents humanity's return to the Moon and our next step toward Mars. 
            Artemis II will be the first crewed mission, testing all systems before we attempt a landing. 
            It's an exciting time for space exploration!
            """
        } else if analysis.topics.contains("orion") {
            response += """
            The Orion spacecraft is our deep space vehicle, designed to carry astronauts safely to the Moon and back. 
            It has advanced life support systems and can sustain a crew for up to 21 days. 
            It's a critical component of the Artemis missions.
            """
        } else if analysis.topics.contains("sls") || analysis.topics.contains("rocket") {
            response += """
            The Space Launch System is the most powerful rocket ever built. It provides the thrust needed 
            to send Orion and its crew beyond Earth's orbit. SLS uses proven technology from the Space Shuttle 
            program, making it both powerful and reliable.
            """
        } else if analysis.topics.contains("moon") || analysis.topics.contains("lunar") {
            response += """
            The Moon is our gateway to deep space. By establishing a sustainable presence there, we'll learn 
            how to live and work on another world. This knowledge will be essential for future missions to Mars 
            and beyond.
            """
        } else {
            response += """
            That's an interesting question about space exploration. The Artemis program involves many complex 
            systems working together - from launch vehicles to spacecraft to mission operations. Every detail 
            matters for crew safety and mission success. Is there a specific aspect you'd like to learn more about?
            """
        }
        
        return response
    }
    
    private func generateGenericIntelligentResponse(userMessage: String, analysis: QueryAnalysis) -> String {
        if analysis.topics.contains("artemis") {
            return """
            The Artemis program represents humanity's return to the Moon and our next step toward Mars. 
            Artemis II will be the first crewed mission, testing all systems before we attempt a landing. 
            It's an exciting time for space exploration!
            """
        }
        return """
        That's a great question! Space exploration involves many complex systems working together. 
        From launch vehicles to spacecraft to mission operations, every detail matters for crew safety 
        and mission success. Is there a specific aspect of the Artemis program you'd like to learn more about?
        """
    }
    
    // MARK: - Core ML Support (for future model integration)
    
    /// Load the shared Core ML model
    private func loadSharedModel() async {
        guard let modelURL = Bundle.main.url(
            forResource: modelFileName.replacingOccurrences(of: ".mlmodelc", with: ""),
            withExtension: "mlmodelc"
        ) else {
            isModelAvailable = false
            return
        }
        
        do {
            let model = try MLModel(contentsOf: modelURL)
            modelCacheQueue.async { [weak self] in
                self?.sharedModel = model
                self?.isModelAvailable = true
            }
            print("Core ML model loaded successfully.")
        } catch {
            print("Failed to load Core ML model: \(error)")
            isModelAvailable = false
        }
    }
    
    /// Get the shared model (thread-safe)
    private func getSharedModel() async -> MLModel? {
        return await withCheckedContinuation { continuation in
            modelCacheQueue.async {
                continuation.resume(returning: self.sharedModel)
            }
        }
    }
    
    /// Run Core ML inference (if model is available)
    private func runCoreMLInference(model: MLModel, prompt: String, astronaut: Astronaut) async throws -> String {
        // Build enhanced prompt
        let enhancedPrompt = buildEnhancedPrompt(for: astronaut, basePrompt: prompt)
        
        // Use on-device intelligence as fallback if Core ML fails
        return generateWithOnDeviceIntelligence(for: astronaut, prompt: enhancedPrompt)
    }
    
    /// Build enhanced prompt with astronaut-specific information
    private func buildEnhancedPrompt(for astronaut: Astronaut, basePrompt: String) -> String {
        var enhancedPrompt = """
        SYSTEM PROMPT:
        
        \(astronaut.personaPrompt)
        
        ASTRONAUT BACKGROUND:
        \(astronaut.backgroundInfo)
        
        SPEAKING STYLE:
        \(astronaut.speakingStyle)
        
        IMPORTANT REMINDERS:
        - You are a simulated educational persona, not the real person
        - Only use publicly available information
        - Stay in character based on the background and speaking style above
        - Be educational and helpful
        - Respond naturally and conversationally
        
        ---
        
        """
        
        enhancedPrompt += basePrompt
        return enhancedPrompt
    }
    
    /// Extract user message from full prompt
    private func extractUserMessage(from prompt: String) -> String {
        if let userRange = prompt.range(of: "User:") {
            let afterUser = prompt[userRange.upperBound...]
            if let assistantRange = afterUser.range(of: "\n\nAssistant:") {
                return String(afterUser[..<assistantRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return String(afterUser).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return prompt
    }
}

// MARK: - Supporting Types

struct QueryAnalysis {
    let topics: [String]
    let sentiment: Double
    let questionType: QuestionType
    let keywords: [String]
}

enum QuestionType {
    case informational
    case procedural
    case explanatory
    case factual
    case general
}

struct AstronautContext {
    let name: String
    let role: String
    let backgroundKeywords: [String]
    let roleKeywords: [String]
    let expertiseAreas: [String]
    let speakingStyle: String
}

// Common words to filter out
private let commonWords: Set<String> = [
    "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
    "of", "with", "by", "from", "as", "is", "are", "was", "were", "be",
    "been", "being", "have", "has", "had", "do", "does", "did", "will",
    "would", "could", "should", "may", "might", "must", "can", "this",
    "that", "these", "those", "what", "which", "who", "whom", "whose",
    "where", "when", "why", "how", "about", "into", "through", "during"
]

enum LLMError: Error {
    case modelNotFound
    case inferenceFailed
    case invalidInput
    case tokenizationFailed
    case decodingFailed
    case foundationModelsUnavailable
}
