/// 太陽系3Dビュー用: 太陽・地球・月の詳細データ
class CelestialBody {
  final String id;
  final String nameJa;
  final String nameEn;
  final String emoji;
  final String tagline;
  final String taglineEn;

  /// 基礎データ（表形式で表示する項目）
  final List<CelestialFact> facts;
  final List<CelestialFact> factsEn;

  /// 詳しい仕組みの解説（見出し付きセクションのリスト）
  final List<CelestialSection> sections;
  final List<CelestialSection> sectionsEn;

  /// 豆知識（箇条書き）
  final List<String> funFacts;
  final List<String> funFactsEn;

  const CelestialBody({
    required this.id,
    required this.nameJa,
    required this.nameEn,
    required this.emoji,
    required this.tagline,
    this.taglineEn = '',
    required this.facts,
    this.factsEn = const [],
    required this.sections,
    this.sectionsEn = const [],
    required this.funFacts,
    this.funFactsEn = const [],
  });

  /// [languageCode]が'en'かつ英語版のデータがある場合は英語、それ以外は日本語を返す。
  String localizedTagline(String languageCode) =>
      languageCode == 'en' && taglineEn.isNotEmpty ? taglineEn : tagline;

  List<CelestialFact> localizedFacts(String languageCode) =>
      languageCode == 'en' && factsEn.isNotEmpty ? factsEn : facts;

  List<CelestialSection> localizedSections(String languageCode) =>
      languageCode == 'en' && sectionsEn.isNotEmpty ? sectionsEn : sections;

  List<String> localizedFunFacts(String languageCode) =>
      languageCode == 'en' && funFactsEn.isNotEmpty ? funFactsEn : funFacts;
}

class CelestialFact {
  final String label;
  final String value;
  const CelestialFact(this.label, this.value);
}

class CelestialSection {
  final String title;
  final String body;
  const CelestialSection(this.title, this.body);
}

/// 太陽系ビューのタブ表示順（太陽からの距離順、月は地球の隣に配置）
const solarSystemDisplayOrder = [
  'sun',
  'mercury',
  'venus',
  'earth',
  'moon',
  'mars',
  'jupiter',
  'saturn',
  'uranus',
  'neptune',
];

const celestialBodies = <String, CelestialBody>{
  'sun': CelestialBody(
    id: 'sun',
    nameJa: '太陽',
    nameEn: 'Sun',
    emoji: '☀️',
    tagline: '太陽系の中心で光と熱を送り続ける恒星',
    taglineEn: 'The star at the center of the solar system, endlessly sending out light and heat',
    facts: [
      CelestialFact('種類', '恒星（G型主系列星）'),
      CelestialFact('直径', '約139万km（地球の約109倍）'),
      CelestialFact('地球からの距離', '約1億5000万km（1天文単位）'),
      CelestialFact('表面温度', '約5500℃'),
      CelestialFact('中心温度', '約1600万℃'),
      CelestialFact('年齢', '約46億歳'),
      CelestialFact('主成分', '水素（約73%）とヘリウム（約25%）'),
    ],
    factsEn: [
      CelestialFact('Type', 'Star (G-type main-sequence star)'),
      CelestialFact('Diameter', 'About 1.39 million km (109× Earth)'),
      CelestialFact('Distance from Earth', 'About 150 million km (1 AU)'),
      CelestialFact('Surface temperature', 'About 5,500°C'),
      CelestialFact('Core temperature', 'About 16 million °C'),
      CelestialFact('Age', 'About 4.6 billion years'),
      CelestialFact('Main composition', 'Hydrogen (~73%) and helium (~25%)'),
    ],
    sections: [
      CelestialSection(
        '太陽はどうして光るの？',
        '太陽の中心部では、水素原子が非常に高い温度と圧力でぶつかり合い、ヘリウムに変わる「核融合反応」が起きています。このとき、ものすごいエネルギーが光と熱になって生まれ、太陽の表面から宇宙へと放たれています。太陽から出た光は、わずか約8分19秒で地球に届きます。',
      ),
      CelestialSection(
        '地球の生命を支える存在',
        '太陽の光と熱がなければ、地球の気温は氷点下まで下がり、植物は光合成ができず、生き物は生きていけません。太陽は地球のすべての生命にとって、なくてはならないエネルギー源です。また、太陽の重力が地球や他の惑星を引きつけているおかげで、惑星たちは太陽のまわりを回り続けることができています。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'Why does the Sun shine?',
        "At the Sun's core, hydrogen atoms collide under extreme temperature and pressure and fuse into helium — a process called nuclear fusion. This releases enormous amounts of energy as light and heat, which radiate outward from the Sun's surface into space. Light from the Sun takes only about 8 minutes and 19 seconds to reach Earth.",
      ),
      CelestialSection(
        'The source that sustains life on Earth',
        "Without the Sun's light and heat, Earth's temperature would plunge below freezing, plants couldn't photosynthesize, and living things couldn't survive. The Sun is an indispensable energy source for all life on Earth. Its gravity also holds Earth and the other planets in orbit, keeping the whole solar system together.",
      ),
    ],
    funFacts: [
      '太陽の中に地球がすっぽり約130万個入るほど大きい。',
      '太陽の表面には「黒点」と呼ばれる少し温度の低い黒っぽい部分があり、数が増えると地球のオーロラが活発になることがある。',
      '太陽もいつかは燃料を使い果たすが、あと約50億年は今のように輝き続けると考えられている。',
      '肉眼で太陽を直接見るのは大変危険。観察するときは必ず専用の日食グラスや投影法を使うこと。',
    ],
    funFactsEn: [
      'The Sun is so big that about 1.3 million Earths could fit inside it.',
      'Dark, slightly cooler patches called "sunspots" appear on the Sun\'s surface — when they become more numerous, auroras on Earth tend to become more active too.',
      'The Sun will eventually run out of fuel, but it is expected to keep shining much as it does now for about another 5 billion years.',
      "Looking directly at the Sun with the naked eye is extremely dangerous. Always use proper solar eclipse glasses or a projection method to observe it.",
    ],
  ),
  'earth': CelestialBody(
    id: 'earth',
    nameJa: '地球',
    nameEn: 'Earth',
    emoji: '🌍',
    tagline: '生命であふれる青い惑星、私たちの故郷',
    taglineEn: 'The blue planet teeming with life — our home',
    facts: [
      CelestialFact('種類', '岩石惑星（太陽から3番目）'),
      CelestialFact('直径', '約1万2742km'),
      CelestialFact('自転周期', '約24時間（1日）'),
      CelestialFact('公転周期', '約365.25日（1年）'),
      CelestialFact('地軸の傾き', '約23.4度'),
      CelestialFact('衛星', '月（1個）'),
      CelestialFact('平均気温', '約15℃'),
    ],
    factsEn: [
      CelestialFact('Type', 'Rocky planet (3rd from the Sun)'),
      CelestialFact('Diameter', 'About 12,742 km'),
      CelestialFact('Rotation period', 'About 24 hours (1 day)'),
      CelestialFact('Orbital period', 'About 365.25 days (1 year)'),
      CelestialFact('Axial tilt', 'About 23.4°'),
      CelestialFact('Moons', 'The Moon (1)'),
      CelestialFact('Average temperature', 'About 15°C'),
    ],
    sections: [
      CelestialSection(
        '自転と公転のちがい',
        '地球はコマのように自分自身でくるくる回っていて（自転）、1回転するのに約24時間かかります。これが「1日」の正体です。同時に地球は太陽のまわりを1周する動き（公転）もしていて、1周するのに約365日かかります。これが「1年」です。',
      ),
      CelestialSection(
        'なぜ季節が生まれるの？',
        '地球は地軸が約23.4度傾いたまま公転しています。この傾きのせいで、太陽の光が当たる角度が季節によって変わり、夏と冬、昼の長さの違いが生まれます。傾きがなければ、地球には季節の変化がありません。',
      ),
      CelestialSection(
        '生命を守る大気と磁場',
        '地球には厚い大気（空気の層）があり、有害な宇宙線や隕石から地表を守っています。また、地球の中心にある鉄でできた核が生み出す「磁場」は、太陽から吹き付ける危険な粒子の流れ（太陽風）をはね返すバリアの役割をしています。この2つのおかげで、地球は生命が安全に暮らせる惑星になっています。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'Rotation vs. revolution',
        "Earth spins on its own axis like a top — that's rotation — completing one turn in about 24 hours. That's what a \"day\" is. At the same time, Earth also travels once around the Sun — that's revolution (orbit) — taking about 365 days to complete a lap. That's a \"year.\"",
      ),
      CelestialSection(
        'Why do we have seasons?',
        "Earth orbits the Sun while its axis stays tilted at about 23.4°. Because of this tilt, the angle at which sunlight hits different parts of Earth changes through the year, creating summer and winter and changing the length of daylight. Without the tilt, Earth wouldn't have seasons at all.",
      ),
      CelestialSection(
        'The atmosphere and magnetic field that protect life',
        "Earth is wrapped in a thick atmosphere that shields the surface from harmful cosmic rays and meteorites. The iron core at Earth's center also generates a magnetic field, which acts like a shield deflecting the dangerous stream of particles blowing from the Sun (the solar wind). Together, these two features make Earth a safe place for life to thrive.",
      ),
    ],
    funFacts: [
      '地球は完全な球ではなく、自転の遠心力でわずかに赤道側がふくらんだ「楕円体」に近い形をしている。',
      '地球の表面の約7割は海でおおわれており、宇宙から見ると青く輝いて見えるため「ウォーターワールド」とも呼ばれる。',
      '地球の自転は少しずつ遅くなっており、大昔（約4億年前）は1日が約22時間しかなかったと考えられている。',
      '地球と同じくらいの大きさの岩石惑星は、太陽系の中では地球だけ。',
    ],
    funFactsEn: [
      "Earth isn't a perfect sphere — centrifugal force from its rotation makes it bulge slightly at the equator, giving it a shape closer to an ellipsoid.",
      'About 70% of Earth\'s surface is covered by ocean, which is why it looks blue from space — Earth is sometimes called the "water world."',
      "Earth's rotation is gradually slowing down; around 400 million years ago, a day is thought to have lasted only about 22 hours.",
      'Earth is the only rocky planet of its size in the solar system — no other rocky planet comes close to matching it.',
    ],
  ),
  'moon': CelestialBody(
    id: 'moon',
    nameJa: '月',
    nameEn: 'Moon',
    emoji: '🌕',
    tagline: '地球にいちばん近い天体、夜空を照らす衛星',
    taglineEn: "Earth's closest neighbor in space, the moon that lights up the night sky",
    facts: [
      CelestialFact('種類', '地球の衛星'),
      CelestialFact('直径', '約3474km（地球の約4分の1）'),
      CelestialFact('地球からの距離', '約38万km'),
      CelestialFact('公転周期（恒星月）', '約27.3日'),
      CelestialFact('満ち欠けの周期（朔望月）', '約29.5日'),
      CelestialFact('自転周期', '約27.3日（公転と同じ）'),
      CelestialFact('表面温度', '昼:約110℃ / 夜:約−170℃'),
    ],
    factsEn: [
      CelestialFact('Type', "Earth's moon"),
      CelestialFact('Diameter', 'About 3,474 km (about 1/4 of Earth)'),
      CelestialFact('Distance from Earth', 'About 380,000 km'),
      CelestialFact('Orbital period (sidereal month)', 'About 27.3 days'),
      CelestialFact('Phase cycle (synodic month)', 'About 29.5 days'),
      CelestialFact('Rotation period', 'About 27.3 days (same as orbit)'),
      CelestialFact('Surface temperature', 'Day: about 110°C / Night: about −170°C'),
    ],
    sections: [
      CelestialSection(
        'なぜ月は形が変わって見えるの？',
        '月は自分では光を出さず、太陽の光を反射して光って見えています。月は地球のまわりを約1か月かけて回っていて（公転）、その間に「太陽・地球・月」の位置関係が少しずつ変わります。地球から見て、太陽の光が月のどちら側に当たっているかによって、光って見える部分の形が変わる――これが満ち欠けの正体です。太陽に照らされた半分は常に光っていますが、地球からはその「光っている部分」がどれだけ見えるかが日によって変わるのです。',
      ),
      CelestialSection(
        '月の満ち欠けの順番',
        '新月（見えない）→ 三日月 → 上弦の月（右半分が光る）→ 十三夜 → 満月（まるく光る）→ 十六夜 → 下弦の月（左半分が光る）→ 二十六夜 → また新月、という順番で約29.5日かけて変化します。新月から新月までの日数が満ち欠けの1周期（朔望月）です。',
      ),
      CelestialSection(
        'なぜいつも同じ面しか見えないの？',
        '月は地球のまわりを1周する時間（公転周期）と、自分自身が1回転する時間（自転周期）がどちらも約27.3日でぴったり同じです。これを「潮汐固定（synchronous rotation）」と呼びます。そのため、地球からはいつも月の同じ面（表側）しか見ることができません。月の裏側は、宇宙探査機が撮影するまで人類には見えない場所でした。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'Why does the Moon change shape?',
        "The Moon doesn't produce its own light — it shines by reflecting sunlight. As the Moon orbits Earth over about a month, the relative positions of the Sun, Earth, and Moon keep shifting. Depending on which side of the Moon the sunlight hits (as seen from Earth), the shape of the lit portion we see changes — that's what causes the phases. Exactly half of the Moon is always lit by the Sun, but how much of that lit half we can see from Earth changes day by day.",
      ),
      CelestialSection(
        'The order of the Moon\'s phases',
        'New moon (invisible) → waxing crescent → first quarter (right half lit) → waxing gibbous → full moon (fully lit) → waning gibbous → last quarter (left half lit) → waning crescent → back to new moon — this cycle takes about 29.5 days. The time from one new moon to the next is one full phase cycle (synodic month).',
      ),
      CelestialSection(
        "Why do we always see the same side of the Moon?",
        "The time it takes the Moon to orbit Earth once (its orbital period) and the time it takes to rotate once on its own axis (its rotation period) are both exactly about 27.3 days. This is called \"synchronous rotation,\" or tidal locking. As a result, we always see the same side (the near side) of the Moon from Earth. The far side of the Moon remained unseen by humanity until spacecraft finally photographed it.",
      ),
    ],
    funFacts: [
      '月の重力が地球の海水を引っぱることで「潮の満ち引き」が起きている。',
      '1969年、アポロ11号によって人類は初めて月面に着陸した。',
      '月は地球から少しずつ（1年に約3.8cm）遠ざかっている。大昔はもっと近くにあり、もっと大きく明るく見えていたと考えられている。',
      '「スーパームーン」は月が地球に最も近づくタイミングで満月になる現象で、いつもより少し大きく明るく見える。',
    ],
    funFactsEn: [
      "The Moon's gravity pulling on Earth's oceans is what causes tides.",
      "In 1969, Apollo 11 carried the first humans to land on the Moon's surface.",
      'The Moon is slowly drifting away from Earth — about 3.8 cm per year. Long ago it was much closer, and would have looked bigger and brighter in the sky.',
      'A "supermoon" happens when a full moon coincides with the Moon being at its closest point to Earth, making it look slightly bigger and brighter than usual.',
    ],
  ),
  'mercury': CelestialBody(
    id: 'mercury',
    nameJa: '水星',
    nameEn: 'Mercury',
    emoji: '🪨',
    tagline: '太陽系でいちばん内側を回る、灼熱と極寒の小さな星',
    taglineEn: 'The innermost planet of the solar system — a small world of scorching heat and bitter cold',
    facts: [
      CelestialFact('種類', '岩石惑星（太陽から1番目）'),
      CelestialFact('直径', '約4879km（地球の約0.38倍）'),
      CelestialFact('公転周期', '約88日'),
      CelestialFact('自転周期', '約59日'),
      CelestialFact('衛星', 'なし'),
      CelestialFact('表面温度', '昼:約430℃ / 夜:約−180℃'),
    ],
    factsEn: [
      CelestialFact('Type', '1st rocky planet from the Sun'),
      CelestialFact('Diameter', 'About 4,879 km (about 0.38× Earth)'),
      CelestialFact('Orbital period', 'About 88 days'),
      CelestialFact('Rotation period', 'About 59 days'),
      CelestialFact('Moons', 'None'),
      CelestialFact('Surface temperature', 'Day: about 430°C / Night: about −180°C'),
    ],
    sections: [
      CelestialSection(
        '太陽にいちばん近いのに極寒の夜がある星',
        '水星には大気がほとんどないため、太陽の熱を保つことができません。太陽が当たる昼側は430℃を超える灼熱になる一方、夜側は−180℃まで冷え込みます。1日の寒暖差が太陽系でもっとも大きい惑星です。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'Closest to the Sun, yet freezing at night',
        "Mercury has almost no atmosphere, so it can't hold onto the Sun's heat. The sunlit side soars above 430°C, while the night side plunges to about −180°C — the largest day-to-night temperature swing of any planet in the solar system.",
      ),
    ],
    funFacts: [
      '水星の1年（公転88日）は、水星の2日（自転59日×2ではなく、太陽から見た昼夜の長さ）よりも短い、不思議な自転と公転の関係を持つ。',
      '地球から見ると太陽に近すぎて、明け方か夕方の短い時間しか観測できない。',
    ],
    funFactsEn: [
      "Mercury's rotation and orbit are strangely linked: because of its slow spin combined with its fast orbit, a single solar day on Mercury (sunrise to sunrise) lasts about 176 Earth days — longer than its own year.",
      "From Earth, Mercury stays so close to the Sun that it can only be observed for a short while around dawn or dusk.",
    ],
  ),
  'venus': CelestialBody(
    id: 'venus',
    nameJa: '金星',
    nameEn: 'Venus',
    emoji: '💛',
    tagline: '「宵の明星」「明けの明星」として輝く、地球のすぐ内側の惑星',
    taglineEn: 'The planet just inside Earth\'s orbit, shining as the "evening star" and "morning star"',
    facts: [
      CelestialFact('種類', '岩石惑星（太陽から2番目）'),
      CelestialFact('直径', '約1万2104km（地球とほぼ同じ）'),
      CelestialFact('公転周期', '約225日'),
      CelestialFact('自転周期', '約243日（惑星の中で最も遅い、しかも逆回転）'),
      CelestialFact('表面温度', '約470℃（太陽系で最も高温）'),
    ],
    factsEn: [
      CelestialFact('Type', '2nd rocky planet from the Sun'),
      CelestialFact('Diameter', 'About 12,104 km (nearly the same as Earth)'),
      CelestialFact('Orbital period', 'About 225 days'),
      CelestialFact('Rotation period', 'About 243 days (the slowest of any planet, and it spins backward)'),
      CelestialFact('Surface temperature', 'About 470°C (the hottest in the solar system)'),
    ],
    sections: [
      CelestialSection(
        '大きさは地球の双子なのに灼熱地獄',
        '金星は大きさや重さが地球とよく似ているため「地球の双子星」と呼ばれます。しかし分厚い二酸化炭素の大気による強力な温室効果で、表面温度は水星よりも高い約470℃に達します。硫酸の雲におおわれ、大気の圧力も地球の90倍以上あります。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        "Earth's twin in size, but a scorching inferno",
        'Venus is often called "Earth\'s twin" because it is so similar to Earth in size and mass. But a thick carbon dioxide atmosphere traps heat in a runaway greenhouse effect, driving the surface temperature to about 470°C — even hotter than Mercury. Venus is shrouded in clouds of sulfuric acid, and its atmospheric pressure is more than 90 times that of Earth.',
      ),
    ],
    funFacts: [
      '明け方や夕方の空に一際明るく見えることから「明けの明星」「宵の明星」と呼ばれ、太陽・月の次に明るい天体。',
      '金星は他の惑星と逆方向に自転しており、金星から見ると太陽は西から昇り東に沈む。',
    ],
    funFactsEn: [
      'Venus shines so brightly at dawn or dusk that it is called the "morning star" or "evening star" — it is the brightest object in the sky after the Sun and Moon.',
      'Venus rotates in the opposite direction to most planets, so if you stood on its surface, the Sun would rise in the west and set in the east.',
    ],
  ),
  'mars': CelestialBody(
    id: 'mars',
    nameJa: '火星',
    nameEn: 'Mars',
    emoji: '🔴',
    tagline: '赤く輝く「赤い惑星」、人類が次に目指す天体',
    taglineEn: 'The glowing "Red Planet" — humanity\'s next destination',
    facts: [
      CelestialFact('種類', '岩石惑星（太陽から4番目）'),
      CelestialFact('直径', '約6779km（地球の約0.53倍）'),
      CelestialFact('公転周期', '約687日（地球のおよそ2倍）'),
      CelestialFact('自転周期', '約24時間37分（地球とよく似ている）'),
      CelestialFact('衛星', 'フォボス・ダイモス（2個）'),
    ],
    factsEn: [
      CelestialFact('Type', '4th rocky planet from the Sun'),
      CelestialFact('Diameter', 'About 6,779 km (about 0.53× Earth)'),
      CelestialFact('Orbital period', 'About 687 days (roughly 2× Earth\'s)'),
      CelestialFact('Rotation period', 'About 24 hours 37 minutes (very close to Earth\'s)'),
      CelestialFact('Moons', 'Phobos and Deimos (2)'),
    ],
    sections: [
      CelestialSection(
        'なぜ赤く見えるの？',
        '火星の表面は酸化鉄（さびた鉄）を多く含む砂や岩でおおわれているため、赤っぽい色に見えます。かつては水が流れていた跡や、太陽系最大の火山「オリンポス山」（富士山の約2.5倍の高さ）など、ダイナミックな地形を持つ惑星です。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'Why does Mars look red?',
        "Mars's surface is covered in sand and rock rich in iron oxide — essentially rust — which gives it its reddish color. Mars has dramatic terrain, including traces of ancient flowing water and Olympus Mons, the largest volcano in the solar system (about 2.5 times the height of Mt. Fuji).",
      ),
    ],
    funFacts: [
      '1日の長さが地球とほぼ同じ（24時間37分）で、四季もあることから、将来の移住候補地として世界中で探査が進められている。',
      'NASAの探査車「パーサヴィアランス」などが現在も火星表面を探査中。',
    ],
    funFactsEn: [
      "Mars has a day almost the same length as Earth's (24 hours 37 minutes) and even has seasons, which is why it's studied worldwide as a candidate for future human settlement.",
      'NASA\'s Perseverance rover and other missions are still exploring the surface of Mars today.',
    ],
  ),
  'jupiter': CelestialBody(
    id: 'jupiter',
    nameJa: '木星',
    nameEn: 'Jupiter',
    emoji: '🟠',
    tagline: '太陽系最大の巨大ガス惑星、「大赤斑」で知られる王者',
    taglineEn: 'The solar system\'s largest gas giant, ruler of the planets and home of the Great Red Spot',
    facts: [
      CelestialFact('種類', '木星型惑星（ガス惑星、太陽から5番目）'),
      CelestialFact('直径', '約13万9820km（地球の約11倍）'),
      CelestialFact('公転周期', '約12年'),
      CelestialFact('自転周期', '約9時間56分（惑星の中で最も速い自転）'),
      CelestialFact('衛星', '約95個（ガリレオ衛星など）'),
    ],
    factsEn: [
      CelestialFact('Type', 'Gas giant (5th planet from the Sun)'),
      CelestialFact('Diameter', 'About 139,820 km (about 11× Earth)'),
      CelestialFact('Orbital period', 'About 12 years'),
      CelestialFact('Rotation period', 'About 9 hours 56 minutes (the fastest spin of any planet)'),
      CelestialFact('Moons', 'About 95 (including the Galilean moons)'),
    ],
    sections: [
      CelestialSection(
        '太陽系の「王者」木星',
        '木星は太陽系にあるすべての惑星を合わせた質量の2倍以上を持つ、圧倒的な巨大惑星です。表面には「大赤斑」と呼ばれる、地球が2〜3個入るほど巨大な渦巻く嵐が、少なくとも300年以上吹き続けています。ガリレオ・ガリレイが発見した4つの衛星（イオ・エウロパ・ガニメデ・カリスト）は、小さな双眼鏡でも観察できることがある。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'Jupiter, king of the solar system',
        'Jupiter is so massive that it weighs more than twice as much as all the other planets in the solar system combined. Its surface features the Great Red Spot, a giant swirling storm large enough to fit two or three Earths inside it, which has been raging for at least 300 years. The four Galilean moons discovered by Galileo Galilei — Io, Europa, Ganymede, and Callisto — can sometimes even be spotted with a small pair of binoculars.',
      ),
    ],
    funFacts: [
      '衛星エウロパは、氷の下に液体の海があると考えられており、生命探査の重要な候補地とされている。',
      '木星が「衝」（地球から見て太陽の反対側にくる時期）になると一年で最も明るく大きく見え、観測の好機となる。',
    ],
    funFactsEn: [
      "Jupiter's moon Europa is thought to hide a liquid ocean beneath its icy crust, making it one of the most promising places to search for life beyond Earth.",
      'When Jupiter reaches "opposition" (positioned opposite the Sun as seen from Earth), it appears at its biggest and brightest of the year — the best time to observe it.',
    ],
  ),
  'saturn': CelestialBody(
    id: 'saturn',
    nameJa: '土星',
    nameEn: 'Saturn',
    emoji: '🪐',
    tagline: '美しい環を持つ、太陽系で2番目に大きな惑星',
    taglineEn: 'The second-largest planet in the solar system, famous for its beautiful rings',
    facts: [
      CelestialFact('種類', '木星型惑星（ガス惑星、太陽から6番目）'),
      CelestialFact('直径', '約11万6460km（地球の約9倍）'),
      CelestialFact('公転周期', '約29年'),
      CelestialFact('自転周期', '約10時間34分'),
      CelestialFact('衛星', '約145個（タイタンなど）'),
    ],
    factsEn: [
      CelestialFact('Type', 'Gas giant (6th planet from the Sun)'),
      CelestialFact('Diameter', 'About 116,460 km (about 9× Earth)'),
      CelestialFact('Orbital period', 'About 29 years'),
      CelestialFact('Rotation period', 'About 10 hours 34 minutes'),
      CelestialFact('Moons', 'About 145 (including Titan)'),
    ],
    sections: [
      CelestialSection(
        'なぜ環（わ）があるの？',
        '土星の環は、氷や岩石のかけらが土星のまわりを無数に回っている帯です。厚さはわずか数十m〜数kmしかないのに、幅は27万kmを超え、地球と月の距離の3分の2ほどもあります。かつて土星に近づきすぎた氷衛星や彗星が、強い重力で砕かれてできたという説が有力です。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'Why does Saturn have rings?',
        "Saturn's rings are made of countless chunks of ice and rock orbiting the planet. Although the rings are only tens of meters to a few kilometers thick, they stretch more than 270,000 km wide — about two-thirds of the distance between Earth and the Moon. The leading theory is that they formed when an icy moon or comet strayed too close to Saturn and was torn apart by its powerful gravity.",
      ),
    ],
    funFacts: [
      '土星は密度が非常に低く、もし水の入った巨大なプールがあれば土星は浮くと言われるほど。',
      '衛星タイタンは分厚い大気を持ち、メタンの海や川があると考えられている、太陽系でも特に個性的な衛星。',
    ],
    funFactsEn: [
      "Saturn's density is so low that, if you could find a bathtub big enough, the planet would actually float in water.",
      "Saturn's moon Titan has a thick atmosphere and is thought to have rivers and seas of liquid methane, making it one of the most unique moons in the solar system.",
    ],
  ),
  'uranus': CelestialBody(
    id: 'uranus',
    nameJa: '天王星',
    nameEn: 'Uranus',
    emoji: '🔵',
    tagline: '横倒しで自転する、青緑色の氷惑星',
    taglineEn: 'A blue-green ice giant that spins on its side',
    facts: [
      CelestialFact('種類', '天王星型惑星（氷惑星、太陽から7番目）'),
      CelestialFact('直径', '約5万724km（地球の約4倍）'),
      CelestialFact('公転周期', '約84年'),
      CelestialFact('自転周期', '約17時間14分（横倒しで自転）'),
      CelestialFact('衛星', '27個'),
    ],
    factsEn: [
      CelestialFact('Type', 'Ice giant (7th planet from the Sun)'),
      CelestialFact('Diameter', 'About 50,724 km (about 4× Earth)'),
      CelestialFact('Orbital period', 'About 84 years'),
      CelestialFact('Rotation period', 'About 17 hours 14 minutes (spins on its side)'),
      CelestialFact('Moons', '27'),
    ],
    sections: [
      CelestialSection(
        '横倒しで転がるように公転する惑星',
        '天王星の地軸は約98度も傾いており、まるでコロコロと横倒しで転がるように太陽のまわりを回っています。大昔に大きな天体が衝突した影響と考えられています。大気中のメタンが赤い光を吸収するため、青緑色に見えます。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'A planet that rolls around the Sun on its side',
        "Uranus's axis is tilted by about 98°, so it essentially rolls around the Sun on its side rather than spinning upright like most planets. This is thought to be the result of a massive collision long ago. Methane in its atmosphere absorbs red light, giving the planet its blue-green color.",
      ),
    ],
    funFacts: [
      '1781年にウィリアム・ハーシェルによって発見された、望遠鏡で発見された初めての惑星。',
      '極端な地軸の傾きにより、1年（84年）のうち約42年間ずっと昼、残り約42年間ずっと夜という極地帯がある。',
    ],
    funFactsEn: [
      'Uranus was discovered by William Herschel in 1781 — the first planet ever found using a telescope.',
      "Because of its extreme axial tilt, parts of Uranus experience about 42 straight years of daylight followed by about 42 straight years of darkness during its 84-year orbit.",
    ],
  ),
  'neptune': CelestialBody(
    id: 'neptune',
    nameJa: '海王星',
    nameEn: 'Neptune',
    emoji: '🌐',
    tagline: '太陽から最も遠い、太陽系最果ての青い惑星',
    taglineEn: 'The farthest planet from the Sun — a deep blue world at the edge of the solar system',
    facts: [
      CelestialFact('種類', '天王星型惑星（氷惑星、太陽から8番目）'),
      CelestialFact('直径', '約4万9244km（地球の約3.9倍）'),
      CelestialFact('公転周期', '約165年'),
      CelestialFact('自転周期', '約16時間6分'),
      CelestialFact('衛星', '16個（トリトンなど）'),
    ],
    factsEn: [
      CelestialFact('Type', 'Ice giant (8th planet from the Sun)'),
      CelestialFact('Diameter', 'About 49,244 km (about 3.9× Earth)'),
      CelestialFact('Orbital period', 'About 165 years'),
      CelestialFact('Rotation period', 'About 16 hours 6 minutes'),
      CelestialFact('Moons', '16 (including Triton)'),
    ],
    sections: [
      CelestialSection(
        '数学の計算から見つかった惑星',
        '海王星は、実際に望遠鏡で偶然発見されたのではなく、天王星の動きのわずかな乱れから「そこに未知の惑星があるはず」と数学的に予測され、1846年にその予測位置付近で発見されました。太陽系の中で最も風が強く、秒速600mにも達する暴風が吹き荒れています。',
      ),
    ],
    sectionsEn: [
      CelestialSection(
        'The planet discovered through mathematics',
        "Neptune wasn't found by chance through a telescope — its existence was predicted mathematically from slight irregularities in Uranus's orbit, and it was discovered near the predicted position in 1846. Neptune has the strongest winds in the solar system, with storms reaching speeds of up to 600 meters per second.",
      ),
    ],
    funFacts: [
      '発見から2026年現在でまだ1周（約165年）していない。1846年の発見から2011年でようやく公転1周を終えた。',
      '衛星トリトンは海王星の自転と逆方向に公転する珍しい衛星で、将来は海王星に落下すると考えられている。',
    ],
    funFactsEn: [
      "Neptune completed its first full orbit since its 1846 discovery only in 2011 — a single Neptunian year lasts about 165 Earth years.",
      "Neptune's moon Triton orbits in the opposite direction to the planet's rotation, an unusual trait, and is expected to eventually spiral into Neptune in the distant future.",
    ],
  ),
};
