/// 太陽系3Dビュー用: 太陽・地球・月の詳細データ
class CelestialBody {
  final String id;
  final String nameJa;
  final String nameEn;
  final String emoji;
  final String tagline;

  /// 基礎データ（表形式で表示する項目）
  final List<CelestialFact> facts;

  /// 詳しい仕組みの解説（見出し付きセクションのリスト）
  final List<CelestialSection> sections;

  /// 豆知識（箇条書き）
  final List<String> funFacts;

  const CelestialBody({
    required this.id,
    required this.nameJa,
    required this.nameEn,
    required this.emoji,
    required this.tagline,
    required this.facts,
    required this.sections,
    required this.funFacts,
  });
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

const celestialBodies = <String, CelestialBody>{
  'sun': CelestialBody(
    id: 'sun',
    nameJa: '太陽',
    nameEn: 'Sun',
    emoji: '☀️',
    tagline: '太陽系の中心で光と熱を送り続ける恒星',
    facts: [
      CelestialFact('種類', '恒星（G型主系列星）'),
      CelestialFact('直径', '約139万km（地球の約109倍）'),
      CelestialFact('地球からの距離', '約1億5000万km（1天文単位）'),
      CelestialFact('表面温度', '約5500℃'),
      CelestialFact('中心温度', '約1600万℃'),
      CelestialFact('年齢', '約46億歳'),
      CelestialFact('主成分', '水素（約73%）とヘリウム（約25%）'),
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
    funFacts: [
      '太陽の中に地球がすっぽり約130万個入るほど大きい。',
      '太陽の表面には「黒点」と呼ばれる少し温度の低い黒っぽい部分があり、数が増えると地球のオーロラが活発になることがある。',
      '太陽もいつかは燃料を使い果たすが、あと約50億年は今のように輝き続けると考えられている。',
      '肉眼で太陽を直接見るのは大変危険。観察するときは必ず専用の日食グラスや投影法を使うこと。',
    ],
  ),
  'earth': CelestialBody(
    id: 'earth',
    nameJa: '地球',
    nameEn: 'Earth',
    emoji: '🌍',
    tagline: '生命であふれる青い惑星、私たちの故郷',
    facts: [
      CelestialFact('種類', '岩石惑星（太陽から3番目）'),
      CelestialFact('直径', '約1万2742km'),
      CelestialFact('自転周期', '約24時間（1日）'),
      CelestialFact('公転周期', '約365.25日（1年）'),
      CelestialFact('地軸の傾き', '約23.4度'),
      CelestialFact('衛星', '月（1個）'),
      CelestialFact('平均気温', '約15℃'),
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
    funFacts: [
      '地球は完全な球ではなく、自転の遠心力でわずかに赤道側がふくらんだ「楕円体」に近い形をしている。',
      '地球の表面の約7割は海でおおわれており、宇宙から見ると青く輝いて見えるため「ウォーターワールド」とも呼ばれる。',
      '地球の自転は少しずつ遅くなっており、大昔（約4億年前）は1日が約22時間しかなかったと考えられている。',
      '地球と同じくらいの大きさの岩石惑星は、太陽系の中では地球だけ。',
    ],
  ),
  'moon': CelestialBody(
    id: 'moon',
    nameJa: '月',
    nameEn: 'Moon',
    emoji: '🌕',
    tagline: '地球にいちばん近い天体、夜空を照らす衛星',
    facts: [
      CelestialFact('種類', '地球の衛星'),
      CelestialFact('直径', '約3474km（地球の約4分の1）'),
      CelestialFact('地球からの距離', '約38万km'),
      CelestialFact('公転周期（恒星月）', '約27.3日'),
      CelestialFact('満ち欠けの周期（朔望月）', '約29.5日'),
      CelestialFact('自転周期', '約27.3日（公転と同じ）'),
      CelestialFact('表面温度', '昼:約110℃ / 夜:約−170℃'),
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
    funFacts: [
      '月の重力が地球の海水を引っぱることで「潮の満ち引き」が起きている。',
      '1969年、アポロ11号によって人類は初めて月面に着陸した。',
      '月は地球から少しずつ（1年に約3.8cm）遠ざかっている。大昔はもっと近くにあり、もっと大きく明るく見えていたと考えられている。',
      '「スーパームーン」は月が地球に最も近づくタイミングで満月になる現象で、いつもより少し大きく明るく見える。',
    ],
  ),
};
