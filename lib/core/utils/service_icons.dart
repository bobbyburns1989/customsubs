library;

/// Service icon mapping for subscription templates.
///
/// Icons are resolved in this priority order (highest → lowest):
///
/// 1. **Local SVG asset** (`assets/logos/{iconName}.svg`) — for brands not in
///    Simple Icons (Disney+, Microsoft, Adobe, etc.). Add the iconName to
///    [_localLogoIconNames] after dropping in the SVG file.
///
/// 2. **SimpleIcons** (`simple_icons` package, ~80 brands mapped) — font-based
///    SVG brand icons, fully offline, bundled with the app.
///
/// 3. **Letter avatar** — first character of the subscription name, rendered
///    by [SubscriptionIcon] as a final fallback.
///
/// ## Adding a missing brand logo
/// 1. Create `{iconName}.svg` (100×100 viewBox) and drop it in `assets/logos/`
/// 2. Add the iconName string to [_localLogoIconNames] below
/// 3. Run `flutter pub get`
///
/// ## Trademark note
/// Adobe, Microsoft, Disney, LinkedIn, Xbox, Nintendo, Hulu, Bumble, Hinge
/// were removed from Simple Icons for trademark reasons — use local SVGs instead.

import 'package:flutter/widgets.dart';
import 'package:simple_icons/simple_icons.dart';

class ServiceIcons {
  // ---------------------------------------------------------------------------
  // Local SVG logos — brands not covered by simple_icons (trademark removals).
  //
  // HOW TO ADD A LOGO:
  //   1. Create `{iconName}.svg` (100×100 viewBox) and drop it in assets/logos/
  //   2. Add the iconName string to this set
  //   3. Run `flutter pub get` to rebuild the asset bundle
  //
  // The iconName must match the `iconName` field in subscription_templates.json.
  // ---------------------------------------------------------------------------
  static const Set<String> _localLogoIconNames = {
    // --- Original set (trademark removals from Simple Icons) ---
    'disney',        // Disney+     → assets/logos/disney.svg
    'hulu',          // Hulu        → assets/logos/hulu.svg
    'microsoft',     // MS 365      → assets/logos/microsoft.svg
    'adobe',         // Adobe CC    → assets/logos/adobe.svg
    'linkedin',      // LinkedIn    → assets/logos/linkedin.svg
    'xbox',          // Xbox        → assets/logos/xbox.svg
    'nintendo',      // Nintendo    → assets/logos/nintendo.svg
    'bumble',        // Bumble      → assets/logos/bumble.svg
    'espn',          // ESPN+       → assets/logos/espn.svg
    'hinge',         // Hinge       → assets/logos/hinge.svg
    'siriusxm',      // SiriusXM    → assets/logos/siriusxm.svg

    // --- AI / Dev tools (not in Simple Icons) ---
    'midjourney',    // Midjourney  → assets/logos/midjourney.svg
    'cursor',        // Cursor IDE  → assets/logos/cursor.svg
    'windsurf',      // Windsurf    → assets/logos/windsurf.svg
    'runway',        // RunwayML    → assets/logos/runway.svg
    'jasper',        // Jasper AI   → assets/logos/jasper.svg
    'synthesia',     // Synthesia   → assets/logos/synthesia.svg

    // --- Health & Fitness ---
    'myfitnesspal',  // MFP         → assets/logos/myfitnesspal.svg
    'calm',          // Calm        → assets/logos/calm.svg
    'noom',          // Noom        → assets/logos/noom.svg
    'classpass',     // ClassPass   → assets/logos/classpass.svg
    'beachbody',     // Beachbody   → assets/logos/beachbody.svg
    'gym',           // Gym         → assets/logos/gym.svg

    // --- Finance & Budgeting ---
    'ynab',          // YNAB        → assets/logos/ynab.svg
    'monarch',       // Monarch     → assets/logos/monarch.svg
    'rocket',        // Rocket Money→ assets/logos/rocket.svg
    'pocketguard',   // PocketGuard → assets/logos/pocketguard.svg

    // --- News & Media ---
    'wsj',           // WSJ         → assets/logos/wsj.svg
    'wapo',          // WaPo        → assets/logos/wapo.svg
    'atlantic',      // The Atlantic→ assets/logos/atlantic.svg

    // --- Education & Language ---
    'babbel',        // Babbel      → assets/logos/babbel.svg
    'busuu',         // Busuu       → assets/logos/busuu.svg

    // --- Security & Utilities ---
    'nordpass',      // NordPass    → assets/logos/nordpass.svg
    'nest',          // Nest Aware  → assets/logos/nest.svg

    // --- Streaming / TV ---
    'sling',         // Sling TV    → assets/logos/sling.svg
    'amc',           // AMC+        → assets/logos/amc.svg
    'britbox',       // BritBox     → assets/logos/britbox.svg
    'shudder',       // Shudder     → assets/logos/shudder.svg
    'discovery',     // Discovery+  → assets/logos/discovery.svg

    // --- Dating ---
    'match',         // Match.com   → assets/logos/match.svg

    // --- Food / Meal Kits ---
    'blueapron',     // Blue Apron  → assets/logos/blueapron.svg
    'factor',        // Factor      → assets/logos/factor.svg

    // --- Education ---
    'rosetta',       // Rosetta Stone → assets/logos/rosetta.svg

    // --- Batch 2 additions ---

    // Health & Wellbeing
    'betterhelp',    // BetterHelp    → assets/logos/betterhelp.svg
    'talkspace',     // Talkspace     → assets/logos/talkspace.svg
    'oura',          // Oura Ring     → assets/logos/oura.svg
    'whoop',         // WHOOP         → assets/logos/whoop.svg
    'zwift',         // Zwift         → assets/logos/zwift.svg

    // Productivity / Education
    'superhuman',    // Superhuman    → assets/logos/superhuman.svg
    'masterclass',   // MasterClass   → assets/logos/masterclass.svg

    // Music
    'deezer',        // Deezer        → assets/logos/deezer.svg

    // Business / Productivity
    'docusign',      // DocuSign      → assets/logos/docusign.svg
    'monday',        // Monday.com    → assets/logos/monday.svg (three-dot motif)

    // Streaming / Sports TV
    'espnplus',      // ESPN+         → assets/logos/espnplus.svg
    'f1tv',          // F1 TV         → assets/logos/f1tv.svg
    'mgmplus',       // MGM+          → assets/logos/mgmplus.svg
    'philo',         // Philo         → assets/logos/philo.svg

    // Shopping / Market
    'thrive',        // Thrive Market → assets/logos/thrive.svg

    // --- Batch 3 additions ---

    // Fitness & Gyms
    'equinox',       // Equinox         → assets/logos/equinox.svg
    'orangetheory',  // Orangetheory    → assets/logos/orangetheory.svg
    'soulcycle',     // SoulCycle       → assets/logos/soulcycle.svg
    'planet_fitness',// Planet Fitness  → assets/logos/planet_fitness.svg
    'la_fitness',    // LA Fitness      → assets/logos/la_fitness.svg
    '24hour',        // 24 Hour Fitness → assets/logos/24hour.svg
    'anytime',       // Anytime Fitness → assets/logos/anytime.svg
    'barrys',        // Barry's Bootcamp→ assets/logos/barrys.svg
    'lifetime',      // Life Time       → assets/logos/lifetime.svg
    'f45',           // F45 Training    → assets/logos/f45.svg
    'lesmills',      // Les Mills+      → assets/logos/lesmills.svg
    'dailyburn',     // Daily Burn      → assets/logos/dailyburn.svg
    'fiton',         // FitOn           → assets/logos/fiton.svg
    'future',        // Future          → assets/logos/future.svg
    'obe',           // Obé Fitness     → assets/logos/obe.svg

    // Telehealth
    'teladoc',       // Teladoc         → assets/logos/teladoc.svg
    'cerebral',      // Cerebral        → assets/logos/cerebral.svg
    'mdlive',        // MDLive          → assets/logos/mdlive.svg
    'khealth',       // K Health        → assets/logos/khealth.svg
    'nurx',          // Nurx            → assets/logos/nurx.svg
    'roman',         // Roman           → assets/logos/roman.svg
    'hims',          // Hims            → assets/logos/hims.svg
    'hers',          // Hers            → assets/logos/hers.svg

    // Productivity / Email
    'convertkit',    // ConvertKit      → assets/logos/convertkit.svg
    'descript',      // Descript        → assets/logos/descript.svg
    'otter',         // Otter.ai        → assets/logos/otter.svg
    'fantastical',   // Fantastical     → assets/logos/fantastical.svg
    'fastmail',      // Fastmail        → assets/logos/fastmail.svg
    'copyai',        // Copy.ai         → assets/logos/copyai.svg
    'notebooklm',    // NotebookLM      → assets/logos/notebooklm.svg
    'characterai',   // Character.ai    → assets/logos/characterai.svg

    // Finance
    'copilot',       // Copilot Money   → assets/logos/copilot.svg
    'simplifi',      // Simplifi        → assets/logos/simplifi.svg
    'creditkarma',   // Credit Karma    → assets/logos/creditkarma.svg
    'experian',      // Experian        → assets/logos/experian.svg

    // --- Batch 4 additions ---

    // Streaming Niche
    'criterion',     // Criterion Channel  → assets/logos/criterion.svg
    'curiosity',     // CuriosityStream    → assets/logos/curiosity.svg
    'dropout',       // Dropout            → assets/logos/dropout.svg
    'mhz',           // MHz Choice         → assets/logos/mhz.svg
    'pureflix',      // Pure Flix          → assets/logos/pureflix.svg
    'viki',          // Viki               → assets/logos/viki.svg
    'hallmark',      // Hallmark Movies Now→ assets/logos/hallmark.svg
    'boosteroid',    // Boosteroid         → assets/logos/boosteroid.svg
    'geforce',       // GeForce NOW        → assets/logos/geforce.svg
    'gaia',          // Gaia               → assets/logos/gaia.svg

    // Beauty / Fashion
    'ipsy',          // Ipsy               → assets/logos/ipsy.svg
    'birchbox',      // Birchbox           → assets/logos/birchbox.svg
    'boxycharm',     // BoxyCharm          → assets/logos/boxycharm.svg
    'fabfitfun',     // FabFitFun          → assets/logos/fabfitfun.svg
    'glossybox',     // Glossybox          → assets/logos/glossybox.svg
    'sephora',       // Sephora            → assets/logos/sephora.svg
    'allure',        // Allure Beauty      → assets/logos/allure.svg
    'savagex',       // Savage X Fenty     → assets/logos/savagex.svg
    'fabletics',     // Fabletics VIP      → assets/logos/fabletics.svg
    'stitchfix',     // Stitch Fix         → assets/logos/stitchfix.svg
    'bombas',        // Bombas             → assets/logos/bombas.svg
    'alo',           // Alo Moves          → assets/logos/alo.svg

    // Food / Drink Boxes
    'sunbasket',     // Sunbasket          → assets/logos/sunbasket.svg
    'freshly',       // Freshly            → assets/logos/freshly.svg
    'gobble',        // Gobble             → assets/logos/gobble.svg
    'nakedwines',    // Naked Wines        → assets/logos/nakedwines.svg
    'winc',          // Winc               → assets/logos/winc.svg
    'firstleaf',     // Firstleaf          → assets/logos/firstleaf.svg
    'butcherbox',    // ButcherBox         → assets/logos/butcherbox.svg
    'craftbeer',     // Craft Beer Club    → assets/logos/craftbeer.svg
    'tasters',       // Taster's Club      → assets/logos/tasters.svg
    'ollie',         // Ollie              → assets/logos/ollie.svg

    // Pets
    'barkbox',       // BarkBox            → assets/logos/barkbox.svg
    'kitnipbox',     // KitNipBox          → assets/logos/kitnipbox.svg
    'petplate',      // PetPlate           → assets/logos/petplate.svg

    // --- Batch 5 additions ---

    // Home / Security
    'simplisafe',    // SimpliSafe         → assets/logos/simplisafe.svg
    'adt',           // ADT Security       → assets/logos/adt.svg
    'ahs',           // American Home Shield→ assets/logos/ahs.svg
    'choice',        // Choice Home Warranty→ assets/logos/choice.svg
    'orkin',         // Orkin              → assets/logos/orkin.svg
    'trugreen',      // TruGreen           → assets/logos/trugreen.svg
    'terminix',      // Terminix           → assets/logos/terminix.svg
    'onstar',        // OnStar             → assets/logos/onstar.svg
    'chargepoint',   // ChargePoint        → assets/logos/chargepoint.svg
    'publicstorage', // Public Storage     → assets/logos/publicstorage.svg
    'pods',          // PODS Storage       → assets/logos/pods.svg
    'clutter',       // Clutter            → assets/logos/clutter.svg
    'lawnstarter',   // LawnStarter        → assets/logos/lawnstarter.svg
    'handy',         // Handy              → assets/logos/handy.svg
    'taskrabbit',    // TaskRabbit         → assets/logos/taskrabbit.svg
    'sittercity',    // Sittercity         → assets/logos/sittercity.svg
    'mls',           // MLS Season Pass    → assets/logos/mls.svg

    // Misc / Niche
    'identityforce', // IdentityForce      → assets/logos/identityforce.svg
    'lifelock',      // LifeLock           → assets/logos/lifelock.svg
    'carvertical',   // CarVertical        → assets/logos/carvertical.svg
    'kraken',        // Kraken             → assets/logos/kraken.svg
    'privacy',       // Privacy.com        → assets/logos/privacy.svg
    'costco',        // Costco             → assets/logos/costco.svg
    'bjs',           // BJ's Wholesale     → assets/logos/bjs.svg
    'samsclub',      // Sam's Club         → assets/logos/samsclub.svg
    'chewy',         // Chewy Autoship     → assets/logos/chewy.svg
    'luna',          // Amazon Luna+       → assets/logos/luna.svg
    'dsc',           // Dollar Shave Club  → assets/logos/dsc.svg
    'harrys',        // Harry's            → assets/logos/harrys.svg

    // Adult / Creator Platforms (lettermarks only — App Store guidelines)
    'fansly',        // Fansly             → assets/logos/fansly.svg
    'fancentro',     // FanCentro          → assets/logos/fancentro.svg
    'manyvids',      // ManyVids           → assets/logos/manyvids.svg
    'loyalfans',     // LoyalFans          → assets/logos/loyalfans.svg
    'avn',           // AVN                → assets/logos/avn.svg

    // --- Batch 6: Zero-coverage gap fills ---

    // Security / Smart Home
    'arlo',          // Arlo Secure        → assets/logos/arlo.svg

    // Marketing / CRM
    'activecampaign',// ActiveCampaign     → assets/logos/activecampaign.svg

    // Childcare / Household
    'care',          // Care.com           → assets/logos/care.svg

    // Streaming Niche
    'cocktail',      // Cocktail           → assets/logos/cocktail.svg

    // Beauty Box
    'cocotique',     // Cocotique          → assets/logos/cocotique.svg

    // Skincare
    'dhc',           // DHC Skincare       → assets/logos/dhc.svg

    // Finance / Accounting
    'freshbooks',    // FreshBooks         → assets/logos/freshbooks.svg

    // Fitness / GPS
    'garmin',        // Garmin Connect+    → assets/logos/garmin.svg

    // Specialty Box
    'hemper',        // Hemper             → assets/logos/hemper.svg

    // Kids Education
    'lingokids',     // LingoKids          → assets/logos/lingokids.svg

    // Cocktail / Home
    'shaker',        // Shaker             → assets/logos/shaker.svg

    // Mental Health
    'shine',         // Shine              → assets/logos/shine.svg
  };

  /// Returns the asset path for a locally bundled SVG logo.
  /// Only call this after confirming [hasLocalLogo] returns true.
  static String getLocalLogoPath(String iconName) =>
      'assets/logos/${iconName.toLowerCase()}.svg';

  /// Returns true if a local PNG logo exists for this [iconName].
  static bool hasLocalLogo(String? iconName) {
    if (iconName == null || iconName.isEmpty) return false;
    return _localLogoIconNames.contains(iconName.toLowerCase());
  }

  // ---------------------------------------------------------------------------
  // Verified mapping: template iconName → SimpleIcons constant
  // All entries confirmed against simple_icons v14.6.1 at build time.
  // ---------------------------------------------------------------------------
  static const Map<String, IconData> _iconMap = {
    // --- Streaming / Video ---
    'netflix': SimpleIcons.netflix,
    'spotify': SimpleIcons.spotify,
    'youtube': SimpleIcons.youtube,
    'youtube_tv': SimpleIcons.youtube,     // No separate YouTube TV icon
    'crunchyroll': SimpleIcons.crunchyroll,
    'tidal': SimpleIcons.tidal,
    'twitch': SimpleIcons.twitch,
    'pandora': SimpleIcons.pandora,
    'hbo': SimpleIcons.hbo,
    // 'hulu': removed from Simple Icons (trademark) — falls back to letter
    // 'disney': removed from Simple Icons (trademark) — falls back to letter

    // --- Apple Services ---
    'apple_music': SimpleIcons.applemusic,
    'apple_tv': SimpleIcons.appletv,
    'apple_arcade': SimpleIcons.applearcade,
    'apple_one': SimpleIcons.apple,        // No dedicated Apple One icon
    'apple_news': SimpleIcons.apple,
    'apple_fitness': SimpleIcons.apple,
    'icloud': SimpleIcons.icloud,

    // --- Google Services ---
    'google_one': SimpleIcons.google,
    'google_ai': SimpleIcons.google,

    // --- Cloud Storage & Utilities ---
    'dropbox': SimpleIcons.dropbox,
    'amazon': SimpleIcons.amazon,
    'kindle': SimpleIcons.amazon,          // No separate Kindle icon

    // --- Productivity & Design ---
    'notion': SimpleIcons.notion,
    'figma': SimpleIcons.figma,
    'canva': SimpleIcons.canva,
    'sketch': SimpleIcons.sketch,
    'framer': SimpleIcons.framer,
    'miro': SimpleIcons.miro,
    'loom': SimpleIcons.loom,
    'airtable': SimpleIcons.airtable,
    'trello': SimpleIcons.trello,
    'asana': SimpleIcons.asana,
    'clickup': SimpleIcons.clickup,
    'linear': SimpleIcons.linear,
    'basecamp': SimpleIcons.basecamp,
    'calendly': SimpleIcons.calendly,
    'typeform': SimpleIcons.typeform,
    'surveymonkey': SimpleIcons.surveymonkey,
    'grammarly': SimpleIcons.grammarly,
    'webflow': SimpleIcons.webflow,
    'zapier': SimpleIcons.zapier,
    'intercom': SimpleIcons.intercom,
    'hubspot': SimpleIcons.hubspot,
    'salesforce': SimpleIcons.salesforce,
    'zendesk': SimpleIcons.zendesk,
    'squarespace': SimpleIcons.squarespace,
    'shopify': SimpleIcons.shopify,
    'mailchimp': SimpleIcons.mailchimp,
    'replit': SimpleIcons.replit,
    'jetbrains': SimpleIcons.jetbrains,
    // 'microsoft': removed from Simple Icons (trademark) — falls back to letter
    // 'adobe': removed from Simple Icons (trademark) — falls back to letter

    // --- AI Tools ---
    'chatgpt': SimpleIcons.openai,         // ChatGPT → OpenAI brand icon
    'claude': SimpleIcons.claude,
    'perplexity': SimpleIcons.perplexity,
    'elevenlabs': SimpleIcons.elevenlabs,
    // 'midjourney': not in Simple Icons — falls back to letter

    // --- Developer Tools ---
    'github': SimpleIcons.github,
    'xero': SimpleIcons.xero,
    'quickbooks': SimpleIcons.quickbooks,
    // 'freshbooks': not in Simple Icons — falls back to letter

    // --- Finance ---
    'coinbase': SimpleIcons.coinbase,
    'dashlane': SimpleIcons.dashlane,
    'nordvpn': SimpleIcons.nordvpn,
    'expressvpn': SimpleIcons.expressvpn,

    // --- Gaming ---
    'playstation': SimpleIcons.playstation,
    'ea': SimpleIcons.ea,
    'ubisoft': SimpleIcons.ubisoft,
    // 'xbox': removed from Simple Icons (trademark) — uses local SVG
    // 'nintendo': removed from Simple Icons (trademark) — uses local SVG

    // --- Security & Antivirus ---
    'bitdefender': SimpleIcons.bitdefender,
    'mcafee': SimpleIcons.mcafee,
    'norton': SimpleIcons.norton,

    // --- Streaming ---
    'starz': SimpleIcons.starz,

    // --- Fitness & Health ---
    'strava': SimpleIcons.strava,
    'peloton': SimpleIcons.peloton,
    'headspace': SimpleIcons.headspace,

    // --- Education ---
    'duolingo': SimpleIcons.duolingo,
    'coursera': SimpleIcons.coursera,
    'skillshare': SimpleIcons.skillshare,

    // --- News & Reading ---
    'medium': SimpleIcons.medium,
    'substack': SimpleIcons.substack,
    'nyt': SimpleIcons.newyorktimes,
    // 'wsj': not in Simple Icons — falls back to letter
    // 'wapo': not in Simple Icons — falls back to letter

    // --- Social & Dating ---
    'discord': SimpleIcons.discord,
    'slack': SimpleIcons.slack,
    'snapchat': SimpleIcons.snapchat,
    'x': SimpleIcons.x,
    'patreon': SimpleIcons.patreon,
    'onlyfans': SimpleIcons.onlyfans,
    'tinder': SimpleIcons.tinder,
    // 'bumble': not in Simple Icons — falls back to letter
    // 'linkedin': removed from Simple Icons (trademark) — falls back to letter
    // 'hinge': not in Simple Icons — uses local SVG (assets/logos/hinge.svg)

    // --- Food, Delivery & Meal Kits ---
    'doordash': SimpleIcons.doordash,
    'instacart': SimpleIcons.instacart,
    'uber': SimpleIcons.uber,
    'hellofresh': SimpleIcons.hellofresh,
    'audible': SimpleIcons.audible,        // Amazon Audible audiobooks

    // --- Retail ---
    'target': SimpleIcons.target,
    'walmart': SimpleIcons.walmart,

    // --- Smart Home & Security ---
    'tesla': SimpleIcons.tesla,
    'ring': SimpleIcons.ring,

    // --- Video Conferencing ---
    'zoom': SimpleIcons.zoom,

    // --- Payments & Password Managers ---
    '1password': SimpleIcons.n1password,

    // --- Streaming (TV) ---
    'paramount': SimpleIcons.paramountplus,
    'peacock': SimpleIcons.nbc,            // Peacock is NBC Universal's service
    'fubo': SimpleIcons.fubo,              // FuboTV live TV streaming
    'mubi': SimpleIcons.mubi,
    'mlb': SimpleIcons.mlb,
    'nba': SimpleIcons.nba,
    'dazn': SimpleIcons.dazn,
    'nebula': SimpleIcons.nebula,
    'shadow': SimpleIcons.shadow,          // Shadow cloud gaming PC

    // --- Music Streaming ---
    'amazon_music': SimpleIcons.amazonmusic,
    'youtube_music': SimpleIcons.youtubemusic,

    // --- Productivity & Dev Tools ---
    'todoist': SimpleIcons.todoist,
    'obsidian': SimpleIcons.obsidian,
    'kagi': SimpleIcons.kagi,
    'raycast': SimpleIcons.raycast,
    'poe': SimpleIcons.poe,

    // --- VPN & Privacy ---
    'surfshark': SimpleIcons.surfshark,
    'protonmail': SimpleIcons.protonmail,
    'protonvpn': SimpleIcons.protonvpn,
    'mullvad': SimpleIcons.mullvad,

    // --- Automation & Productivity Tools ---
    'make': SimpleIcons.make,              // Make.com (formerly Integromat)

    // --- Cell Phone Carriers ---
    // SimpleIcons.spectrum is the dev framework (purple), NOT Charter Spectrum ISP — omitted
    'verizon': SimpleIcons.verizon,
    'att_wireless': SimpleIcons.atandt,    // AT&T Wireless → AT&T brand icon
    'att_internet': SimpleIcons.atandt,    // AT&T Internet → same brand icon
    'boost': SimpleIcons.boost,            // Boost Mobile (orange #F7901E confirmed)

    // --- Smart Home ---
    'wyze': SimpleIcons.wyze,

    // --- Password Managers ---
    'lastpass': SimpleIcons.lastpass,
    'keeper': SimpleIcons.keeper,
  };

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the [IconData] brand icon for a given template [iconName], or
  /// null if no brand icon is available.
  ///
  /// [iconName] is the value from the `iconName` field in
  /// `subscription_templates.json` (e.g. "netflix", "spotify", "apple_music").
  ///
  /// Returns null for unmapped services — the caller should render a letter
  /// avatar as fallback.
  static IconData? getIconForIconName(String? iconName) {
    if (iconName == null || iconName.isEmpty) return null;
    return _iconMap[iconName.toLowerCase()];
  }

  /// Returns true if a brand icon exists for the given [iconName].
  static bool hasIconForIconName(String? iconName) {
    return getIconForIconName(iconName) != null;
  }

  // ---------------------------------------------------------------------------
  // Legacy name-based lookup (used in _SubscriptionTile where iconName is not
  // always available — falls back to matching against subscription.name).
  // ---------------------------------------------------------------------------

  /// Attempts to find an icon by matching the [serviceName] display string
  /// against known service names. Returns null if no match found.
  ///
  /// Prefer [getIconForIconName] when the iconName field is available, as it
  /// is more reliable and more efficient.
  static IconData? getIconByName(String serviceName) {
    final name = serviceName.toLowerCase();

    // Try common known names — covers custom subscriptions that match
    // a known service but don't have an iconName set.
    if (name.contains('netflix')) return SimpleIcons.netflix;
    if (name.contains('spotify')) return SimpleIcons.spotify;
    if (name.contains('youtube')) return SimpleIcons.youtube;
    if (name.contains('apple music')) return SimpleIcons.applemusic;
    if (name.contains('apple tv')) return SimpleIcons.appletv;
    if (name.contains('apple arcade')) return SimpleIcons.applearcade;
    if (name.contains('icloud')) return SimpleIcons.icloud;
    if (name.contains('dropbox')) return SimpleIcons.dropbox;
    if (name.contains('amazon')) return SimpleIcons.amazon;
    if (name.contains('notion')) return SimpleIcons.notion;
    if (name.contains('figma')) return SimpleIcons.figma;
    if (name.contains('github')) return SimpleIcons.github;
    if (name.contains('discord')) return SimpleIcons.discord;
    if (name.contains('slack')) return SimpleIcons.slack;
    if (name.contains('zoom')) return SimpleIcons.zoom;
    if (name.contains('twitch')) return SimpleIcons.twitch;
    if (name.contains('tinder')) return SimpleIcons.tinder;
    if (name.contains('snapchat')) return SimpleIcons.snapchat;
    if (name.contains('patreon')) return SimpleIcons.patreon;
    if (name.contains('doordash')) return SimpleIcons.doordash;
    if (name.contains('uber')) return SimpleIcons.uber;
    if (name.contains('tesla')) return SimpleIcons.tesla;
    if (name.contains('duolingo')) return SimpleIcons.duolingo;
    if (name.contains('strava')) return SimpleIcons.strava;
    if (name.contains('peloton')) return SimpleIcons.peloton;
    if (name.contains('headspace')) return SimpleIcons.headspace;
    if (name.contains('coursera')) return SimpleIcons.coursera;
    if (name.contains('shopify')) return SimpleIcons.shopify;
    if (name.contains('canva')) return SimpleIcons.canva;
    if (name.contains('substack')) return SimpleIcons.substack;
    if (name.contains('medium')) return SimpleIcons.medium;
    if (name.contains('coinbase')) return SimpleIcons.coinbase;
    if (name.contains('nordvpn')) return SimpleIcons.nordvpn;
    if (name.contains('chatgpt') || name.contains('openai')) {
      return SimpleIcons.openai;
    }
    if (name.contains('claude') || name.contains('anthropic')) {
      return SimpleIcons.claude;
    }
    if (name.contains('perplexity')) return SimpleIcons.perplexity;
    if (name.contains('playstation')) return SimpleIcons.playstation;
    if (name.contains('target')) return SimpleIcons.target;
    if (name.contains('walmart')) return SimpleIcons.walmart;

    return null;
  }
}
