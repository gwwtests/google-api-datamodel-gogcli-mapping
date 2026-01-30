# Gmail Priority Inbox and Important Label Algorithm

**Primary Source**: https://research.google.com/pubs/archive/36955.pdf
**Authors**: Douglas Aberdeen, Ondrej Pacovsky (Google Research)
**Additional Sources**:

* http://mikhailian.mova.org/node/256
* https://www.newmail.ai/blog/gmail-ai-smart-sorting-organization
* https://getemil.io/guides/master-the-gmail-priority-inbox/

**Retrieved**: 2026-01-30

## Overview

Gmail's Priority Inbox uses machine learning algorithms to automatically identify important emails based on user reading patterns, sender frequency, and keywords, displaying them in a separate section.

## The IMPORTANT Label

In the Gmail API, important messages are marked with the `IMPORTANT` system label. This label is automatically applied by Gmail's machine learning model.

## Machine Learning Algorithm

Gmail Priority Inbox uses a per-user statistical model to predict how likely users are to act on incoming mail, helping alleviate information overload.

### Core Algorithm

* **Model Type**: Logistic regression
* **Output**: Smooth ranking function with buckets containing ratios of important to unimportant messages that follow the log-odds curve
* **Accuracy**: Approximately 80 ± 5% accuracy on control groups based on implicit importance definition
* **Personalization**: Per-user models significantly outperform global models

### Key Factors Analyzed

**Social Features**: Based on the degree of interaction between sender and recipient, e.g., the percentage of a sender's mail that is read by the recipient.

**User Behavior Prediction**: Importance ground truth is based on how the user interacts with a mail after delivery, with the goal to predict the probability that the user will interact with the mail within a specified timeframe.

**Engagement Signals**:

* Which emails the user opens
* Which emails the user replies to
* Which emails the user ignores
* Sender frequency
* Keywords and content
* Semantic context

## Performance Impact

A study of Google employees found that Priority Inbox users:

* Spent 6% less time reading mail overall
* Spent 13% less time reading unimportant mail

## Technical Implementation

* **Real-time ranking**: Processes messages as they arrive
* **Near-online updating**: Updates millions of models per day
* **Storage**: Gmail makes extensive use of Bigtable to store and serve models and collect mail training data
* **Learning Loop**: Every action the user takes improves future accuracy

## Personalization Levels

When comparing different approaches:

* **Global models**: Basic shared model across users
* **Personalized models**: Individual user models
* **Personalized models with personalized thresholds**: Highest accuracy, significant reduction in mistakes

## Priority Inbox Organization

Gmail's Priority Inbox categorizes incoming emails into three sections:

1. **Important and unread** - Messages predicted to be important
2. **Starred** - Messages manually marked by the user
3. **Everything else** - Other messages

## 2026 AI Updates

In March 2025, Gmail replaced its strictly chronological email search with an AI relevance model. Rather than displaying results by date received, Gmail now defaults to "Most Relevant" sorting, surfacing messages based on:

* Engagement signals
* Sender frequency
* Semantic context

In early 2026, Gmail unveiled its AI Inbox feature, designed to provide personalized briefings. Blake Barnes, VP of Product at Gmail, explained: "With email volume at an all-time high, managing your inbox and the flow of information has become as important as the emails themselves."

## API Implications

The Gmail API provides:

* The `IMPORTANT` system label on messages Gmail's algorithm deems important
* No direct access to the importance score or probability
* No ability to manually trigger re-scoring
* No access to the underlying machine learning features or weights

Applications can:

* Query for messages with `labelIds` containing `"IMPORTANT"`
* Add or remove the `IMPORTANT` label manually (provides user feedback to the algorithm)
* Filter messages based on importance

## Search Operators

In Gmail's web interface and API queries:

* `is:important` - Find messages marked as important
* `is:starred` - Find starred messages
* `label:important` - Alternative syntax for important messages
