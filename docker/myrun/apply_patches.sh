#!/bin/bash
set -e

# Apply all patches except fix_install_A0.patch and agent_retry.patch to the agent-zero repository
for p in /patches/*.patch; do
    case "$p" in
        */fix_install_A0.patch) continue ;;
        */agent_retry.patch) continue ;;
    esac
    echo "Applying patch: $p"
    patch -d /git/agent-zero -p1 < "$p"
done

# Apply agent_retry changes manually since the patch format doesn't match
echo "Applying agent_retry changes manually..."
cd /git/agent-zero

# Add httpx import if not already present
if ! grep -q "import httpx" agent.py; then
    sed -i '1a import httpx' agent.py
fi

# Apply retry logic to call_utility_model method
python3 << 'EOF'
import re

with open('agent.py', 'r') as f:
    content = f.read()

# Pattern to find the call_utility_model streaming section
pattern1 = r'(async for chunk in \(prompt \| model\)\.astream\(\{\}\):\s*\n\s*await self\.handle_intervention\(\)[^\n]*\n\s*content = models\.parse_chunk\(chunk\)\s*\n\s*limiter\.add\(output=tokens\.approximate_tokens\(content\)\)\s*\n\s*response \+= content\s*\n\s*if callback:\s*\n\s*await callback\(content\))'

replacement1 = '''attempt = 0
        while True:
            try:
                async for chunk in (prompt | model).astream({}):
                    await self.handle_intervention()  # wait for intervention and handle it, if paused

                    content = models.parse_chunk(chunk)
                    limiter.add(output=tokens.approximate_tokens(content))
                    response += content

                    if callback:
                        await callback(content)
                break
            except httpx.HTTPError as exc:
                attempt += 1
                self.context.log.log(
                    type="warning",
                    heading="stream interrupted",
                    content=str(exc),
                )
                if attempt >= 3:
                    raise
                await asyncio.sleep(1)
                response = ""'''

# Apply first replacement
content = re.sub(pattern1, replacement1, content, flags=re.MULTILINE | re.DOTALL)

# Pattern to find the call_chat_model streaming section
pattern2 = r'(async for chunk in \(prompt \| model\)\.astream\(\{\}\):\s*\n\s*await self\.handle_intervention\(\)[^\n]*\n\s*content = models\.parse_chunk\(chunk\)\s*\n\s*limiter\.add\(output=tokens\.approximate_tokens\(content\)\)\s*\n\s*response \+= content\s*\n\s*if callback:\s*\n\s*await callback\(content, response\))'

replacement2 = '''attempt = 0
        while True:
            try:
                async for chunk in (prompt | model).astream({}):
                    await self.handle_intervention()  # wait for intervention and handle it, if paused

                    content = models.parse_chunk(chunk)
                    limiter.add(output=tokens.approximate_tokens(content))
                    response += content

                    if callback:
                        await callback(content, response)
                break
            except httpx.HTTPError as exc:
                attempt += 1
                self.context.log.log(
                    type="warning",
                    heading="stream interrupted",
                    content=str(exc),
                )
                if attempt >= 3:
                    raise
                await asyncio.sleep(1)
                response = ""'''

# Apply second replacement
content = re.sub(pattern2, replacement2, content, flags=re.MULTILINE | re.DOTALL)

with open('agent.py', 'w') as f:
    f.write(content)
EOF

echo "Agent retry changes applied successfully"
