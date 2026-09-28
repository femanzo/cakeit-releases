"""Generate installer metadata from the release's verified checksum manifest."""
import json, os, pathlib, re

root = pathlib.Path(__file__).parent
tag = os.environ['RELEASE_TAG']
if not re.fullmatch(r'v[\w.-]{1,63}', tag):
    raise ValueError('Invalid release tag')
release = json.loads((root / 'release.json').read_text(encoding='utf-8-sig'))
if release['draft'] or release['prerelease'] or release['tag_name'] != tag:
    raise ValueError('Use a published stable release')
entries = {}
for line in (root / 'SHA256SUMS.txt').read_text(encoding='utf-8-sig').splitlines():
    match = re.fullmatch(r'([a-fA-F0-9]{64})\s+\*?([A-Za-z0-9._-]+)', line)
    if not match or match[2] in entries:
        raise ValueError('Invalid checksum manifest')
    entries[match[2]] = match[1].lower()
bases = [name for name in entries if name.endswith('.zip') and name+'.001' in entries]
if len(bases) != 1:
    raise ValueError('Expected one split game archive')
base = bases[0]
parts = sorted(n for n in entries if n.startswith(base+'.'))
if parts != [f'{base}.{i:03}' for i in range(1, len(parts)+1)]:
    raise ValueError('Missing archive part')
assets = {a['name']: a for a in release['assets']}
prefix = f'https://github.com/femanzo/cakeit-releases/releases/download/{tag}/'
for name in parts:
    a = assets[name]
    if a['state'] != 'uploaded' or a['size'] <= 0 or a['digest'] != 'sha256:'+entries[name] or a['browser_download_url'] != prefix+name:
        raise ValueError('Incomplete or altered package')
downloads = ' '.join(f"DownloadPage.Add('{prefix+n}', '{n}', '{entries[n]}');" for n in parts)
join = '/D /C copy /B ' + '+'.join('"{tmp}\\'+n+'"' for n in parts) + ' "{tmp}\\'+base+'" >nul'
values = {'ReleaseTag': tag, 'PackageName': base, 'PackageSHA': entries[base], 'Downloads': downloads, 'JoinCommand': join}
# ISPP permits a double-quoted literal with doubled embedded double quotes.
(root / 'package.iss').write_text('\n'.join('#define '+key+' "'+value.replace('"','""')+'"' for key,value in values.items())+'\n',encoding='utf-8')
print(f'Installer configured: {tag}, {len(parts)} payload parts, verified SHA256 metadata')
