import 'dart:math';

/// Pool of confirmation sentences for YouTube Study Mode channel additions
/// per GMP_FF_BUILD.md Step 15 & 16.
class ConfirmationSentences {
  static const List<String> shortPool = [
    'I am adding this channel solely for educational learning.',
    'This channel supports my focused study and academic growth.',
    'I commit to intentional consumption of this study material.',
    'This channel directly aids my learning objectives and work.',
    'I will only watch relevant educational videos on this channel.',
  ];

  static const List<String> longPool = [
    'I acknowledge that adding excessive channels dilutes my focus and confirm that this channel is strictly necessary for deep mastery.',
    'Mindful consumption requires deliberate restraint and I consciously verify that this creator produces high signal educational material.',
    'Discipline is choosing between what I want now and what I want most, and this channel strictly supports my highest academic ambitions.',
    'I commit to maintaining an uncompromising standard of attention and certify that this channel contains zero low cognitive demand distractions.',
    'Deep focused work demands intentionality, and I swear to engage with this material purely as a diligent student of the craft.',
    'I verify that this video channel delivers structured technical or academic value that advances my current study roadmap.',
    'I will not browse recommendations, algorithmic suggestions, or unrelated entertainment videos when visiting this educational channel.',
    'My attention is my most scarce resource, and I pledge to protect it from frivolous stimulation during active study sessions.',
    'I understand that intellectual excellence requires monastic discipline, and this channel will be used exclusively for serious education.',
    'I solemnly declare that every minute spent on this channel will be actively dedicated to note taking and deliberate practice.',
    'Learning requires cognitive friction and deliberate effort; I will not use this channel as passive background amusement.',
    'I confirm that this content directly solves hard problems in my domain and cannot be replaced by distraction-free reading.',
    'I hold myself accountable to rigorous standards of digital sobriety and will immediately exit upon finishing the required lecture.',
    'This addition represents a conscious choice to acquire valuable skills rather than surrender to algorithmic dopamine traps.',
    'I consciously refuse algorithmic entertainment and accept the responsibility of staying on task while learning from this channel.',
    'I understand that superficial learning is an illusion, so I will watch this educational content with intense focus and handwritten notes.',
    'My focus is sacred; I will not allow autoplay, related video sidebars, or comment sections to hijack my cognitive bandwidth.',
    'I certify that this channel provides indispensable subject matter knowledge that directly propels my academic or professional work.',
    'I accept the friction of typing this sentence to ensure that my desire to add this channel is intentional and deeply rational.',
    'I commit to closing YouTube the exact second this educational tutorial concludes without clicking any tempting clickbait thumbnails.',
    'I verify that this channel does not publish superficial infotainment designed to mimic productivity while delivering triviality.',
    'Deliberate practice is the only path to skill mastery; I will watch this channel solely to learn concepts and solve difficult exercises.',
    'I value long term accomplishment over short term gratification and will guard my study time with uncompromising vigilance.',
    'I acknowledge that attention fragmentation degrades deep thinking, so I will watch only specified tutorial lectures on this channel.',
    'I promise to treat this learning session with the solemnity of a university seminar and refrain from browsing side suggestions.',
    'I intentionally choose discipline over convenience and confirm that this channel is essential for my educational syllabus.',
    'I confirm that this video channel is a genuine study asset that provides rigorous explanations rather than quick sensationalism.',
    'I pledge that I am adding this educational channel to build competence, not to satisfy a subconscious craving for entertainment.',
    'Every video on this channel that I watch during study hours will have an explicit, predetermined learning outcome written down.',
    'I refuse to let the recommendation algorithm dictate my thoughts, actions, or cognitive habits during focused study hours.',
    'I will consume only the exact instructional video required for my current lesson and avoid all peripheral browsing behavior.',
    'I verify that this channel offers deep technical clarity and that I will apply its insights immediately to real problem sets.',
    'Attention is the bedrock of mastery; I commit to watching this channel with single-minded devotion to my educational goals.',
    'I verify that this educational creator maintains high intellectual integrity and produces content worthy of focused attention.',
    'I will not multitask while watching lectures on this channel; I will pause, reflect, and synthesize every core principle presented.',
    'I accept that real learning is difficult and often boring, and I will not abandon this lecture when cognitive strain occurs.',
    'I affirm that my future self depends on the discipline I exercise right now while engaging with this educational content.',
    'I will not scroll through the comments or watch unrelated shorts while navigating to this verified educational playlist.',
    'I acknowledge that dopamine addiction ruins intellectual stamina, so I will hold myself to the strictest study standards.',
    'I verify that this channel provides irreplaceable instructional guidance that is strictly aligned with my study agenda.',
    'I commit to turning off autoplay and exiting the browser immediately once the relevant educational segment has concluded.',
    'I will use this channel as a reference library, never as a relaxation lounge or mindless background audio stream.',
    'I acknowledge that every digital input shapes my mental clarity; I choose only rigorous educational material for this whitelist.',
    'I promise to engage with this creator solely as an analytical thinker seeking specific answers to difficult technical questions.',
    'I will not permit algorithmic suggestions to derail my train of thought while learning complex topics on this channel.',
    'I affirm that this channel is an educational instrument of high caliber that serves my core academic mission.',
    'I take complete personal responsibility for my attention and confirm that this channel is needed for rigorous academic study.',
    'I refuse the cheap pleasure of endless video hopping; I will study this material with unyielding concentration and purpose.',
    'I swear that this educational addition is guided by genuine curiosity and deliberate learning, not casual procrastination.',
    'I dedicate myself to deep work and verify that this channel will be consumed with the utmost intellectual rigor and dignity.',
  ];

  /// Returns a sentence based on channel count, ensuring it is not the same as [lastSentence].
  static String getRandomSentence({
    required int currentChannelCount,
    String? lastSentence,
    Random? random,
  }) {
    final rng = random ?? Random();
    final pool = currentChannelCount <= 25 ? shortPool : longPool;

    if (pool.length <= 1) return pool.first;

    String candidate;
    do {
      candidate = pool[rng.nextInt(pool.length)];
    } while (candidate == lastSentence && pool.length > 1);

    return candidate;
  }
}
