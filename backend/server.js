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
Message:
${message}

Tone:
${tone}

Reply Length:
${length}

Writing Style:
${writingStyle}

Generate 3 different reply suggestions.
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

    const reply = response.choices[0].message.content;

    res.json({
      replies: [reply],
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