import sqlite3

from pyglossary.glossary_v2 import Glossary

MDX_PATH = "/Users/vxoxvx/Misc/Dictionary/Longman/LDOCE5++ V 1-35.mdx"
DB_PATH = "/Users/vxoxvx/Misc/Dictionary/Longman/ldoce5.db"

if __name__ == "__main__":
    Glossary.init()
    glos = Glossary()
    glos.directRead(MDX_PATH, formatName="OctopusMdict")
    
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    
    # term -> definition
    cur.execute("""
        CREATE TABLE IF NOT EXISTS entry (
            id INTEGER PRIMARY KEY,
            headword TEXT NOT NULL,
            defi TEXT NOT NULL
        )
    """)
    
    # term_alias -> term_id
    cur.execute("""
        CREATE TABLE IF NOT EXISTS term (
            term TEXT NOT NULL,
            entry_id INTEGER NOT NULL
        )
    """)
    
    for i, entry in enumerate(glos):
        cur.execute(
            "INSERT INTO entry (headword, defi) VALUES (?, ?)",
            (entry.l_term[0], entry.defi),
        )
        entry_id = cur.lastrowid
        cur.executemany(
            "INSERT INTO term (term, entry_id) VALUES (?, ?)",
            [(t.lower(), entry_id) for t in entry.l_term], 
        )
    
    cur.execute("CREATE INDEX IF NOT EXISTS idx_term ON term(term)")
    con.commit()
    con.close()
    glos.cleanup()
    print("success")
