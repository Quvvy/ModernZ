// Jimaku subtitle fetcher for mpv (ModernZ extra)
// Adapted from https://github.com/ZXY101/mpv-jimaku (GPL-3.0)

var options = {
    api_key: '',
    auto_fetch: true,
    language_preference: 'ja',
    cache_dir: '~~/mpv_subs',
    api_base_url: 'https://jimaku.cc',
    max_entry_results: 10,
    auto_fetch_delay_ms: 800,
};

mp.options.read_options(options, 'jimaku-subs');

var ARCHIVE_EXT = /\.(zip|7z|rar)$/i;
var SUB_EXT = /\.(ass|ssa|srt|vtt)$/i;
var lastAutoPath = null;
var fetchInProgress = false;

function homeDir() {
    return mp.utils.getenv('USERPROFILE') || mp.utils.getenv('HOME') || '';
}

function expandPath(path) {
    if (!path) return path;
    if (path.indexOf('~~') === 0) {
        return mp.utils.join_path(homeDir(), path.replace(/^~~\/?/, ''));
    }
    return path;
}

function apiKeyConfigured() {
    return options.api_key && options.api_key !== 'YOUR_KEY_HERE';
}

function api(url, extraArgs) {
    if (!apiKeyConfigured()) {
        showMessage('Jimaku: API key not set in jimaku-subs.conf');
        return null;
    }

    var baseArgs = [
        'curl', '-s', '--url', url,
        '--header', 'Authorization: ' + options.api_key,
    ];
    var args = baseArgs.concat(extraArgs || []);

    var res = mp.command_native({
        name: 'subprocess',
        playback_only: false,
        capture_stdout: true,
        capture_stderr: true,
        args: args,
    });

    if (!res || res.status !== 0) {
        showMessage('Jimaku: request failed');
        return null;
    }

    if (!res.stdout) return null;

    try {
        return JSON.parse(res.stdout);
    } catch (e) {
        showMessage('Jimaku: invalid API response');
        return null;
    }
}

function curlDownload(url, destPath) {
    if (!apiKeyConfigured()) return false;

    var dir = destPath.replace(/[\\/][^\\/]+$/, '');
    ensureDir(dir);

    var res = mp.command_native({
        name: 'subprocess',
        playback_only: false,
        capture_stdout: true,
        capture_stderr: true,
        args: [
            'curl', '-s', '-L', '--url', url,
            '--header', 'Authorization: ' + options.api_key,
            '--output', destPath,
        ],
    });

    return res && res.status === 0 && mp.utils.file_info(destPath);
}

function showMessage(message, persist) {
    var ass_start = mp.get_property_osd('osd-ass-cc/0') || '';
    var ass_stop = mp.get_property_osd('osd-ass-cc/1') || '';
    mp.osd_message(ass_start + '{\\fs16}' + message + ass_stop, persist ? 999 : 2);
}

function inputGet(args) {
    mp.input.terminate();
    setTimeout(function () { mp.input.get(args); }, 1);
}

function inputSelect(args) {
    mp.input.terminate();
    setTimeout(function () { mp.input.select(args); }, 1);
}

function sanitize(text) {
    var subPatterns = [
        /\.[a-zA-Z0-9]+$/,
        /\./g, /-/g, /_/g,
        /\[[^\]]+\]/g,
        /\([^\)]+\)/g,
        /720[pP]/g, /480[pP]/g, /1080[pP]/g,
        /[xX]26[45]/g,
        /[bB]lu[-]?[rR]ay/g,
        /^[\s]*/, /[\s]*$/,
        /1920[xX]1080/g,
        /Hi10P/g, /FLAC/g, /AAC/g,
    ];

    var result = text;
    subPatterns.forEach(function (pattern) {
        var next = result.replace(pattern, ' ');
        if (next.length > 0) result = next;
    });
    return result.replace(/\s+/g, ' ').trim();
}

function extractTitle(text) {
    var matchers = [
        { regex: /^(.+?)[\s-]+[Ss]\d+[Ee]?\d+/, group: 1 },
        { regex: /^(.+?)[\s-]+[Ee](?:pisode\s*)?\d+/, group: 1 },
        { regex: /^(.+?)[\s-]+\d{1,3}(?:\s|$)/, group: 1 },
        { regex: /^([\w\s\d]+)[Ss]\d+[Ee]?\d+/, group: 1 },
        { regex: /^([\w\s\d]+)-[\s]*\d+[\s]*[^\w]*$/, group: 1 },
        { regex: /^([\w\s\d]+)[Ee]?[Pp]?[\s]+\d+$/, group: 1 },
        { regex: /^([\w\s\d]+)[\s]\d+.*$/, group: 1 },
        { regex: /^\d+[\s]*(.+)$/, group: 1 },
    ];

    for (var i = 0; i < matchers.length; i++) {
        var m = matchers[i];
        var match = text.match(m.regex);
        if (match) return match[m.group].trim();
    }
    return text.trim();
}

function extractEpisode(text) {
    var matchers = [
        /[Ss]\d+[Ee](\d{1,3})/,
        /[Ee](?:pisode\s*)?(\d{1,3})/,
        /(?:^|[\s-])(\d{1,3})(?:\s|$|[^\d])/,
    ];

    for (var i = 0; i < matchers.length; i++) {
        var match = text.match(matchers[i]);
        if (match) return match[1];
    }
    return null;
}

function getMediaContext() {
    var mediaTitle = mp.get_property('media-title') || '';
    var forceTitle = mp.get_property('force-media-title') || '';
    var filename = mp.get_property('filename') || '';
    var path = mp.get_property('path') || '';

    var source = mediaTitle || forceTitle || filename;
    var sanitized = sanitize(source);
    var title = extractTitle(sanitized);
    var episode = extractEpisode(sanitized) || extractEpisode(filename);

    return {
        source: source,
        title: title,
        episode: episode,
        path: path,
    };
}

function getNames(items) {
    return items.map(function (item) { return item.name; });
}

function scoreSubtitleFile(file) {
    var name = (file.name || '').toLowerCase();
    var score = 0;

    if (SUB_EXT.test(name)) score += 10;
    if (ARCHIVE_EXT.test(name)) score -= 50;

    if (options.language_preference) {
        var lang = options.language_preference.toLowerCase();
        if (name.indexOf(lang) >= 0) score += 20;
        if (lang === 'ja' && (name.indexOf('jpn') >= 0 || name.indexOf('japanese') >= 0)) score += 15;
    }

    if (/\.ass$/i.test(name)) score += 5;
    if (/web/i.test(name)) score += 2;

    return score;
}

function pickBestSubtitle(files) {
    var candidates = files.filter(function (f) {
        return f && f.name && !ARCHIVE_EXT.test(f.name);
    });

    if (candidates.length === 0) return null;

    candidates.sort(function (a, b) {
        return scoreSubtitleFile(b) - scoreSubtitleFile(a);
    });

    return candidates[0];
}

function ensureDir(path) {
    mp.command_native(['mkdir', path]);
}

function cacheDestination(ctx, subName) {
    var base = expandPath(options.cache_dir);
    var showDir = sanitize(ctx.title).replace(/[<>:"/\\|?*]/g, '_') || 'unknown';
    var epPart = ctx.episode ? ('ep' + ctx.episode) : 'unknown-episode';
    var destDir = mp.utils.join_path(base, showDir, epPart);
    ensureDir(destDir);
    return mp.utils.join_path(destDir, subName);
}

function downloadSub(sub, destPath) {
    return curlDownload(sub.url, destPath) ? destPath : null;
}

function loadSubtitleFile(filePath) {
    mp.commandv('sub-add', filePath, 'select');
    showMessage('Jimaku: loaded ' + filePath.split(/[\\/]/).pop());
}

function selectSub(selectedSub, ctx, interactive) {
    if (!selectedSub || !selectedSub.url) {
        showMessage('Jimaku: invalid subtitle entry');
        return;
    }

    var destPath = cacheDestination(ctx, selectedSub.name);
    showMessage('Jimaku: downloading ' + selectedSub.name);

    var saved = downloadSub(selectedSub, destPath);
    if (!saved) {
        showMessage('Jimaku: download failed');
        return;
    }

    loadSubtitleFile(saved);
}

function selectEpisode(anime, episode, ctx, interactive) {
    var url = options.api_base_url + '/api/entries/' + anime.id + '/files';
    if (episode) url += '?episode=' + encodeURIComponent(episode);

    showMessage('Jimaku: fetching subs for ' + anime.name);
    var episodeResults = api(url);

    if (!episodeResults) return;
    if (episodeResults.error) {
        showMessage('Jimaku: ' + episodeResults.error);
        return;
    }
    if (episodeResults.length === 0) {
        showMessage('Jimaku: no subtitle files found');
        return;
    }

    if (episodeResults.length === 1) {
        selectSub(episodeResults[0], ctx, interactive);
        return;
    }

    if (!interactive) {
        var best = pickBestSubtitle(episodeResults);
        if (best) {
            selectSub(best, ctx, false);
            return;
        }
    }

    inputSelect({
        prompt: 'Select subtitle file: ',
        items: getNames(episodeResults),
        submit: function (id) {
            selectSub(episodeResults[id - 1], ctx, true);
        },
    });
}

function onAnimeSelected(anime, ctx, interactive, episodeOverride) {
    var episode = episodeOverride !== undefined ? episodeOverride : ctx.episode;

    if (interactive || !episode) {
        inputGet({
            prompt: 'Episode (leave blank for all): ',
            default_text: episode || '',
            submit: function (value) {
                selectEpisode(anime, value || null, ctx, true);
            },
        });
        return;
    }

    selectEpisode(anime, episode, ctx, false);
}

function searchEntries(searchTerm, ctx, interactive) {
    mp.input.terminate();
    showMessage('Jimaku: searching "' + searchTerm + '"');

    var url = encodeURI(
        options.api_base_url + '/api/entries/search?anime=true&query=' + searchTerm
    );
    var animeResults = api(url);

    if (!animeResults) return;
    if (animeResults.error) {
        showMessage('Jimaku: ' + animeResults.error);
        return;
    }
    if (animeResults.length === 0) {
        showMessage('Jimaku: no results found');
        if (interactive) return;
        showMessage('Jimaku: press Ctrl+Shift+J to search manually');
        return;
    }

    if (animeResults.length === 1) {
        onAnimeSelected(animeResults[0], ctx, interactive, ctx.episode);
        return;
    }

    if (!interactive) {
        onAnimeSelected(animeResults[0], ctx, false, ctx.episode);
        return;
    }

    var items = getNames(animeResults);
    inputSelect({
        prompt: 'Select anime: ',
        items: items,
        submit: function (id) {
            onAnimeSelected(animeResults[id - 1], ctx, true, ctx.episode);
        },
    });
}

function manualReselect() {
    var ctx = getMediaContext();
    mp.set_property('pause', 'yes');
    inputGet({
        prompt: 'Search term: ',
        default_text: ctx.title,
        submit: function (term) {
            if (!term) term = ctx.title;
            searchEntries(term, ctx, true);
        },
    });
    showMessage('Jimaku: manual search (Ctrl+Shift+J)', true);
}

function autoFetchFromMedia() {
    if (!options.auto_fetch || !apiKeyConfigured()) return;
    if (fetchInProgress) return;

    var ctx = getMediaContext();
    if (!ctx.title) {
        showMessage('Jimaku: could not parse title; use Ctrl+Shift+J');
        return;
    }

    var pathKey = ctx.path + '|' + ctx.title + '|' + (ctx.episode || '');
    if (lastAutoPath === pathKey) return;

    fetchInProgress = true;
    lastAutoPath = pathKey;

    try {
        searchEntries(ctx.title, ctx, false);
    } finally {
        fetchInProgress = false;
    }
}

mp.add_key_binding('Ctrl+Shift+j', 'reselect', manualReselect);

mp.register_event('file-loaded', function () {
    if (!options.auto_fetch || !apiKeyConfigured()) return;

    var delay = Math.max(0, options.auto_fetch_delay_ms || 0);
    setTimeout(function () {
        autoFetchFromMedia();
    }, delay);
});
