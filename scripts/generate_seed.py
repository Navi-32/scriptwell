"""Generates database/05_seed.sql and the SVG book covers in
src/main/webapp/assets/covers from one list, so they always match.

    python scripts/generate_seed.py
"""
import html
import os
import textwrap

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
COVERS = os.path.join(ROOT, "src", "main", "webapp", "assets", "covers")
SEED = os.path.join(ROOT, "database", "05_seed.sql")

CATEGORIES = [
    # name, description, bootstrap icon, cover palette (top, bottom, accent)
    ("Classics", "Timeless literature that shaped the world", "bi-bank", ("#5b2333", "#2b0f18", "#e8c07d")),
    ("Fiction", "Contemporary novels and modern storytelling", "bi-feather", ("#1f4e5f", "#0d2630", "#f4d58d")),
    ("Fantasy & Sci-Fi", "Other worlds, distant futures and epic quests", "bi-stars", ("#2a1b5c", "#0b0820", "#9fd8ff")),
    ("Mystery & Thriller", "Page-turners full of suspense and secrets", "bi-incognito", ("#262626", "#050505", "#d64545")),
    ("Programming", "Software craft, languages and computer science", "bi-code-slash", ("#0f3d3e", "#04181a", "#5ee3b5")),
    ("Science", "Big ideas about the universe, life and humanity", "bi-globe-americas", ("#13315c", "#061325", "#ffb703")),
    ("Self-Help & Business", "Habits, money and the art of doing great work", "bi-graph-up-arrow", ("#7a3e00", "#2e1700", "#ffe8a3")),
]

# title, author, category index, price, stock, publisher, year, pages, rating, description
BOOKS = [
    ("Pride and Prejudice", "Jane Austen", 0, 299, 40, "Penguin Classics", 1813, 432, 4.7,
     "Elizabeth Bennet trades sharp words with the proud Mr Darcy in a witty study of manners, marriage and first impressions in Regency England."),
    ("1984", "George Orwell", 0, 349, 55, "Penguin Modern", 1949, 328, 4.8,
     "Winston Smith quietly rebels against a regime that watches every move and rewrites every truth. A chilling classic about surveillance and freedom."),
    ("To Kill a Mockingbird", "Harper Lee", 0, 399, 30, "Harper Perennial", 1960, 336, 4.8,
     "Through the eyes of young Scout Finch, a small Alabama town is tested when her father defends a Black man accused of a crime he did not commit."),
    ("The Great Gatsby", "F. Scott Fitzgerald", 0, 249, 4, "Scribner", 1925, 208, 4.4,
     "Jay Gatsby throws dazzling parties on Long Island in pursuit of a lost love, in a sharp portrait of the Jazz Age and the American dream."),
    ("Jane Eyre", "Charlotte Bronte", 0, 299, 25, "Penguin Classics", 1847, 624, 4.5,
     "An orphaned governess with an unbreakable spirit discovers dark secrets at Thornfield Hall and must choose between love and self-respect."),

    ("The Alchemist", "Paulo Coelho", 1, 350, 60, "HarperOne", 1988, 208, 4.6,
     "A shepherd boy leaves Andalusia to search for treasure near the Egyptian pyramids and learns to listen to his heart along the way."),
    ("The Kite Runner", "Khaled Hosseini", 1, 450, 35, "Bloomsbury", 2003, 372, 4.7,
     "A story of friendship, betrayal and redemption that moves from the kite-flying streets of Kabul to a new life in California."),
    ("The Midnight Library", "Matt Haig", 1, 499, 3, "Canongate", 2020, 304, 4.3,
     "Between life and death lies a library where every book lets Nora live a different version of her life. Which one is worth choosing?"),
    ("Life of Pi", "Yann Martel", 1, 399, 22, "Canongate", 2001, 352, 4.2,
     "After a shipwreck, a teenage boy shares a lifeboat with a Bengal tiger for 227 days in this tale of survival, faith and storytelling."),
    ("The Book Thief", "Markus Zusak", 1, 425, 28, "Picador", 2005, 592, 4.7,
     "Narrated by Death, the story of Liesel, a girl in Nazi Germany who steals books and shares them with those around her."),

    ("The Hobbit", "J.R.R. Tolkien", 2, 499, 45, "HarperCollins", 1937, 310, 4.8,
     "Bilbo Baggins is swept out of his comfortable hole and into a quest for dragon-guarded treasure with a band of dwarves and a wizard."),
    ("Dune", "Frank Herbert", 2, 599, 38, "Ace Books", 1965, 688, 4.7,
     "On the desert planet Arrakis, young Paul Atreides is drawn into a struggle for the most valuable substance in the universe."),
    ("The Name of the Wind", "Patrick Rothfuss", 2, 650, 18, "DAW Books", 2007, 662, 4.6,
     "Kvothe, a legendary magician and musician, tells the true story of his childhood, his years at the University and the making of a myth."),
    ("Project Hail Mary", "Andy Weir", 2, 599, 26, "Ballantine", 2021, 496, 4.8,
     "A lone astronaut wakes up with no memory on a mission to save Earth, and finds an unexpected ally light-years from home."),
    ("The Martian", "Andy Weir", 2, 450, 2, "Crown", 2011, 384, 4.7,
     "Stranded on Mars after a dust storm, botanist Mark Watney must science his way to survival with humour and duct tape."),

    ("The Girl with the Dragon Tattoo", "Stieg Larsson", 3, 499, 20, "Quercus", 2005, 672, 4.4,
     "A disgraced journalist and a brilliant hacker investigate a forty-year-old disappearance inside a powerful Swedish family."),
    ("Gone Girl", "Gillian Flynn", 3, 450, 24, "Crown", 2012, 432, 4.3,
     "On their fifth anniversary Amy Dunne vanishes, and her husband becomes the prime suspect in a twisting portrait of a marriage."),
    ("The Silent Patient", "Alex Michaelides", 3, 399, 33, "Celadon", 2019, 336, 4.4,
     "A famous painter shoots her husband and never speaks again. A psychotherapist becomes obsessed with uncovering her motive."),
    ("The Da Vinci Code", "Dan Brown", 3, 425, 40, "Doubleday", 2003, 489, 4.1,
     "Symbologist Robert Langdon follows a trail of codes hidden in the works of Leonardo da Vinci after a murder in the Louvre."),
    ("And Then There Were None", "Agatha Christie", 3, 299, 5, "HarperCollins", 1939, 272, 4.6,
     "Ten strangers are lured to an island and begin dying one by one, exactly as an old nursery rhyme predicts."),

    ("Clean Code", "Robert C. Martin", 4, 899, 30, "Prentice Hall", 2008, 464, 4.6,
     "A handbook of agile software craftsmanship: how to write readable functions, meaningful names and code that is easy to change."),
    ("Effective Java", "Joshua Bloch", 4, 1099, 25, "Addison-Wesley", 2018, 412, 4.8,
     "Ninety best-practice items for the Java platform, covering generics, lambdas, streams, concurrency and API design."),
    ("The Pragmatic Programmer", "David Thomas & Andrew Hunt", 4, 999, 20, "Addison-Wesley", 2019, 352, 4.7,
     "Practical advice on everything from personal responsibility and career growth to architecture, testing and automation."),
    ("Head First Java", "Kathy Sierra & Bert Bates", 4, 849, 35, "O'Reilly", 2022, 752, 4.5,
     "A visually rich, brain-friendly introduction to object-oriented programming and the Java language."),
    ("Oracle PL/SQL Programming", "Steven Feuerstein", 4, 1299, 12, "O'Reilly", 2014, 1340, 4.6,
     "The definitive guide to PL/SQL: blocks, cursors, packages, triggers, collections, exceptions and performance tuning."),
    ("Introduction to Algorithms", "Cormen, Leiserson, Rivest & Stein", 4, 1499, 15, "MIT Press", 2022, 1312, 4.7,
     "The classic computer-science text on algorithm design and analysis, from sorting and graphs to dynamic programming."),

    ("A Brief History of Time", "Stephen Hawking", 5, 399, 42, "Bantam", 1988, 256, 4.6,
     "From the Big Bang to black holes, Hawking explains the nature of space and time for readers with no scientific background."),
    ("Sapiens", "Yuval Noah Harari", 5, 499, 50, "Harper", 2015, 464, 4.6,
     "How did an insignificant ape come to rule the planet? A sweeping history of humankind from the Stone Age to today."),
    ("Cosmos", "Carl Sagan", 5, 450, 18, "Ballantine", 1980, 432, 4.7,
     "A lyrical tour of the universe and of the scientific journey that has helped humans understand their place within it."),
    ("The Selfish Gene", "Richard Dawkins", 5, 425, 4, "Oxford University Press", 1976, 360, 4.4,
     "A gene-centred view of evolution that changed how we think about altruism, behaviour and natural selection."),

    ("Atomic Habits", "James Clear", 6, 499, 65, "Avery", 2018, 320, 4.8,
     "Tiny changes, remarkable results: a practical framework for building good habits and breaking bad ones."),
    ("Rich Dad Poor Dad", "Robert Kiyosaki", 6, 350, 48, "Plata Publishing", 1997, 336, 4.3,
     "Two father figures, two attitudes towards money. Lessons on assets, liabilities and financial independence."),
    ("Deep Work", "Cal Newport", 6, 450, 27, "Grand Central", 2016, 304, 4.5,
     "Rules for focused success in a distracted world, and why the ability to concentrate is becoming a superpower."),
    ("The Psychology of Money", "Morgan Housel", 6, 399, 1, "Harriman House", 2020, 256, 4.7,
     "Nineteen short stories about how people think about money, risk and greed, and why behaviour matters more than knowledge."),
]


def sql(s):
    return "'" + s.replace("'", "''") + "'"


def cover_svg(idx, title, author, cat):
    top, bottom, accent = CATEGORIES[cat][3]
    e = html.escape
    lines = textwrap.wrap(title.upper(), 13 if len(title) > 22 else 12)[:4]
    size = 30 if max(len(l) for l in lines) <= 10 else 25
    start = 150 - (len(lines) - 1) * size * 0.6
    tspans = "".join(
        f'<tspan x="150" y="{start + i * size * 1.2:.0f}">{e(l)}</tspan>' for i, l in enumerate(lines))
    motif = [
        # each category gets its own decorative motif
        f'<circle cx="150" cy="300" r="70" fill="none" stroke="{accent}" stroke-opacity=".35" stroke-width="2"/>'
        f'<circle cx="150" cy="300" r="48" fill="none" stroke="{accent}" stroke-opacity=".25" stroke-width="2"/>',
        f'<path d="M30 330 Q150 250 270 330" fill="none" stroke="{accent}" stroke-opacity=".4" stroke-width="2"/>'
        f'<path d="M30 350 Q150 270 270 350" fill="none" stroke="{accent}" stroke-opacity=".25" stroke-width="2"/>',
        "".join(f'<circle cx="{(i * 53) % 280 + 10}" cy="{(i * 37) % 120 + 250}" r="{1 + i % 3}" fill="{accent}" fill-opacity=".7"/>' for i in range(24)),
        f'<path d="M0 360 L120 260 L300 330 L300 420 L0 420Z" fill="{accent}" fill-opacity=".12"/>'
        f'<line x1="40" y1="250" x2="260" y2="250" stroke="{accent}" stroke-width="3"/>',
        "".join(f'<rect x="{30 + i * 34}" y="{280 + (i % 3) * 18}" width="20" height="6" rx="3" fill="{accent}" fill-opacity=".5"/>' for i in range(7)),
        f'<ellipse cx="150" cy="310" rx="110" ry="30" fill="none" stroke="{accent}" stroke-opacity=".45" stroke-width="2"/>'
        f'<circle cx="150" cy="310" r="18" fill="{accent}" fill-opacity=".8"/>',
        f'<polyline points="40,350 90,320 130,335 180,285 220,300 260,250" fill="none" stroke="{accent}" stroke-width="3"/>',
    ][cat]
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 420" width="300" height="420">
<defs><linearGradient id="g" x1="0" y1="0" x2="0.6" y2="1"><stop offset="0" stop-color="{top}"/><stop offset="1" stop-color="{bottom}"/></linearGradient></defs>
<rect width="300" height="420" fill="url(#g)"/>
<rect x="0" y="0" width="14" height="420" fill="#000" fill-opacity=".25"/>
<rect x="18" y="18" width="264" height="384" fill="none" stroke="{accent}" stroke-opacity=".55" stroke-width="1.5"/>
<text x="150" y="58" text-anchor="middle" font-family="Georgia,serif" font-size="11" letter-spacing="4" fill="{accent}">{e(CATEGORIES[cat][0].upper())}</text>
{motif}
<text text-anchor="middle" font-family="Georgia,'Times New Roman',serif" font-weight="bold" font-size="{size}" fill="#ffffff">{tspans}</text>
<line x1="110" y1="{start + len(lines) * size * 1.2 - size * 0.4:.0f}" x2="190" y2="{start + len(lines) * size * 1.2 - size * 0.4:.0f}" stroke="{accent}" stroke-width="2"/>
<text x="150" y="385" text-anchor="middle" font-family="Helvetica,Arial,sans-serif" font-size="13" letter-spacing="1.5" fill="#ffffff" fill-opacity=".9">{e(author.upper()[:34])}</text>
<text x="268" y="34" text-anchor="end" font-family="Georgia,serif" font-size="10" fill="{accent}" fill-opacity=".8">SW</text>
</svg>'''


def main():
    os.makedirs(COVERS, exist_ok=True)
    out = ["-- =====================================================================",
           "--  ScriptWell : 05_seed.sql  (generated by scripts/generate_seed.py)",
           "-- =====================================================================", ""]
    for name, desc, icon, _ in CATEGORIES:
        out.append(f"INSERT INTO categories (name, description, icon) VALUES ({sql(name)}, {sql(desc)}, {sql(icon)});")
    out.append("")
    for i, (title, author, cat, price, stock, pub, year, pages, rating, desc) in enumerate(BOOKS, 1):
        cover = f"book-{i:02d}.svg"
        isbn = f"978-81-{9000 + i * 7:04d}-{(i * 13) % 100:02d}-{i % 10}"
        out.append(
            "INSERT INTO books (title, author, isbn, category_id, price, stock, description, cover_image, "
            "publisher, pub_year, pages, rating) VALUES "
            f"({sql(title)}, {sql(author)}, {sql(isbn)}, "
            f"(SELECT category_id FROM categories WHERE name = {sql(CATEGORIES[cat][0])}), "
            f"{price}, {stock}, {sql(desc)}, {sql(cover)}, {sql(pub)}, {year}, {pages}, {rating});")
        with open(os.path.join(COVERS, cover), "w", encoding="utf-8") as f:
            f.write(cover_svg(i, title, author, cat))
    with open(os.path.join(COVERS, "default.svg"), "w", encoding="utf-8") as f:
        f.write(cover_svg(0, "ScriptWell Edition", "ScriptWell Books", 1))

    out.append("""
COMMIT;

-- Demo accounts (passwords are hashed by PKG_USER)
--   admin@scriptwell.com / admin123      demo@scriptwell.com / demo123
DECLARE
  v_admin NUMBER; v_demo NUMBER; v_riya NUMBER;
  v_order NUMBER; v_ref VARCHAR2(40);
BEGIN
  pkg_user.register_user('ScriptWell Admin', 'admin@scriptwell.com', 'admin123', '9876500000',
                         'ScriptWell HQ, Connaught Place, New Delhi 110001', v_admin);
  UPDATE users SET role = 'ADMIN' WHERE user_id = v_admin;

  pkg_user.register_user('Aarav Sharma', 'demo@scriptwell.com', 'demo123', '9876543210',
                         '221B MG Road, Sector 14, Gurugram, Haryana 122001', v_demo);
  pkg_user.register_user('Riya Mehta', 'riya@example.com', 'riya123', '9812345678',
                         '12 Park Street, Kolkata, West Bengal 700016', v_riya);
  COMMIT;

  -- A few historical orders so the dashboard has data to show
  pkg_cart.add_item(v_demo, 31, 1);
  pkg_cart.add_item(v_demo, 22, 1);
  pkg_order.place_order(v_demo, '221B MG Road, Sector 14, Gurugram, Haryana 122001', 'CARD', v_order, v_ref);
  UPDATE orders SET order_date = SYSDATE - 12 WHERE order_id = v_order;
  pkg_order.update_status(v_order, 'DELIVERED');

  pkg_cart.add_item(v_riya, 12, 1);
  pkg_cart.add_item(v_riya, 11, 2);
  pkg_cart.add_item(v_riya, 28, 1);
  pkg_order.place_order(v_riya, '12 Park Street, Kolkata, West Bengal 700016', 'UPI', v_order, v_ref);
  UPDATE orders SET order_date = SYSDATE - 6 WHERE order_id = v_order;
  pkg_order.update_status(v_order, 'SHIPPED');

  pkg_order.buy_now(v_demo, 2, 1, '221B MG Road, Sector 14, Gurugram, Haryana 122001', 'COD', v_order, v_ref);
  UPDATE orders SET order_date = SYSDATE - 2 WHERE order_id = v_order;

  pkg_cart.add_item(v_riya, 18, 1);
  pkg_cart.add_item(v_riya, 6, 1);
  pkg_order.place_order(v_riya, '12 Park Street, Kolkata, West Bengal 700016', 'CARD', v_order, v_ref);
  COMMIT;
END;
/
""")
    with open(SEED, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out))
    print(f"{len(BOOKS)} books, {len(CATEGORIES)} categories -> {SEED}")


if __name__ == "__main__":
    main()
