// This file contains the hardcoded educational content for offline access.
// It reflects Trish's mission to empower users with "lived experience" strategies.

class Article {
  final String title;
  final String summary;
  final String content; // Supports simple formatting like \n for new lines
  final String iconName; // Mapped in UI to actual Icons

  const Article({
    required this.title,
    required this.summary,
    required this.content,
    required this.iconName,
  });
}

const List<Article> kOfflineArticles = [
  Article(
    title: "What is Gaslighting?",
    summary: "Recognize when someone is making you question your own reality.",
    iconName: "psychology",
    content: """
Gaslighting is a form of psychological manipulation where a person seeks to sow seeds of doubt in a targeted individual or members of a group, making them question their own memory, perception, or sanity.

**Key Signs:**
1. **Denial:** They flatly deny saying or doing things you know they did.
2. **Shifting Blame:** "I wouldn't have to yell if you weren't so sensitive."
3. **Trivializing:** They make your feelings seem unimportant or irrational.

**How to Counter It:**
* **Write it down:** Keep a journal of events immediately after they happen.
* **Trust your gut:** If something feels 'off', it usually is.
* **Disengage:** Do not try to argue facts with a gaslighter; they are not interested in the truth.
""",
  ),
  Article(
    title: "The 'DARVO' Technique",
    summary: "Deny, Attack, and Reverse Victim and Offender.",
    iconName: "shield",
    content: """
DARVO is a reaction often used by perpetrators of wrongdoing (especially sexual offenders or abusers) when held accountable.

**The Stages:**
1. **Deny:** "I never did that."
2. **Attack:** "You are crazy/obsessed/trying to ruin me."
3. **Reverse Victim & Offender:** "I am the real victim here because you are accusing me."

**Response Strategy:**
Recognize the pattern. When you see them shift from "I didn't do it" to "You are attacking me," stop engaging. Name the behavior to yourself: "This is DARVO." Do not defend yourself against the attacks; stay focused on the original issue or end the conversation.
""",
  ),
  Article(
    title: "The Grey Rock Method",
    summary: "Becoming uninteresting to toxic people.",
    iconName: "rock",
    content: """
The Grey Rock method is a strategy for dealing with narcissists, sociopaths, and other toxic people. The goal is to make yourself so boring and unresponsive that they lose interest in you.

**How to do it:**
* **Neutral Responses:** Use "Mmhmm," "Okay," or "I see."
* **No Emotion:** Do not show anger, tears, or frustration.
* **Short Answers:** Avoid sharing personal details or opinions.
* **Be Boring:** If asked what you did today, say "Just laundry."

**Why it works:**
Toxic people feed on drama and emotional reaction (supply). When you cut off the supply, they often move on to a new target.
""",
  ),
  Article(
    title: "Setting Boundaries",
    summary: "Clear lines that define what you will and will not tolerate.",
    iconName: "fence",
    content: """
Boundaries are not about controlling others; they are about controlling what you allow in your life.

**The Formula:**
"If you [behavior], then I will [action]."

**Examples:**
* "If you continue to raise your voice, I will leave the room."
* "I will not discuss my finances with you. If you bring it up, I will hang up."

**The Hard Part:**
The boundary is useless if you do not follow through with the consequence. You must be consistent.
""",
  ),
];
