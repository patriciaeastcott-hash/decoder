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
    title: "Love Bombing",
    summary:
        "Lavish displays of attention and affection used to create an intense, premature connection.",
    iconName: "favorite",
    content: """
Love bombing is an attempt to influence someone through lavish displays of attention and affection, often at the beginning of a relationship. It creates an intense emotional connection quickly, making it harder to recognize problematic behavior later.

**Signs:**
* Excessive compliments and flattery from the start.
* Constant communication and demands for your time.
* Grand romantic gestures very early in the relationship.
* Pressure to commit or move fast ("I've never felt this way before").
* Making you feel like you're soulmates immediately.
* Overwhelming gifts or attention that feels too much too soon.

**Why It Works:**
Love bombing exploits our natural desire for connection and validation. The intense positive attention triggers dopamine release, creating an addictive cycle. When the behavior inevitably shifts, you're already emotionally invested and may blame yourself for the change.

**How to Respond:**
* Recognize that healthy relationships develop gradually.
* Set boundaries around pacing and personal time.
* Trust your instincts if something feels overwhelming.
* Don't feel guilty for wanting to slow down.
* Observe how they react when you set boundaries.

**Healthy Alternative:**
Genuine affection builds over time as people truly get to know each other. Healthy partners respect your need for independence and don't pressure you to abandon other relationships or commitments.
""",
  ),
  Article(
    title: "Triangulation",
    summary:
        "Bringing a third party into a conflict to create confusion and insecurity.",
    iconName: "share",
    content: """
Triangulation occurs when someone brings a third party into a two-person conflict or relationship to manipulate the dynamic. This creates confusion, competition, and insecurity while allowing the manipulator to avoid direct communication.

**Signs:**
* Comparing you unfavorably to others ("They never complain like you do").
* Sharing private relationship details with others to get allies.
* Pitting people against each other.
* Using "everyone thinks" or "people have told me" without specifics.
* Creating competition between friends or family members.
* Refusing to address issues directly, always involving others.

**Why It Works:**
Triangulation divides and conquers. It makes you feel isolated, questioning your perception, and competing for approval. The manipulator maintains control by being the central point of all communication.

**How to Respond:**
* Insist on direct communication: "Let's discuss this just between us."
* Don't engage in conversations about absent third parties.
* Verify information directly with the people mentioned.
* Refuse to compete for someone's attention or approval.
* Set boundaries: "I'm not comfortable discussing this with others involved."

**Healthy Alternative:**
Healthy relationships involve direct communication. When conflicts arise, both parties discuss issues privately and respectfully without recruiting others to take sides.
""",
  ),
  Article(
    title: "Stonewalling",
    summary:
        "Refusal to communicate or cooperate, often using silence as punishment.",
    iconName: "block",
    content: """
Stonewalling is the refusal to communicate or cooperate, typically through silence, withdrawal, or shutting down during conflict. It's a form of emotional withdrawal that leaves the other person feeling unheard and powerless.

**Signs:**
* Complete silence or monosyllabic responses during discussions.
* Physically turning away or leaving without explanation.
* Refusing to acknowledge someone's presence.
* Acting busy to avoid conversation.
* Changing the subject or pretending not to hear.
* Extended periods of silent treatment as punishment.

**Why It Works:**
Stonewalling is a power move that creates anxiety and desperation in the other person. The silence becomes unbearable, often causing the stonewalled person to either back down or become increasingly distressed.

**How to Respond:**
* Name the behavior: "I notice you've stopped responding."
* Suggest a time to talk: "Let's discuss this in an hour when we're calmer."
* Don't chase or beg for communication.
* Set a boundary: "I need us to communicate about this. If you need space, please tell me when we can talk."
* Take care of yourself emotionally during the silence.

**Healthy Alternative:**
Taking a break during heated discussions is healthy, but it should be communicated: "I need 30 minutes to calm down, then let's talk." Both parties agree to return to the conversation.
""",
  ),
  Article(
    title: "Projection",
    summary:
        "Attributing one's own unacceptable thoughts or behaviors to another person.",
    iconName: "switch_video",
    content: """
Projection occurs when someone attributes their own unacceptable thoughts, feelings, or behaviors to another person. It's a defense mechanism that allows them to avoid taking responsibility while making you feel guilty or defensive.

**Signs:**
* Accusing you of things they're actually doing (cheating, lying).
* Attributing their feelings to you ("You're angry" when they're angry).
* Criticizing you for traits they possess.
* Accusing you of manipulation while manipulating you.
* Claiming you don't trust them when they're untrustworthy.
* Saying you're too sensitive when they're being defensive.

**Why It Works:**
Projection shifts the focus from their behavior to yours, putting you on the defensive. It's disorienting because you end up defending yourself against accusations that don't match your reality.

**How to Respond:**
* Don't immediately defend yourself—pause and assess.
* Consider whether the accusation fits them better than you.
* State your reality calmly: "That's not accurate. I haven't done that."
* Don't absorb their emotions or take ownership of their issues.
* Maintain your sense of self and trust your own perceptions.

**Healthy Alternative:**
Healthy people take responsibility for their own feelings and behaviors. They use "I" statements and acknowledge their own role in conflicts.
""",
  ),
  Article(
    title: "Flying Monkeys",
    summary:
        "People recruited by a manipulator to harass or persuade you on their behalf.",
    iconName: "group",
    content: """
Flying monkeys are people who do the bidding of a manipulator, often without realizing they're being used. The manipulator recruits these individuals to harass, persuade, spy on, or gaslight their target on their behalf.

**Signs:**
* Friends or family suddenly bringing up issues on someone else's behalf.
* People pressuring you to reconcile or "give them another chance."
* Others sharing information about you back to the manipulator.
* Receiving messages like "They really miss you" or "They're so hurt."
* People who weren't present suddenly having opinions about your conflicts.
* Feeling ganged up on by multiple people at once.

**Why It Works:**
Flying monkeys add social pressure and make you feel isolated or wrong. When multiple people echo the same message, it's easier to doubt yourself and question your boundaries.

**How to Respond:**
* Maintain your boundaries regardless of who delivers the message.
* Don't share personal information with people who might report back.
* State clearly: "I appreciate your concern, but this is between us."
* Recognize that these people may be receiving a distorted story.
* Don't justify or explain yourself to third parties.

**Healthy Alternative:**
Healthy people respect that conflicts are between the involved parties. They don't recruit others to fight their battles or pressure people on their behalf.
""",
  ),
  Article(
    title: "Future Faking",
    summary:
        "Making false promises about the future to get what they want in the present.",
    iconName: "schedule",
    content: """
Future faking involves making false promises about the future to get what someone wants in the present. The manipulator paints elaborate pictures of a future together with no intention of following through.

**Signs:**
* Grand promises that never materialize (trips, marriage, moving in).
* Detailed future plans that always get postponed.
* Using future promises to excuse current bad behavior.
* Talking about "someday" to avoid "today" commitments.
* Making plans to get you to stay, then nothing changes.
* Promises that conveniently require you to sacrifice something now.

**Why It Works:**
Future faking keeps you invested and hopeful while accepting unacceptable present circumstances. You tolerate bad behavior now because you believe it's temporary and the promised future is coming.

**How to Respond:**
* Pay attention to actions, not words.
* Notice if promises are used to deflect from current problems.
* Set timeframes: "Let's discuss concrete steps and timelines."
* Don't sacrifice present needs for promised future rewards.
* Track patterns of promises made vs. promises kept.

**Healthy Alternative:**
Healthy partners make realistic plans together and follow through. They take concrete steps toward shared goals and don't use future promises to manipulate present behavior.
""",
  ),
  Article(
    title: "Word Salad",
    summary:
        "Circular, confusing, or nonsensical language designed to exhaust you.",
    iconName: "blur_on",
    content: """
Word salad is a communication tactic where someone responds with circular, confusing, contradictory, or nonsensical language. It's designed to confuse, exhaust, and derail productive conversation.

**Signs:**
* Long rambling responses that don't answer the question.
* Contradicting themselves within the same conversation.
* Bringing up unrelated topics to derail discussion.
* Using complex language that sounds meaningful but says nothing.
* Circular logic that goes nowhere.
* Leaving conversations feeling more confused than when you started.

**Why It Works:**
Word salad exhausts and confuses you. You become so focused on trying to understand or follow their logic that you forget the original issue. It also makes you look unreasonable if you keep pressing for clarity.

**How to Respond:**
* Bring the conversation back: "That doesn't answer my question."
* Ask for clarity: "Can you please give me a direct yes or no?"
* Don't try to parse nonsensical logic.
* State your point clearly and end the conversation if it continues.
* Consider using written communication for important topics.

**Healthy Alternative:**
Healthy communication is clear, direct, and stays on topic. Both parties work toward mutual understanding, not confusion.
""",
  ),
  Article(
    title: "Hoovering",
    summary:
        "Attempts to 'suck' you back into a relationship after you've pulled away.",
    iconName: "cyclone",
    content: """
Hoovering is an attempt to "suck" someone back into a relationship after a breakup or period of no contact. Like a vacuum cleaner (Hoover brand), the person tries to pull you back in through various tactics.

**Signs:**
* Sudden contact after silence (texts, calls, showing up).
* Promises that "everything will be different this time."
* Dramatic declarations of change or love.
* Reminders of good times or inside jokes.
* Emergencies or crises that require your help.
* Apologies followed by explanations that minimize their behavior.

**Why It Works:**
Hoovering exploits your emotional attachment and hope. The good memories flood back, and you want to believe they've changed. The intermittent reinforcement makes reconciliation feel precious.

**How to Respond:**
* Maintain no contact if that's what you chose.
* Remember why you left, not just the good times.
* Don't respond to breadcrumbs or test the waters.
* Block communication channels if needed.
* Talk to supportive friends who will remind you of reality.

**Healthy Alternative:**
If someone genuinely wants to reconcile, they respect your need for space, take concrete actions to address problems, and don't use manipulation to force contact.
""",
  ),
  Article(
    title: "Reactive Abuse",
    summary:
        "Provoking you until you snap, then blaming you for your reaction.",
    iconName: "flash_on",
    content: """
Reactive abuse occurs when someone who is being abused reacts with their own abusive behavior. The abuser then uses this reaction to claim that their victim is actually the abusive one, or that the abuse is mutual.

**Signs:**
* Being pushed to your breaking point, then responding badly.
* Your reaction being used as proof you're the problem.
* Feeling like you're becoming someone you don't recognize.
* Being baited into arguments, then blamed for arguing.
* Your emotional responses being labeled as "crazy" or "abusive."
* Having your justified anger reframed as the real issue.

**Why It Works:**
Reactive abuse allows the abuser to play victim and makes you question yourself. You feel guilty for your reaction, even though it was caused by sustained mistreatment. It also discredits you to others.

**How to Respond:**
* Recognize the pattern of provocation and reaction.
* Understand that being driven to react doesn't make you the abuser.
* Remove yourself from situations before reaching your breaking point.
* Don't engage in circular arguments designed to provoke you.
* Document patterns to maintain clarity about what's happening.

**Healthy Alternative:**
Healthy relationships don't involve deliberate provocation. Both people take responsibility for their behavior and work to de-escalate conflict, not intensify it.
""",
  ),
  Article(
    title: "Trauma Bonding",
    summary:
        "A strong emotional attachment formed through cycles of abuse and kindness.",
    iconName: "link",
    content: """
Trauma bonding is a strong emotional attachment that develops between an abused person and their abuser. It occurs through cycles of abuse, devaluation, and positive reinforcement, creating an addiction-like bond.

**Signs:**
* Feeling unable to leave despite knowing the relationship is harmful.
* Making excuses for their behavior to yourself and others.
* Feeling more attached after incidents of mistreatment.
* Experiencing intense highs and lows in the relationship.
* Defending them to people who express concern.
* Returns repeatedly despite promises to yourself to leave.

**Why It Works:**
Trauma bonds form through intermittent reinforcement—unpredictable cycles of kindness and cruelty. This creates an addiction similar to gambling, where the unpredictable rewards create stronger attachment than consistent kindness would.

**How to Respond:**
* Recognize that these feelings are a result of abuse, not love.
* Understand that trauma bonds feel different from healthy attachment.
* Seek professional support to understand and break the pattern.
* Establish no contact to begin healing.
* Be patient with yourself—these bonds take time to break.

**Healthy Alternative:**
Healthy bonds form through consistent trust, respect, and mutual care. You feel secure, not anxious. The relationship adds to your life rather than consuming it.
""",
  ),
  Article(
    title: "Breadcrumbing",
    summary:
        "Giving just enough attention to keep you interested without committing.",
    iconName: "grain",
    content: """
Breadcrumbing involves giving someone just enough attention to keep them interested, but never enough to build a real relationship. Like leaving a trail of breadcrumbs, the person keeps you following without reaching any destination.

**Signs:**
* Inconsistent communication—disappearing then reappearing.
* Flirty messages but no concrete plans.
* Keeping you interested but never committing.
* Late-night texts but no daytime effort.
* Vague promises about getting together "sometime."
* Enough contact to prevent you from moving on.

**Why It Works:**
Breadcrumbing keeps you hoping and waiting. The intermittent attention creates anticipation and keeps you emotionally invested without the other person having to invest much effort or commitment.

**How to Respond:**
* Recognize the pattern of minimal effort.
* Stop being available for last-minute or low-effort contact.
* Ask for what you want: "I'd like to make concrete plans."
* Notice if they step up or make excuses.
* Don't settle for breadcrumbs when you deserve the whole meal.

**Healthy Alternative:**
People who genuinely want to connect with you make time, make plans, and show consistent interest. Their effort matches their words.
""",
  ),
  Article(
    title: "Scapegoating",
    summary:
        "Unfairly blaming one person for the problems of a group or family.",
    iconName: "person_remove",
    content: """
Scapegoating occurs when one person or group is unfairly blamed for problems, often to deflect from the real issues or to maintain a dysfunctional system. The scapegoat becomes the repository for everyone else's faults.

**Signs:**
* Being blamed for things that aren't your fault or responsibility.
* Your presence somehow "causing" others to misbehave.
* Being the one who "ruins" family events by existing.
* Others bonding over complaints about you.
* Your reasonable reactions being framed as the problem.
* Being treated as fundamentally different or wrong.

**Why It Works:**
Scapegoating allows families or groups to avoid addressing real problems by focusing blame on one person. It maintains the status quo and gives others someone to feel superior to.

**How to Respond:**
* Recognize you're not responsible for others' dysfunction.
* Set boundaries around accepting blame that isn't yours.
* Build relationships with people who see you clearly.
* Consider limiting contact with systems that scapegoat you.
* Don't try to prove you're not the problem—they need to believe it.

**Healthy Alternative:**
Healthy families and groups take responsibility for their own behavior and emotions. Problems are addressed directly rather than blamed on one person.
""",
  ),
  Article(
    title: "Moving the Goalposts",
    summary:
        "Changing the requirements for success after you've already met them.",
    iconName: "sports_score",
    content: """
Moving the goalposts means changing the requirements or standards after you've met them. No matter what you do, it's never quite enough because the target keeps shifting.

**Signs:**
* Achieving what was asked, then being told it wasn't good enough.
* New requirements appearing after you meet the original ones.
* Standards that apply to you but not to them.
* Constantly changing expectations without acknowledgment.
* Your efforts being minimized with "but what about..."
* Never feeling like you can succeed or satisfy them.

**Why It Works:**
Moving goalposts keeps you off-balance and striving for approval you'll never receive. It maintains their power while ensuring you feel inadequate and keep trying harder.

**How to Respond:**
* Document agreed-upon expectations in writing when possible.
* Point out when standards change: "Last week you said..."
* Stop trying to meet impossible or shifting standards.
* Recognize when someone will never be satisfied.
* Set your own standards and stop seeking their approval.

**Healthy Alternative:**
Healthy people set clear expectations, acknowledge when they're met, and discuss changes in requirements openly and reasonably.
""",
  ),
  Article(
    title: "Emotional Blackmail",
    summary: "Using fear, obligation, and guilt to manipulate your behavior.",
    iconName: "warning",
    content: """
Emotional blackmail is a form of manipulation where someone uses fear, obligation, and guilt (FOG) to control your behavior. They threaten negative consequences—emotional or otherwise—if you don't comply with their demands.

**Signs:**
* Threats of self-harm if you leave or set boundaries.
* Punishing you with cold shoulder or anger for not complying.
* Using your fears against you ("No one else will love you").
* Creating guilt for normal self-care or boundaries.
* Making you responsible for their emotional state.
* Ultimatums designed to control your choices.

**Why It Works:**
Emotional blackmail exploits your caring nature and fear of consequences. You comply to avoid the threatened outcome, which reinforces that the tactic works, ensuring it continues.

**How to Respond:**
* Recognize manipulation versus genuine expression of needs.
* Don't take responsibility for their emotional regulation.
* Set boundaries despite threatened consequences.
* Call out the pattern: "I feel like I'm being pressured to..."
* Seek help if there are threats of self-harm.

**Healthy Alternative:**
Healthy people express their needs and feelings without threats or manipulation. They take responsibility for their own emotions and respect your right to make choices.
""",
  ),
  Article(
    title: "Intermittent Reinforcement",
    summary:
        "Unpredictable rewards that create an addictive psychological attachment.",
    iconName: "casino",
    content: """
Intermittent reinforcement is when rewards (attention, affection, kindness) are given unpredictably. This pattern is more addictive than consistent behavior because you never know when the next "reward" will come.

**Signs:**
* Being treated well sometimes, poorly other times with no clear pattern.
* Never knowing which version of them you'll get.
* Feeling like you're always trying to get back to the "good times."
* The unpredictability keeping you anxiously engaged.
* Brief moments of kindness after extended bad treatment.
* Feeling like you're on an emotional rollercoaster.

**Why It Works:**
This pattern creates psychological addiction. Like gambling, the unpredictable rewards create more compulsive behavior than consistent rewards. Your brain keeps trying to figure out how to make the good times consistent.

**How to Respond:**
* Recognize the pattern of unpredictability.
* Understand this creates addictive attachment, not love.
* Stop trying to figure out how to earn consistent good treatment.
* Acknowledge that you deserve consistent respect and kindness.
* Seek support to break free from the addictive pattern.

**Healthy Alternative:**
Healthy relationships involve consistent treatment. People have bad days, but the baseline of respect, care, and kindness remains steady and predictable.
""",
  ),
  Article(
    title: "Covert Contracts",
    summary:
        "Unspoken agreements where a favor is done with a hidden expectation of return.",
    iconName: "handshake",
    content: """
Covert contracts are unspoken expectations or agreements where someone does something nice with the hidden expectation of something in return. When the unstated expectation isn't met, resentment and blame follow.

**Signs:**
* Doing favors then being angry when you don't reciprocate as expected.
* Keeping score of what they've done for you.
* Being nice followed by "after all I've done for you."
* Feeling obligated to return gestures you didn't ask for.
* Accusations of being ungrateful for not meeting unstated expectations.
* Discovering that kindness came with strings attached.

**Why It Works:**
Covert contracts create confusion and guilt. You feel ungrateful for not meeting expectations you never agreed to, and they feel justified in their resentment because they "did so much" for you.

**How to Respond:**
* Point out unstated expectations: "I didn't know you expected that."
* Don't accept guilt for not reading minds.
* Be wary of unsolicited favors from people who keep score.
* Clarify expectations upfront in your own relationships.
* Set boundaries around accepting "help" that comes with strings.

**Healthy Alternative:**
Healthy people express their needs and expectations clearly. They give freely without keeping score, and they ask directly for what they want rather than creating obligation through unsolicited favors.
""",
  ),
  Article(
    title: "Crazymaking",
    summary:
        "Behaviors designed to make you confused, destabilized, and doubt your sanity.",
    iconName: "psychology",
    content: """
Crazymaking involves behaviors designed to make you feel confused, destabilized, and question your sanity. It's a combination of tactics that leave you feeling off-balance and doubting yourself.

**Signs:**
* Constant contradictions between words and actions.
* Agreeing to things then pretending the conversation never happened.
* Subtle sabotage followed by innocent claims of accidents.
* Creating chaos then blaming you for being upset.
* Making you feel paranoid for noticing patterns.
* Leaving you constantly confused about what's real.

**Why It Works:**
Crazymaking destabilizes your sense of reality. When you can't trust your own perceptions, you become dependent on the manipulator to tell you what's real, increasing their control.

**How to Respond:**
* Trust your perceptions and document patterns.
* Don't try to make them admit to behaviors.
* Build a support system that validates your reality.
* Recognize that you're not crazy for noticing patterns.
* Consider whether this relationship is worth your mental health.

**Healthy Alternative:**
Healthy people are consistent, follow through on agreements, and validate your perceptions even when perspectives differ. They don't make you question your sanity.
""",
  ),
  Article(
    title: "FOG (Fear, Obligation, Guilt)",
    summary: "The three emotions manipulative people use to control others.",
    iconName: "cloud_queue",
    content: """
FOG stands for Fear, Obligation, and Guilt—the three emotions manipulative people use to control others. They create a fog that clouds your judgment and keeps you compliant.

**Signs:**
* Fear: Threats of abandonment, anger, or negative consequences.
* Obligation: "After everything I've done for you" and duty-based pressure.
* Guilt: Making you feel selfish for having boundaries or needs.
* Feeling trapped by these emotions when considering your choices.
* Making decisions based on avoiding these feelings rather than what's right.
* Chronic anxiety about disappointing or upsetting them.

**Why It Works:**
FOG works by hijacking your emotions. Instead of making decisions based on your values and needs, you make them to avoid fear, fulfill perceived obligations, or alleviate guilt.

**How to Respond:**
* Identify which emotion is being triggered.
* Question whether the fear, obligation, or guilt is legitimate.
* Distinguish between actual obligations and manufactured ones.
* Recognize guilt that's imposed versus guilt from actual wrongdoing.
* Make decisions based on your values, not avoidance of FOG.

**Healthy Alternative:**
Healthy relationships involve mutual respect without manipulation. People express needs directly, accept "no," and don't weaponize emotions to control behavior.
""",
  ),
  Article(
    title: "JADE",
    summary:
        "Justify, Argue, Defend, Explain—responses to avoid when setting boundaries.",
    iconName: "shield",
    content: """
JADE stands for Justify, Argue, Defend, and Explain—four responses to avoid when setting boundaries with manipulative people. These responses invite debate and give manipulators ammunition to attack your boundaries.

**Signs:**
* Feeling compelled to explain every decision in detail.
* Getting drawn into arguments about your boundaries.
* Defending your right to have needs or limits.
* Providing justifications that are then picked apart.
* Circular conversations that go nowhere.
* Exhaustion from trying to make them understand.

**Why It Works:**
When you JADE, you signal that your boundary is up for negotiation. Each explanation becomes a new point to attack, each justification another thing to invalidate. The conversation never ends.

**How to Respond:**
* State your boundary clearly and simply.
* Avoid giving detailed explanations or justifications.
* Don't engage in debates about whether your boundary is valid.
* Use phrases like: "I'm not available for that" or "That doesn't work for me."
* Remember: "No" is a complete sentence.

**Healthy Alternative:**
Healthy people accept boundaries without requiring extensive justification. They respect "no" even if they don't fully understand the reasoning.
""",
  ),
  Article(
    title: "Baiting",
    summary: "Deliberately provoking an emotional reaction to use against you.",
    iconName: "phishing",
    content: """
Baiting involves deliberately provoking someone to get an emotional reaction, then using that reaction against them. It's a way to make you look unstable while they appear calm and rational.

**Signs:**
* Making inflammatory comments then acting innocent.
* Pushing your buttons until you react emotionally.
* Using your triggers against you deliberately.
* Acting calm while you're upset, then blaming you for overreacting.
* Bringing up sensitive topics "just asking" or "just joking."
* Setting traps in conversations then springing them.

**Why It Works:**
Baiting makes you look like the unreasonable one. When you react to provocation, they point to your reaction as evidence of your instability, conveniently ignoring what led to it.

**How to Respond:**
* Recognize when you're being deliberately provoked.
* Don't take the bait—respond calmly or not at all.
* Name the behavior: "I notice you bring this up to upset me."
* Remove yourself from the situation.
* Don't defend yourself against bad-faith provocations.

**Healthy Alternative:**
Healthy people communicate to understand, not to provoke. They avoid sensitive topics maliciously and care about your emotional well-being.
""",
  ),
  Article(
    title: "Smear Campaigns",
    summary:
        "Spreading lies or distortions to damage your reputation and isolate you.",
    iconName: "campaign",
    content: """
A smear campaign is when someone spreads lies, distortions, or private information about you to damage your reputation and turn others against you. It's character assassination designed to isolate you and control the narrative.

**Signs:**
* Learning they've been talking about you negatively to others.
* Mutual friends or family acting differently toward you.
* Your private information being shared without consent.
* Being painted as the villain in a one-sided story.
* People having opinions about situations they weren't part of.
* Your attempts to defend yourself being used as more "evidence."

**Why It Works:**
Smear campaigns isolate you and make it harder to leave or get support. When your reputation is damaged, people are less likely to believe your side of the story, and you may feel ashamed or trapped.

**How to Respond:**
* Don't engage in public back-and-forth or mudslinging.
* Maintain your integrity and let your character speak for itself.
* Tell your truth to people who matter and will listen.
* Document evidence in case you need it.
* Focus on building new, healthy relationships.
* Understand that people who believe lies without hearing you weren't truly your people.

**Healthy Alternative:**
Healthy people handle conflicts privately and respectfully. They don't try to turn others against someone or share private information to damage reputations.
""",
  ),
  Article(
    title: "Victim Blaming",
    summary: "Holding the harmed person responsible for the harm done to them.",
    iconName: "fingerprint",
    content: """
Victim blaming occurs when the person being harmed is held responsible for the harmful behavior done to them. It shifts accountability from the person causing harm to the person experiencing it.

**Signs:**
* "You made me do this" or "Look what you made me do."
* "If you hadn't..." followed by justification for mistreatment.
* Focusing on what you did wrong instead of their harmful behavior.
* Being told you're "too sensitive" when hurt by their actions.
* "You should have known better" after being deceived.
* Your reaction to mistreatment becoming the focus, not the mistreatment.

**Why It Works:**
Victim blaming makes you question yourself and focus on what you could have done differently, taking the heat off their behavior. It also makes you easier to control because you're trying to prevent "making them" mistreat you.

**How to Respond:**
* Recognize that you're not responsible for someone else's choices.
* Refocus on their behavior: "That doesn't justify what you did."
* Don't accept blame for someone else's actions.
* Notice if you're constantly trying to avoid "causing" their bad behavior.
* Understand that everyone is responsible for their own responses.

**Healthy Alternative:**
Healthy people take responsibility for their own behaviors regardless of circumstances. They may discuss what triggered them, but they don't blame others for their choices.
""",
  ),
  Article(
    title: "Silent Treatment",
    summary: "Refusal to communicate as a form of punishment and control.",
    iconName: "volume_off",
    content: """
The silent treatment is the refusal to communicate with someone as a form of punishment or manipulation. It's used to create anxiety, signal disapproval, and maintain control through withdrawal.

**Signs:**
* Being ignored for hours or days after disagreements.
* Refusal to acknowledge your presence or attempts at communication.
* No explanation for the withdrawal.
* Using silence to punish or control behavior.
* Feeling anxious and desperate during the silence.
* Walking on eggshells to avoid triggering the silent treatment.

**Why It Works:**
The silent treatment creates intense anxiety and often forces you to apologize or back down just to end the unbearable silence. It's a power move that punishes without requiring the silent person to engage.

**How to Respond:**
* Don't chase, beg, or try to force communication.
* Give space but set a time limit: "I'll check in tomorrow."
* Don't apologize just to end the silence if you did nothing wrong.
* Take care of yourself during the silence.
* Recognize when silence is punishment versus needed space.

**Healthy Alternative:**
Healthy people might need space to cool down, but they communicate that need: "I need some time to think. Let's talk tomorrow." They don't use silence as punishment.
""",
  ),
  Article(
    title: "Boundary Testing",
    summary:
        "Repeatedly pushing against limits to see if you will enforce them.",
    iconName: "fence",
    content: """
Boundary testing occurs when someone repeatedly pushes against your stated limits to see if you'll enforce them. They're checking whether your "no" really means no.

**Signs:**
* Doing exactly what you asked them not to do, but slightly differently.
* Asking the same question repeatedly hoping for a different answer.
* Acting like they forgot your boundary.
* Testing limits "just this once."
* Making you repeatedly enforce the same boundary.
* Pushing a little further each time you don't enforce consequences.

**Why It Works:**
Boundary testing wears you down and identifies which boundaries are negotiable. If you don't consistently enforce a boundary, they learn they can violate it. They also make you feel unreasonable for having to repeat yourself.

**How to Respond:**
* Enforce boundaries consistently every single time.
* Don't explain the same boundary repeatedly.
* Follow through with stated consequences.
* Don't make exceptions "just this once."
* Recognize testing as a red flag, not forgetfulness.

**Healthy Alternative:**
Healthy people respect boundaries the first time. They might forget occasionally, but they apologize genuinely and adjust when reminded, rather than repeatedly testing limits.
""",
  ),
  Article(
    title: "Weaponized Incompetence",
    summary: "Pretending to be bad at tasks to avoid responsibility.",
    iconName: "build_circle",
    content: """
Weaponized incompetence is when someone pretends to be bad at tasks to avoid responsibility. By doing things poorly or claiming inability, they force others to take over the work.

**Signs:**
* Consistently "forgetting" how to do routine tasks.
* Doing things so poorly you have to redo them.
* Acting helpless about tasks they're capable of doing.
* Making tasks seem more complicated than they are.
* "I don't know how" despite being shown multiple times.
* Strategic incompetence that somehow only affects tasks they don't want to do.

**Why It Works:**
You eventually stop asking them to do things because it's easier to do it yourself. They successfully avoid responsibility without directly refusing, so they look willing while being functionally useless.

**How to Respond:**
* Stop doing tasks for them that they're capable of.
* Resist the urge to fix their "mistakes."
* Set expectations: "I need you to figure this out."
* Don't accept learned helplessness as real inability.
* Let natural consequences happen.

**Healthy Alternative:**
Healthy people take genuine responsibility for their share of tasks. They ask for help learning when needed, but then they actually learn and improve.
""",
  ),
  Article(
    title: "Rewriting History",
    summary: "Changing the narrative of past events to avoid accountability.",
    iconName: "edit_note",
    content: """
Rewriting history involves changing the narrative about past events to make themselves look better or you look worse. They tell a version of events that didn't happen to justify current behavior.

**Signs:**
* Claiming events happened differently than they did.
* Conveniently "forgetting" their bad behavior.
* Changing their story over time.
* Making you doubt your memory of events.
* Claiming you're misremembering or exaggerating.
* Painting themselves as the victim of events where they were the aggressor.

**Why It Works:**
Rewriting history destabilizes your sense of reality and allows them to avoid accountability. If the past didn't happen the way you remember, your current reactions seem unreasonable.

**How to Respond:**
* Trust your own memory and perceptions.
* Keep a journal or records of important events.
* Don't let them convince you events didn't happen.
* Validate your memories with others who were present when possible.
* Stop trying to get them to admit the truth.

**Healthy Alternative:**
Healthy people acknowledge when their memory might be imperfect but don't completely deny or rewrite events. They take ownership of their past actions.
""",
  ),
  Article(
    title: "Conditional Kindness",
    summary:
        "Kindness that is only given when you are compliant or serving their needs.",
    iconName: "sentiment_satisfied",
    content: """
Conditional kindness is being nice only when you're compliant, useful, or behaving as desired. The moment you assert yourself, have needs, or set boundaries, the kindness evaporates.

**Signs:**
* Kindness that disappears when you say "no."
* Being treated well only when you're serving their needs.
* Affection that's contingent on your behavior.
* Punishment (coldness, anger) for asserting yourself.
* Having to "earn" basic respect and care.
* Never knowing if you'll get kindness or coldness.

**Why It Works:**
Conditional kindness trains you to suppress your needs and boundaries to maintain their approval. You become focused on earning the kindness rather than recognizing it should be freely given.

**How to Respond:**
* Recognize that love and respect shouldn't be conditional on compliance.
* Notice when kindness is transactional.
* Don't sacrifice your needs for someone's fluctuating approval.
* Set boundaries regardless of how they respond.
* Understand that you deserve consistent kindness.

**Healthy Alternative:**
Healthy people maintain basic respect and kindness even during disagreements. Their care for you isn't contingent on you never having needs or boundaries.
""",
  ),
  Article(
    title: "Comparative Suffering",
    summary: "Minimizing your pain by comparing it to 'worse' situations.",
    iconName: "balance",
    content: """
Comparative suffering is minimizing someone's pain or problems by comparing them to supposedly worse situations. It's the "others have it worse" or "you think YOU have problems" response.

**Signs:**
* "At least you don't have..." when you express difficulties.
* "You think that's bad? Let me tell you about..."
* Making you feel guilty for having problems.
* Turning your pain into a competition.
* Never allowing you to have struggles worth discussing.
* One-upping your experiences with their worse ones.

**Why It Works:**
Comparative suffering shames you for having feelings and keeps the focus on them. You feel guilty for struggling and stop sharing, which isolates you and keeps them from having to provide emotional support.

**How to Respond:**
* Recognize that pain isn't a competition.
* Assert that your feelings are valid: "Other people's struggles don't invalidate mine."
* Stop sharing with people who minimize your experiences.
* Don't apologize for having problems.
* Seek support from people who can hold space for your struggles.

**Healthy Alternative:**
Healthy people validate feelings without comparison. They understand that someone else having bigger problems doesn't mean your problems aren't real or worthy of support.
""",
  ),
  Article(
    title: "Rugsweeping",
    summary: "Pretending problems didn't happen to avoid resolution.",
    iconName: "cleaning_services",
    content: """
Rugsweeping is avoiding addressing problems by pretending they didn't happen or aren't important. Issues are swept under the rug rather than resolved, creating a foundation of unaddressed resentment.

**Signs:**
* "Let's just move on" without actually resolving anything.
* "Why do you have to bring up the past?" when discussing patterns.
* Acting like nothing happened after serious incidents.
* Pressure to forgive and forget without change.
* Making you feel like the problem for wanting to address issues.
* Creating a false peace by avoiding difficult conversations.

**Why It Works:**
Rugsweeping allows them to avoid accountability and continue harmful patterns. You feel like the difficult one for wanting resolution, so you stay quiet while problems accumulate.

**How to Respond:**
* Insist on addressing issues: "We need to talk about this."
* Don't accept pressure to "just move on."
* Recognize that patterns from the past predict the future.
* Trust your need for resolution.
* Don't let them make you feel difficult for wanting healthy communication.

**Healthy Alternative:**
Healthy people address problems directly, work toward genuine resolution, and make amends. They understand that sweeping issues under the rug doesn't make them go away.
""",
  ),
  Article(
    title: "Testing Loyalty",
    summary:
        "Creating situations to test your commitment or force you to choose.",
    iconName: "verified",
    content: """
Testing loyalty involves creating situations to test whether you'll choose them over others or sacrifice yourself to prove your commitment. It's a manipulation tactic disguised as relationship security.

**Signs:**
* Creating scenarios where you must choose between them and others.
* Getting upset when you spend time with friends or family.
* Asking you to prove your love in increasingly demanding ways.
* Manufacturing crises that require you to drop everything.
* Asking you to cut off people who are "threats" to the relationship.
* Never feeling like you've proven yourself enough.

**Why It Works:**
Loyalty tests isolate you and increase their control. Each test you pass leads to a harder one, and failing any test results in accusations of not truly caring.

**How to Respond:**
* Recognize that secure people don't test loyalty.
* Refuse to choose between them and other important relationships.
* Don't sacrifice yourself to prove love.
* Set boundaries: "I won't be tested."
* Understand that real trust is built, not tested.

**Healthy Alternative:**
Healthy people build trust through consistent behavior over time. They don't create tests or demand you prove your loyalty by sacrificing other relationships or yourself.
""",
  ),
  Article(
    title: "Playing the Victim",
    summary:
        "Portraying oneself as persecuted to gain sympathy and avoid accountability.",
    iconName: "sentiment_dissatisfied",
    content: """
Playing the victim involves portraying yourself as perpetually wronged, helpless, or persecuted to gain sympathy, avoid accountability, and manipulate others into caretaking or compliance.

**Signs:**
* Everything is always someone else's fault.
* Constant narratives of being mistreated or misunderstood.
* Deflecting responsibility by claiming to be the real victim.
* Using their victimhood to manipulate your behavior.
* Never taking accountability for anything.
* Crying or falling apart when confronted with their behavior.

**Why It Works:**
Playing victim triggers your empathy and compassion, making you focus on comforting them rather than addressing their harmful behavior. It's hard to hold someone accountable when they seem so wounded.

**How to Respond:**
* Recognize the difference between real vulnerability and manipulation.
* Don't let victimhood deflect from legitimate concerns.
* Maintain your boundaries even when they seem wounded.
* Notice if they're always the victim in every story.
* Understand that real victims work toward healing, not perpetual victimhood.

**Healthy Alternative:**
Healthy people acknowledge when they've been hurt, but they also take responsibility for their own behaviors and healing. They don't use past hurts to manipulate or avoid accountability.
""",
  ),
  Article(
    title: "Double Standards",
    summary: "Applying different rules to you than they apply to themselves.",
    iconName: "compare_arrows",
    content: """
Double standards involve having one set of rules for yourself and another for other people. What's acceptable for them is unacceptable for you, with no acknowledgment of the hypocrisy.

**Signs:**
* They can do things you're not allowed to do.
* Different expectations apply depending on who benefits.
* Anger at you for behavior they regularly display.
* Rules that conveniently change based on their needs.
* Denial or minimization when you point out the inconsistency.
* Being called controlling for wanting the same freedom they have.

**Why It Works:**
Double standards create an unequal power dynamic where you're held to standards they don't meet. You feel confused and resentful but struggle to articulate the unfairness when they deny it.

**How to Respond:**
* Point out the double standard clearly: "You do that all the time."
* Don't accept explanations for why the standard is different.
* Set the same boundaries for yourself that they set for you.
* Recognize that fair relationships have equal standards.
* Don't try to convince them of the hypocrisy.

**Healthy Alternative:**
Healthy relationships have mutual expectations. Both people hold themselves to the same standards they expect from each other, and flexibility is reciprocal.
""",
  ),
  Article(
    title: "Performative Vulnerability",
    summary: "Calculated 'honesty' designed to manipulate rather than connect.",
    iconName: "theater_comedy",
    content: """
Performative vulnerability is using the appearance of openness and emotional sharing to manipulate rather than connect. It's calculated "honesty" designed to achieve a specific outcome.

**Signs:**
* Sharing deep things very quickly to create false intimacy.
* Vulnerability that always serves a purpose (gaining trust, deflecting).
* Emotional revelations that don't match their behavior.
* Using their struggles to excuse harmful behavior.
* Sharing to create obligation or sympathy.
* Openness that feels strategic rather than genuine.

**Why It Works:**
Performative vulnerability creates a sense of deep connection and makes you feel special for receiving their "trust." You feel guilty questioning or setting boundaries with someone who's been "so open" with you.

**How to Respond:**
* Notice when vulnerability is paired with requests or manipulation.
* Observe whether their actions match their emotional revelations.
* Don't let shared struggles excuse harmful behavior.
* Trust your instincts if something feels performative.
* Remember that real vulnerability builds over time.

**Healthy Alternative:**
Genuine vulnerability is shared gradually as trust builds. It's not used strategically to manipulate, create false intimacy, or excuse harmful behavior.
""",
  ),
];
