"""
Build complete Quran SQLite database from Tanzil.net text file.
Downloads the Uthmani text and creates quran_uthmani.db with all 6236 ayahs.
"""
import sqlite3
import urllib.request
import os
import sys

DB_PATH = os.path.join(os.path.dirname(__file__), '..', 'assets', 'db', 'quran_uthmani.db')
# Full Uthmani text (preserves waqf marks like صلى، قلى، ج) — we strip only circles in parse
TANZIL_URL = 'https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt-2&agree=true'

# Unicode chars to strip (circle marks that appear as brown dots)
STRIP_CHARS = [
    '\u06DF',  # ARABIC SMALL HIGH ROUNDED ZERO (the brown circle)
    '\u06E1',  # ARABIC SMALL HIGH DOTLESS HEAD OF KHAH
]

# Surah metadata: (number, name_arabic, name_english, ayah_count, revelation_type)
SURAHS = [
    (1, "الفاتحة", "Al-Fatiha", 7, "Meccan"),
    (2, "البقرة", "Al-Baqarah", 286, "Medinan"),
    (3, "آل عمران", "Aal-Imran", 200, "Medinan"),
    (4, "النساء", "An-Nisa", 176, "Medinan"),
    (5, "المائدة", "Al-Ma'idah", 120, "Medinan"),
    (6, "الأنعام", "Al-An'am", 165, "Meccan"),
    (7, "الأعراف", "Al-A'raf", 206, "Meccan"),
    (8, "الأنفال", "Al-Anfal", 75, "Medinan"),
    (9, "التوبة", "At-Tawbah", 129, "Medinan"),
    (10, "يونس", "Yunus", 109, "Meccan"),
    (11, "هود", "Hud", 123, "Meccan"),
    (12, "يوسف", "Yusuf", 111, "Meccan"),
    (13, "الرعد", "Ar-Ra'd", 43, "Medinan"),
    (14, "إبراهيم", "Ibrahim", 52, "Meccan"),
    (15, "الحجر", "Al-Hijr", 99, "Meccan"),
    (16, "النحل", "An-Nahl", 128, "Meccan"),
    (17, "الإسراء", "Al-Isra", 111, "Meccan"),
    (18, "الكهف", "Al-Kahf", 110, "Meccan"),
    (19, "مريم", "Maryam", 98, "Meccan"),
    (20, "طه", "Ta-Ha", 135, "Meccan"),
    (21, "الأنبياء", "Al-Anbiya", 112, "Meccan"),
    (22, "الحج", "Al-Hajj", 78, "Medinan"),
    (23, "المؤمنون", "Al-Mu'minun", 118, "Meccan"),
    (24, "النور", "An-Nur", 64, "Medinan"),
    (25, "الفرقان", "Al-Furqan", 77, "Meccan"),
    (26, "الشعراء", "Ash-Shu'ara", 227, "Meccan"),
    (27, "النمل", "An-Naml", 93, "Meccan"),
    (28, "القصص", "Al-Qasas", 88, "Meccan"),
    (29, "العنكبوت", "Al-Ankabut", 69, "Meccan"),
    (30, "الروم", "Ar-Rum", 60, "Meccan"),
    (31, "لقمان", "Luqman", 34, "Meccan"),
    (32, "السجدة", "As-Sajdah", 30, "Meccan"),
    (33, "الأحزاب", "Al-Ahzab", 73, "Medinan"),
    (34, "سبأ", "Saba", 54, "Meccan"),
    (35, "فاطر", "Fatir", 45, "Meccan"),
    (36, "يس", "Ya-Sin", 83, "Meccan"),
    (37, "الصافات", "As-Saffat", 182, "Meccan"),
    (38, "ص", "Sad", 88, "Meccan"),
    (39, "الزمر", "Az-Zumar", 75, "Meccan"),
    (40, "غافر", "Ghafir", 85, "Meccan"),
    (41, "فصلت", "Fussilat", 54, "Meccan"),
    (42, "الشورى", "Ash-Shura", 53, "Meccan"),
    (43, "الزخرف", "Az-Zukhruf", 89, "Meccan"),
    (44, "الدخان", "Ad-Dukhan", 59, "Meccan"),
    (45, "الجاثية", "Al-Jathiyah", 37, "Meccan"),
    (46, "الأحقاف", "Al-Ahqaf", 35, "Meccan"),
    (47, "محمد", "Muhammad", 38, "Medinan"),
    (48, "الفتح", "Al-Fath", 29, "Medinan"),
    (49, "الحجرات", "Al-Hujurat", 18, "Medinan"),
    (50, "ق", "Qaf", 45, "Meccan"),
    (51, "الذاريات", "Adh-Dhariyat", 60, "Meccan"),
    (52, "الطور", "At-Tur", 49, "Meccan"),
    (53, "النجم", "An-Najm", 62, "Meccan"),
    (54, "القمر", "Al-Qamar", 55, "Meccan"),
    (55, "الرحمن", "Ar-Rahman", 78, "Medinan"),
    (56, "الواقعة", "Al-Waqi'ah", 96, "Meccan"),
    (57, "الحديد", "Al-Hadid", 29, "Medinan"),
    (58, "المجادلة", "Al-Mujadila", 22, "Medinan"),
    (59, "الحشر", "Al-Hashr", 24, "Medinan"),
    (60, "الممتحنة", "Al-Mumtahanah", 13, "Medinan"),
    (61, "الصف", "As-Saff", 14, "Medinan"),
    (62, "الجمعة", "Al-Jumu'ah", 11, "Medinan"),
    (63, "المنافقون", "Al-Munafiqun", 11, "Medinan"),
    (64, "التغابن", "At-Taghabun", 18, "Medinan"),
    (65, "الطلاق", "At-Talaq", 12, "Medinan"),
    (66, "التحريم", "At-Tahrim", 12, "Medinan"),
    (67, "الملك", "Al-Mulk", 30, "Meccan"),
    (68, "القلم", "Al-Qalam", 52, "Meccan"),
    (69, "الحاقة", "Al-Haqqah", 52, "Meccan"),
    (70, "المعارج", "Al-Ma'arij", 44, "Meccan"),
    (71, "نوح", "Nuh", 28, "Meccan"),
    (72, "الجن", "Al-Jinn", 28, "Meccan"),
    (73, "المزمل", "Al-Muzzammil", 20, "Meccan"),
    (74, "المدثر", "Al-Muddaththir", 56, "Meccan"),
    (75, "القيامة", "Al-Qiyamah", 40, "Meccan"),
    (76, "الإنسان", "Al-Insan", 31, "Medinan"),
    (77, "المرسلات", "Al-Mursalat", 50, "Meccan"),
    (78, "النبأ", "An-Naba", 40, "Meccan"),
    (79, "النازعات", "An-Nazi'at", 46, "Meccan"),
    (80, "عبس", "Abasa", 42, "Meccan"),
    (81, "التكوير", "At-Takwir", 29, "Meccan"),
    (82, "الانفطار", "Al-Infitar", 19, "Meccan"),
    (83, "المطففين", "Al-Mutaffifin", 36, "Meccan"),
    (84, "الانشقاق", "Al-Inshiqaq", 25, "Meccan"),
    (85, "البروج", "Al-Buruj", 22, "Meccan"),
    (86, "الطارق", "At-Tariq", 17, "Meccan"),
    (87, "الأعلى", "Al-A'la", 19, "Meccan"),
    (88, "الغاشية", "Al-Ghashiyah", 26, "Meccan"),
    (89, "الفجر", "Al-Fajr", 30, "Meccan"),
    (90, "البلد", "Al-Balad", 20, "Meccan"),
    (91, "الشمس", "Ash-Shams", 15, "Meccan"),
    (92, "الليل", "Al-Layl", 21, "Meccan"),
    (93, "الضحى", "Ad-Duha", 11, "Meccan"),
    (94, "الشرح", "Ash-Sharh", 8, "Meccan"),
    (95, "التين", "At-Tin", 8, "Meccan"),
    (96, "العلق", "Al-Alaq", 19, "Meccan"),
    (97, "القدر", "Al-Qadr", 5, "Meccan"),
    (98, "البينة", "Al-Bayyinah", 8, "Medinan"),
    (99, "الزلزلة", "Az-Zalzalah", 8, "Medinan"),
    (100, "العاديات", "Al-Adiyat", 11, "Meccan"),
    (101, "القارعة", "Al-Qari'ah", 11, "Meccan"),
    (102, "التكاثر", "At-Takathur", 8, "Meccan"),
    (103, "العصر", "Al-Asr", 3, "Meccan"),
    (104, "الهمزة", "Al-Humazah", 9, "Meccan"),
    (105, "الفيل", "Al-Fil", 5, "Meccan"),
    (106, "قريش", "Quraysh", 4, "Meccan"),
    (107, "الماعون", "Al-Ma'un", 7, "Meccan"),
    (108, "الكوثر", "Al-Kawthar", 3, "Meccan"),
    (109, "الكافرون", "Al-Kafirun", 6, "Meccan"),
    (110, "النصر", "An-Nasr", 3, "Medinan"),
    (111, "المسد", "Al-Masad", 5, "Meccan"),
    (112, "الإخلاص", "Al-Ikhlas", 4, "Meccan"),
    (113, "الفلق", "Al-Falaq", 5, "Meccan"),
    (114, "الناس", "An-Nas", 6, "Meccan"),
]

def download_quran_text():
    """Download Quran text from Tanzil.net"""
    print("Downloading Quran text from Tanzil.net...")
    req = urllib.request.Request(TANZIL_URL, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        response = urllib.request.urlopen(req, timeout=30)
        text = response.read().decode('utf-8')
        print(f"Downloaded {len(text)} bytes")
        return text
    except Exception as e:
        print(f"Download failed: {e}")
        print("Trying alternative source...")
        # Try alternative: tanzil.net simple text
        alt_url = 'https://tanzil.net/pub/download/index.php?quranType=uthmani&outType=txt-2&agree=true'
        try:
            req2 = urllib.request.Request(alt_url, headers={'User-Agent': 'Mozilla/5.0'})
            response = urllib.request.urlopen(req2, timeout=30)
            return response.read().decode('utf-8')
        except:
            return None

def strip_circles(text):
    """Remove only circle marks from text, preserving waqf signs"""
    for ch in STRIP_CHARS:
        text = text.replace(ch, '')
    return text

def parse_tanzil_text(text):
    """Parse Tanzil format: sura|aya|text, strip circles and Bismillah.
    
    Uses two-pass approach:
    1. First pass: parse all ayahs, capture Bismillah from Al-Fatiha:1
    2. Second pass: strip Bismillah prefix from first ayah of each surah
    """
    # First pass: collect raw ayahs and find Bismillah
    raw_ayahs = []
    bismillah = None
    
    for line in text.strip().split('\n'):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        parts = line.split('|', 2)
        if len(parts) == 3:
            sura = int(parts[0])
            aya = int(parts[1])
            txt = parts[2].strip()
            # Strip circle marks
            txt = strip_circles(txt)
            raw_ayahs.append((sura, aya, txt))
            # Capture Al-Fatiha ayah 1 as the Bismillah text
            if sura == 1 and aya == 1:
                bismillah = txt.strip()
                print(f"  Captured Bismillah: {bismillah[:40]}...")
    
    if not bismillah:
        print("  WARNING: Could not capture Bismillah from Al-Fatiha!")
        return raw_ayahs
    
    # Second pass: strip Bismillah from first ayah of other surahs
    ayahs = []
    stripped_count = 0
    for sura, aya, txt in raw_ayahs:
        if aya == 1 and sura != 1 and sura != 9:  # Skip Al-Fatiha and At-Tawbah
            if txt.startswith(bismillah):
                txt = txt[len(bismillah):].strip()
                stripped_count += 1
        ayahs.append((sura, aya, txt))
    
    print(f"  Stripped Bismillah from {stripped_count} surahs")
    return ayahs

def build_database(ayahs):
    """Create SQLite database with suras and quran_text tables"""
    # Remove old DB
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    # Create suras table
    cursor.execute('''
        CREATE TABLE suras (
            id INTEGER PRIMARY KEY,
            name_arabic TEXT NOT NULL,
            name_english TEXT NOT NULL,
            ayah_count INTEGER NOT NULL,
            revelation_type TEXT NOT NULL
        )
    ''')
    
    # Create quran_text table
    cursor.execute('''
        CREATE TABLE quran_text (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sura INTEGER NOT NULL,
            aya INTEGER NOT NULL,
            text TEXT NOT NULL
        )
    ''')
    
    # Insert surahs
    for s in SURAHS:
        cursor.execute(
            'INSERT INTO suras (id, name_arabic, name_english, ayah_count, revelation_type) VALUES (?, ?, ?, ?, ?)',
            s
        )
    
    # Insert ayahs
    cursor.executemany(
        'INSERT INTO quran_text (sura, aya, text) VALUES (?, ?, ?)',
        ayahs
    )
    
    # Create indexes
    cursor.execute('CREATE INDEX idx_quran_text_sura ON quran_text(sura)')
    cursor.execute('CREATE INDEX idx_quran_text_sura_aya ON quran_text(sura, aya)')
    
    conn.commit()
    
    # Verify
    cursor.execute('SELECT COUNT(*) FROM quran_text')
    total = cursor.fetchone()[0]
    cursor.execute('SELECT COUNT(DISTINCT sura) FROM quran_text')
    sura_count = cursor.fetchone()[0]
    
    conn.close()
    
    db_size = os.path.getsize(DB_PATH)
    print(f"\n=== Database built successfully ===")
    print(f"Total ayahs: {total}")
    print(f"Total surahs: {sura_count}")
    print(f"DB size: {db_size / 1024:.1f} KB")
    
    return total

if __name__ == '__main__':
    text = download_quran_text()
    if text:
        ayahs = parse_tanzil_text(text)
        if ayahs:
            total = build_database(ayahs)
            if total >= 6236:
                print("\n✅ Full Quran database ready!")
            else:
                print(f"\n⚠️ Only {total} ayahs found (expected 6236)")
        else:
            print("❌ Failed to parse Tanzil text")
    else:
        print("❌ Failed to download Quran text")
