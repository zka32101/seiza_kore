# 星座コレ！ - Leonardo AI 画像生成プロンプト集

世界観: 夜空を向けてスマホで星座を発見・コレクションする天体観測アプリ。
ダークな紺色〜インディゴ〜パープルのグラデーション背景に、金色・白・淡い青のきらめく星々。
禅的で神秘的、かつ子供から大人まで親しめる温かみのあるトーン。

推奨モデル: Leonardo Phoenix / Leonardo Diffusion XL
推奨設定: Photo Real / Illustration スタイル寄り、Guidance Scale 7〜9

---

## 1. アプリアイコン（1024×1024）

```
App icon design for a stargazing constellation collection app, minimalist emblem,
a single glowing golden constellation line-art pattern (connected stars forming
a simple star shape) centered on a deep indigo to purple gradient circular
background, soft starlight glow, celestial and zen atmosphere, clean vector-style
icon, no text, no watermark, square format, high contrast, app store icon style,
centered composition
```
**ネガティブプロンプト**: `text, watermark, multiple objects, cluttered, photorealistic face, blurry, low contrast`
**サイズ**: 1024×1024（正方形）

---

## 2. Google Play フィーチャーグラフィック（1024×500）

```
Wide banner illustration for a constellation discovery mobile game, night sky
background with deep navy to purple gradient, scattered twinkling gold and pale
blue stars, a hand holding a smartphone pointing at the sky with a glowing
constellation line overlay appearing above it, dreamy and magical atmosphere,
warm and inviting tone, wide horizontal composition, cinematic lighting, no text,
digital illustration style
```
**ネガティブプロンプト**: `text, watermark, logo, cluttered, dark and scary, horror`
**サイズ**: 1024×500（横長）

---

## 3. オンボーディング背景1（発見・探索テーマ）

```
A person holding up a smartphone toward a starry night sky, silhouette style,
glowing constellation lines forming above the phone screen connecting real stars,
deep purple and indigo night sky gradient, warm golden light emanating from the
phone, sense of wonder and discovery, illustration style, soft dreamy atmosphere,
vertical mobile wallpaper composition
```
**サイズ**: 1080×1920（縦長・スマホ画面比率）

---

## 4. オンボーディング背景2（コレクション・図鑑テーマ）

```
An open magical star atlas book glowing softly, pages showing multiple small
constellation illustrations scattered like a collection album, golden constellation
line patterns floating above the pages, deep indigo background, warm amber and
soft blue lighting, sense of collecting and cataloging treasures, illustration
style, cozy magical library atmosphere, vertical mobile wallpaper composition
```
**サイズ**: 1080×1920（縦長・スマホ画面比率）

---

## 5. オンボーディング背景3（光年の時間旅行テーマ）

```
Abstract cosmic illustration depicting light traveling across vast space and time,
a beam of golden starlight stretching from a distant glowing star across a deep
purple and indigo galaxy background, subtle motion trail effect suggesting the
passage of thousands of years, dreamy nebula clouds, sense of awe and cosmic scale,
illustration style, vertical mobile wallpaper composition
```
**サイズ**: 1080×1920（縦長・スマホ画面比率）

---

## 6. ストア紹介用ヒーロー画像

```
Wide hero illustration for a constellation collecting mobile app store page,
a serene night sky filled with countless twinkling stars in deep indigo and
purple gradient, multiple golden constellation line patterns connecting stars
across the sky forming recognizable shapes like a bear, a swan, and a crown,
warm and magical atmosphere, dreamy soft glow, no text, no people, wide
landscape composition, premium app marketing illustration style
```
**サイズ**: 1920×1080（横長・マーケティング用）

---

## 生成後の配置先

| ファイル | 配置先 |
|---------|--------|
| 1. アプリアイコン | `assets/branding/app_icon_1024.png` |
| 2. フィーチャーグラフィック | `assets/branding/feature_graphic_1024x500.png` |
| 3-5. オンボーディング背景 | `assets/onboarding/onboarding_bg_1.png` 〜 `_3.png` |
| 6. ヒーロー画像 | `assets/branding/store_hero.png` |

配置後、以下を教えてください:
- アプリアイコン → `flutter_launcher_icons` パッケージでの自動生成に対応します
- オンボーディング背景 → `onboarding_screen.dart` への組み込みに対応します
