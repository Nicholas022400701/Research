set -u
R=$PWD
W=$R/w
mkdir -p "$W" && cd "$W"
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -salt -pass env:RKEY -in "$R/jobs/$JOB.enc" | tar xz
V="https://x-access-token:$VT@github.com/Nicholas022400701/Vault.git"
B="r-$JOB-$S"
git clone -q --depth 1 -b "$B" "$V" vault 2>/dev/null || { git clone -q --depth 1 "$V" vault && cd vault && git checkout -q --orphan "$B" && git rm -rfq . >/dev/null 2>&1; cd "$W"; }
mkdir -p state out
[ -d vault/state ] && cp -r vault/state/. state/
if [ -f requirements.txt ]; then pip install -q -r requirements.txt >> log.txt 2>&1; fi
export SHARD="$S" NSHARDS="$N" HOP="$HOP" STATE="$W/state" OUT="$W/out" BUDGET_MIN="$BUDGET"
rm -f CONTINUE
timeout "$((BUDGET*60))" python main.py >> log.txt 2>&1
echo "exit=$?" >> log.txt
mkdir -p vault/out vault/state
cp -r out/. vault/out/ 2>/dev/null
rm -rf vault/state && cp -r state vault/state
cp log.txt "vault/log-$HOP.txt"
if [ -f CONTINUE ]; then touch vault/CONTINUE; echo 1 > "$R/c.txt"; else rm -f vault/CONTINUE; fi
cd vault && git config user.email r@r.r && git config user.name r && git add -A && git commit -qm "$JOB $S $HOP" || true
for i in 1 2 3 4 5; do git push -q "$V" "HEAD:$B" && break || sleep $((RANDOM % 20 + 5)); done
cd "$W" && tar cz out log.txt state 2>/dev/null | openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt -pass env:RKEY -out "$R/out.enc"
