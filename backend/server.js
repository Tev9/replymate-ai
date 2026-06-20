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
    const { message, tone, length, writingStyle } = req.body;

    const prompt = `
    You are ReplyMate AI.

    Generate exactly 3 different reply suggestions.

    Message to reply to:
    ${message}

    Tone:
    ${tone}

    Reply length:
    ${length}

    User writing style:
    ${writingStyle}

    Rules:
    - Return ONLY valid JSON.
    - Do not include markdown.
    - Do not include numbering.
    - Use this exact format:
    {
      "replies": [
        "reply one",
        "reply two",
        "reply three"
      ]
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
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      error: 'Failed to generate reply',
    });
  }
});

const PORT = 3001;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});