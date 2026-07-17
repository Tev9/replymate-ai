import 'package:flutter/material.dart';
import '../widgets/analysis_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/contact_profile_card.dart';
import '../widgets/learning_timeline_card.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';
import '../services/memory_service.dart';
import '../models/conversation_memory.dart';
import '../models/learning_event.dart';
import '../services/style_learning_service.dart';
import '../services/learning_history_service.dart';
import '../models/learning_history.dart';
import '../services/communication_analyzer.dart';
import '../models/communication_profile.dart';
import '../services/communication_profile_service.dart';
import '../widgets/communication_insights_card.dart';
import '../services/communication_statistics_service.dart';
import '../services/communication_profile_builder.dart';
import '../models/communication_statistics.dart';
import '../widgets/communication_statistics_card.dart';
import '../services/learning_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTone = 'Professional';
  String selectedPlatform = 'WhatsApp';
  String relationshipType = 'General';
  List<String> generatedReplies = [];
  bool isLoading = false;
  String writingStyle = '';
  String replyLength = 'Medium';
  String conversationType = '';
  String conversationMood = '';
  String conversationAdvice = '';

  String memoryStatus = '';

  List<LearningHistory> loadedHistory = [];

  ConversationMemory? loadedMemory;
  CommunicationProfile? loadedCommunicationProfile;
  CommunicationStatistics? loadedCommunicationStatistics;

  int bestReplyIndex = -1;
  String bestReplyReason = '';

  List<int> replyScores = [];

  final TextEditingController messageController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController writingStyleController = TextEditingController();

  final AiService aiService = AiService();
  final MemoryService memoryService = MemoryService();
  final StyleLearningService styleLearningService = StyleLearningService();

  final CommunicationAnalyzer communicationAnalyzer = CommunicationAnalyzer();
  final CommunicationProfileService communicationProfileService =
      CommunicationProfileService();
  final CommunicationStatisticsService communicationStatisticsService =
      CommunicationStatisticsService();

  final CommunicationProfileBuilder communicationProfileBuilder =
      CommunicationProfileBuilder();

  late final LearningManager learningManager;

  final LearningHistoryService learningHistoryService =
      LearningHistoryService();

  @override
  void initState() {
    super.initState();

    learningManager = LearningManager(
      styleLearningService: styleLearningService,
      communicationAnalyzer: communicationAnalyzer,
      communicationStatisticsService: communicationStatisticsService,
      communicationProfileBuilder: communicationProfileBuilder,
      communicationProfileService: communicationProfileService,
      memoryService: memoryService,
      learningHistoryService: learningHistoryService,
    );
  }

  Future<void> generateReply() async {
    String message = messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        generatedReplies = ['Please enter a message first.'];
      });
      return;
    }

    setState(() {
      isLoading = true;
      generatedReplies = [];

      conversationType = '';
      conversationMood = '';
      conversationAdvice = '';

      bestReplyIndex = -1;
      bestReplyReason = '';

      replyScores = [];
    });

    final analysis = await aiService.analyzeConversation(
      message: message,
    );

    setState(() {
      conversationType = analysis['type'];
      conversationMood = analysis['mood'];
      conversationAdvice = analysis['advice'];
    });

    final replyData = await aiService.generateReplies(
      message: message,
      tone: selectedTone,
      length: replyLength,
      writingStyle: writingStyle,
      platform: selectedPlatform,
      relationshipType: relationshipType,
      aiConfidence: loadedMemory?.aiConfidence ?? 0,
      messagesLearned: loadedMemory?.messagesLearned ?? 0,
      greeting: loadedCommunicationProfile?.greeting ?? 'Not learned yet',
      closing: loadedCommunicationProfile?.closing ?? 'Not learned yet',
      favoriteWords: loadedCommunicationProfile?.favoriteWords ?? [],
      favoriteEmojis: loadedCommunicationProfile?.favoriteEmojis ?? [],
      sentenceStyle:
          loadedCommunicationProfile?.sentenceStyle ?? 'Not learned yet',
    );

    setState(() {
      generatedReplies = List<String>.from(replyData['replies']);
      replyScores = List<int>.from(replyData['scores'] ?? []);
      bestReplyIndex = replyData['bestReply'] ?? -1;
      bestReplyReason = replyData['reason'] ?? '';
      isLoading = false;
    });
  }

  Future<void> rewriteReply(int index, String instruction) async {
    final oldReply = generatedReplies[index];

    setState(() {
      generatedReplies[index] = 'Rewriting...';
    });

    final newReply = await aiService.rewriteReply(
      reply: oldReply,
      instruction: instruction,
      platform: selectedPlatform,
      writingStyle: writingStyle,
    );

    setState(() {
      generatedReplies[index] = newReply;
    });

    await learnFromChosenReply(
      newReply,
      LearningEvent.rewrittenReply,
    );
  }

  Future<void> showCustomRewriteDialog(int index) async {
    final TextEditingController customController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Rewrite'),
          content: TextField(
            controller: customController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Example: Make it warmer and shorter',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final instruction = customController.text.trim();

                if (instruction.isNotEmpty) {
                  Navigator.pop(context);
                  rewriteReply(index, instruction);
                }
              },
              child: const Text('Rewrite'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveContactMemory() async {
    final displayName = contactController.text.trim();
    final contactName = displayName.toLowerCase();

    if (contactName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a contact name first'),
        ),
      );
      return;
    }

    final currentMemory = await memoryService.loadMemory(contactName);
    final messagesLearned = (currentMemory?.messagesLearned ?? 0) + 1;

    await learningManager.saveMemory(
      contactName: contactName,
      displayName: displayName,
      writingStyle: writingStyle.isEmpty ? 'Not provided yet' : writingStyle,
      preferredTone: selectedTone,
      relationshipType: relationshipType,
      preferredPlatform: selectedPlatform,
      preferredReplyLength: replyLength,
      messagesLearned: messagesLearned,
      currentConfidence: currentMemory?.aiConfidence ?? 0,
      event: LearningEvent.newContact,
    );

    await learningManager.addLearningHistory(
      contactName: contactName,
      title: '👤 Contact Saved',
      description: 'ReplyMate saved this contact profile and preferences.',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Memory saved for $displayName'),
      ),
    );
  }

  Future<void> loadContactMemory() async {
    final displayName = contactController.text.trim();
    final contactName = displayName.toLowerCase();

    if (contactName.isEmpty) return;

    final result = await learningManager.loadContact(contactName);

    if (result == null) {
      setState(() {
        loadedMemory = null;
        loadedHistory = [];
        loadedCommunicationProfile = null;
        loadedCommunicationStatistics = null;

        memoryStatus =
            '👤 New contact. ReplyMate will start learning your style.';
      });
      return;
    }

    setState(() {
      loadedMemory = result.memory;
      loadedHistory = result.history;
      loadedCommunicationProfile = result.profile;
      loadedCommunicationStatistics = result.statistics;

      writingStyle = result.writingStyle;
      writingStyleController.text = result.writingStyle;

      selectedTone = result.memory!.preferredTone;
      relationshipType = result.memory!.relationshipType;
      selectedPlatform = result.memory!.preferredPlatform;
      replyLength = result.memory!.preferredReplyLength;

      memoryStatus = '🧠 Memory loaded for $displayName';
    });
  }

  Future<void> learnFromChosenReply(
    String reply,
    LearningEvent event,
  ) async {
    final displayName = contactController.text.trim();
    final contactName = displayName.toLowerCase();

    if (contactName.isEmpty) {
      return;
    }

    final learningResult = await learningManager.learnFromReply(
      contactName: contactName,
      displayName: displayName,
      reply: reply,
      preferredTone: selectedTone,
      relationshipType: relationshipType,
      preferredPlatform: selectedPlatform,
      preferredReplyLength: replyLength,
      event: event,
    );

    if (!mounted) return;

    setState(() {
      writingStyle = learningResult.writingStyle;
      writingStyleController.text = learningResult.writingStyle;

      loadedMemory = learningResult.memory;
      loadedHistory = learningResult.history;
      loadedCommunicationProfile = learningResult.profile;
      loadedCommunicationStatistics = learningResult.statistics;

      memoryStatus = '🧠 Learned from your chosen reply';
    });
  }

  Widget toneButton(String title) {
    final bool isSelected = selectedTone == title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurple : Colors.grey.shade900,
          ),
          onPressed: () {
            setState(() {
              selectedTone = title;
            });
          },
          child: Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget platformButton(String title) {
    final bool isSelected = selectedPlatform == title;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurple : Colors.grey.shade900,
          ),
          onPressed: () {
            setState(() {
              selectedPlatform = title;
            });
          },
          child: Text(title),
        ),
      ),
    );
  }

  Widget lengthButton(String title) {
    final bool isSelected = replyLength == title;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurple : Colors.grey.shade900,
          ),
          onPressed: () {
            setState(() {
              replyLength = title;
            });
          },
          child: Text(title),
        ),
      ),
    );
  }

  Widget relationshipButton(String title) {
    final bool isSelected = relationshipType == title;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? Colors.deepPurple : Colors.grey.shade900,
          ),
          onPressed: () {
            setState(() {
              relationshipType = title;
            });
          },
          child: Text(title),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReplyMate AI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Smart replies for every chat',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: contactController,
                onEditingComplete: () {
                  loadContactMemory();
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'e.g. Sarah ❤️',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Paste message or conversation...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: writingStyleController,
                onChanged: (value) {
                  writingStyle = value;
                },
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Optional: Paste examples of how you normally write...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              toneButton('Professional'),
              toneButton('Friendly'),
              toneButton('Funny'),
              toneButton('Romantic'),
              const SizedBox(height: 20),
              const Text(
                'Relationship',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  relationshipButton('General'),
                  relationshipButton('Friend'),
                  relationshipButton('Family'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  relationshipButton('Partner'),
                  relationshipButton('Boss'),
                  relationshipButton('Client'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Platform',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  platformButton('WhatsApp'),
                  platformButton('SMS'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  platformButton('Email'),
                  platformButton('LinkedIn'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Reply Length',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  lengthButton('Short'),
                  lengthButton('Medium'),
                  lengthButton('Long'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: generateReply,
                  child: const Text(
                    'Generate Reply',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (memoryStatus.isNotEmpty)
                Card(
                  color: Colors.blueGrey.shade900,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      memoryStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (loadedMemory != null) ...[
                ContactProfileCard(
                  memory: loadedMemory!,
                ),
                if (loadedCommunicationProfile != null) ...[
                  const SizedBox(height: 16),
                  CommunicationInsightsCard(
                    profile: loadedCommunicationProfile!,
                  ),
                ],
                if (loadedCommunicationStatistics != null) ...[
                  const SizedBox(height: 16),
                  CommunicationStatisticsCard(
                    statistics: loadedCommunicationStatistics!,
                  ),
                ],
                const SizedBox(height: 16),
                LearningTimelineCard(
                  history: loadedHistory,
                ),
              ],
              const SizedBox(height: 16),
              const Divider(),
              if (conversationType.isNotEmpty)
                AnalysisCard(
                  type: conversationType,
                  mood: conversationMood,
                  advice: conversationAdvice,
                ),
              const SizedBox(height: 16),
              if (bestReplyIndex >= 0)
                RecommendationCard(
                  bestReplyIndex: bestReplyIndex,
                  reason: bestReplyReason,
                ),
              const SizedBox(height: 16),
              Text(
                'AI Suggestions',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              isLoading
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('Generating AI reply...'),
                        ],
                      ),
                    )
                  : generatedReplies.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('AI replies will appear here.'),
                          ),
                        )
                      : Column(
                          children:
                              generatedReplies.asMap().entries.map((entry) {
                            final index = entry.key + 1;
                            final reply = entry.value;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Suggestion $index',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (replyScores.length >= index)
                                      Text(
                                        '⭐ ${replyScores[index - 1]}/100',
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(reply),
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    if (value == 'copy') {
                                      final messenger =
                                          ScaffoldMessenger.of(context);

                                      Clipboard.setData(
                                        ClipboardData(text: reply),
                                      );

                                      await learnFromChosenReply(
                                        reply,
                                        LearningEvent.copiedReply,
                                      );

                                      if (!mounted) return;

                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Reply copied and learned'),
                                        ),
                                      );
                                    } else if (value == 'custom') {
                                      showCustomRewriteDialog(index - 1);
                                    } else {
                                      rewriteReply(index - 1, value);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'copy',
                                      child: Text('Copy'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Make it shorter',
                                      child: Text('Shorter'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Make it longer',
                                      child: Text('Longer'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Make it funnier',
                                      child: Text('Funny'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Make it more professional',
                                      child: Text('Professional'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'custom',
                                      child: Text('Custom Rewrite'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
