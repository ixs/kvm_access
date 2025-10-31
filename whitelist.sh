#!/bin/bash

# Add whitelist entries for hosts in the $HOST_WHITELIST environment variable
set -euo pipefail

PROFILE_DIR="$HOME/.moonchild productions/pale moon/default/"

if [ -z "${HOST_WHITELIST:-}" ]; then
    echo "No hosts to whitelist. Nothing to do."
    exit
else
    IFS=' ' read -ra HOST_ARRAY <<< "$HOST_WHITELIST"
fi


echo "Initializing Mozilla permission database"
sqlite3 "${PROFILE_DIR}/permissions.sqlite" << EOF
PRAGMA foreign_keys = OFF;
PRAGMA user_version = 12;
PRAGMA page_size = 32768;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS moz_perms ( id INTEGER PRIMARY KEY,origin TEXT,type TEXT,permission INTEGER,expireType INTEGER,expireTime INTEGER,modificationTime INTEGER);
CREATE TABLE IF NOT EXISTS moz_hosts ( id INTEGER PRIMARY KEY,host TEXT,type TEXT,permission INTEGER,expireType INTEGER,expireTime INTEGER,modificationTime INTEGER,appId INTEGER,isInBrowserElement INTEGER);
COMMIT;
EOF

echo "Initializing Java Site Exception list"
mkdir -p "${HOME}/.java/deployment/security/"

echo "Initializing Mozilla Cert override"
firefox-cert-override | head -n 2 > "${PROFILE_DIR}/cert_override.txt"

for host in "${HOST_ARRAY[@]}"; do
    echo "Whitelisting $host for FlashPlayer"
      sqlite3 "${PROFILE_DIR}/permissions.sqlite" << EOF
          INSERT INTO moz_perms (origin, type, permission, expireType, expireTime, modificationTime)
          VALUES ('http://${host}', 'plugin:flash', 1, 2, 0, strftime('%s','now') * 1000);
          VALUES ('http://${host}', 'plugin:java', 1, 2, 0, strftime('%s','now') * 1000);
          INSERT INTO moz_perms (origin, type, permission, expireType, expireTime, modificationTime)
          VALUES ('https://${host}', 'plugin:flash', 1, 2, 0, strftime('%s','now') * 1000);
          VALUES ('https://${host}', 'plugin:java', 1, 2, 0, strftime('%s','now') * 1000);
          VACUUM;
EOF

    echo "Adding $host to Java Site Exception list"
    echo "http://${host}" >> "${HOME}/.java/deployment/security/exception.sites"
    echo "https://${host}" >> "${HOME}/.java/deployment/security/exception.sites"

    echo "Adding $host to Mozilla certificate override list"
    CERT_FILE=/tmp/cert.pem
    curl \
        --insecure \
        --connect-timeout 5 \
        --compressed \
        -o /dev/null \
        -s \
        -w "%{certs}\n" \
        "https://${host}" | \
        openssl x509 -outform pem -out "$CERT_FILE" || continue
    firefox-cert-override "${host}:443=${CERT_FILE}[MUT]" | grep -E '^[^#]' | grep -vE '^$' >> "${PROFILE_DIR}/cert_override.txt"
done



# Prep homepage

cat << EOF > /tmp/homepage.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>kvm_acccess Start Page</title>
<style>
    :root {
        --bg: #0f172a;
        --card-bg: #1e293b;
        --text: #f1f5f9;
        --accent: #38bdf8;
        --accent-hover: #0ea5e9;
        --link-bg: #334155;
        --font: 'Inter', 'Segoe UI', sans-serif;
    }

    * {
        box-sizing: border-box;
        margin: 0;
        padding: 0;
    }

    body {
        background: var(--bg);
        color: var(--text);
        font-family: var(--font);
        display: flex;
        justify-content: center;
        align-items: flex-start;
        min-height: 100vh;
        padding: 40px 20px;
    }

    main {
        width: 100%;
        max-width: 800px;
    }

    header {
        text-align: center;
        margin-bottom: 40px;
    }

    header h1 {
        font-size: 2rem;
        font-weight: 600;
        margin-bottom: 10px;
    }

    header p {
        color: #94a3b8;
        font-size: 1rem;
    }

    .links {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
        gap: 20px;
    }

    .card {
        background: var(--card-bg);
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }

    .card:hover {
        transform: translateY(-4px);
        box-shadow: 0 6px 16px rgba(0,0,0,0.4);
    }

    .hostname {
        font-size: 1.2rem;
        font-weight: 600;
        margin-bottom: 12px;
    }

    .link-group {
        display: flex;
        gap: 10px;
    }

    a.link {
        flex: 1;
        text-align: center;
        text-decoration: none;
        color: var(--text);
        background: var(--link-bg);
        padding: 10px 0;
        border-radius: 6px;
        transition: background 0.2s ease;
        font-weight: 500;
    }

    a.link.http { border: 1px solid #ef4444; }
    a.link.https { border: 1px solid var(--accent); }

    a.link:hover {
        background: var(--accent-hover);
    }

    footer {
        margin-top: 40px;
        text-align: center;
        color: #64748b;
        font-size: 0.9rem;
    }
</style>
</head>
<body>
<main>
    <header>
        <h1>kvm_access Start Page</h1>
        <p>Quick access to whitelisted Baseboard Management Controllers</p>
    </header>

    <section class="links">
EOF

for host in "${HOST_ARRAY[@]}"; do
    title=$(curl -k --connect-timeout 5 -s --compressed https://${host} | xmllint --html --xpath "/html/head/title/text()" - || echo "")
    cat << EOF >> /tmp/homepage.html
        <div class="card">
            <div class="hostname">${host} | ${title}</div>
            <div class="link-group">
                <a href="http://${host}" class="link http">HTTP</a>
                <a href="https://${host}" class="link https">HTTPS</a>
            </div>
        </div>
EOF
done

cat << EOF >> /tmp/homepage.html
    </section>

    <footer>
        Generated on $(date) by $(readlink -f $0)
    </footer>
</main>
</body>
</html>
EOF
