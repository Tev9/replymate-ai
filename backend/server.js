require('dotenv').config();

const express = require('express');
const cors = require('cors');
const OpenAI = require('openai');

const app = express();

app.use(cors());
app.use(express.json());

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

app.get('/', (req, res) => {
  res.send('ReplyMate AI Backend Running');
});

app.post('/generate-replies', async (req, res) => {
  try {
    const {
      message,
      tone,
      length,
      writingStyle,
      platform,
      relationshipType,
    } = req.body;

    const prompt = `
    You are ReplyMate AI.

    Generate exactly 3 different reply suggestions.

    Message or conversation to reply to:
    ${message}

    Tone:
    ${tone}

    Reply length:
    ${length}

    User writing style:
    ${writingStyle}

    Platform:
    ${platform}

    Relationship:
    ${relationshipType}

    Platform rules:
    - WhatsApp: casual, conversational, emojis allowed.
    - SMS: very short and direct.
    - Email: professional, complete sentences.
    - LinkedIn: professional networking style.

    Relationship rules:
    - General: balanced and natural.
    - Friend: casual, relaxed, friendly.
    - Family: warm, caring, respectful.
    - Partner: affectionate, warm, emotionally aware.
    - Boss: professional, respectful, concise.
    - Client: polite, business-focused, trustworthy.

    Rules:
    - Return ONLY valid JSON.
    - Do not include markdown.
    - Do not include numbering.
    - If the input is a conversation, understand the context and reply as "Me".
    - Give each reply a score from 0 to 100.
    - Higher scores should indicate replies that are more likely to receive a positive response.
    - bestReply must be the ZERO-BASED index of the best reply.
    - 0 = first reply, 1 = second reply, 2 = third reply.
    - Use this exact format:

    {
      "replies": [
        "reply one",
        "reply two",
        "reply three"
      ],
      "scores": [95, 88, 79],
      "bestReply": 0,
      "reason": "Explain why the first reply is the strongest."
    }
    `;

    const response = await openai.chat.completions.create({
      model: 'gpt-4.1-mini',
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0.8,
    });

    const content = response.choices[0].message.content;

    const parsed = JSON.parse(content);

    res.json({
      replies: parsed.replies,
      scores: parsed.scores,
      bestReply: parsed.bestReply,
      reason: parsed.reason,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: 'Failed to generate reply',
    });
  }
});

app.post('/rewrite-reply', async (req, res) => {
  try {
    const { reply, instruction, platform, writingStyle } = req.body;

    const prompt = `
You are ReplyMate AI.

Rewrite this reply:

${reply}

Instruction:
${instruction}

Platform:
${platform}

User writing style:
${writingStyle}

Rules:
- Return ONLY valid JSON.
- Do not include markdown.
- Use this exact format:
{
  "reply": "rewritten reply here"
}
`;

    const response = await openai.chat.completions.create({
      model: 'gpt-4.1-mini',
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0.8,
    });

    const content = response.choices[0].message.content;
    const parsed = JSON.parse(content);

    res.json({
      reply: parsed.reply,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: 'Failed to rewrite reply',
    });
  }
});

app.post('/analyze-conversation', async (req, res) => {
  try {
    const { message } = req.body;

    const prompt = `
You are ReplyMate AI.

Analyze this message or conversation:

${message}

Return ONLY valid JSON.
Do not include markdown.

Use this exact format:
{
  "type": "Conversation type here",
  "mood": "Detected mood here",
  "advice": "Short helpful advice here"
}
`;

    const response = await openai.chat.completions.create({
      model: 'gpt-4.1-mini',
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
      temperature: 0.5,
    });

    const content = response.choices[0].message.content;
    const parsed = JSON.parse(content);

    res.json({
      type: parsed.type,
      mood: parsed.mood,
      advice: parsed.advice,
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: 'Failed to analyze conversation',
    });
  }
});

const PORT = 3001;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});