package app.revanced.extension.gamehub;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.Gravity;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * BhGameConfigsActivity — community game config browser.
 *
 * Side menu ID=13. Three-screen flow managed via LinearLayout visibility:
 *   Screen 1: All games (search + list)
 *   Screen 2: Configs for selected game (vote count + date)
 *   Screen 3: Config detail (meta, vote, download, comments)
 *
 * Backend: bannerhub-configs-worker.the412banner.workers.dev
 *   GET  /games             — list all game folders
 *   GET  /list?game=X       — list configs for a game (includes votes)
 *   POST /vote              — upvote a config {sha, game, filename}
 *   GET  /comments?game=X&file=Y — fetch comments
 *   POST /comment           — add a comment {game, filename, text, device}
 */
public class BhGameConfigsActivity extends Activity {

    // ── Constants ────────────────────────────────────────────────────────────
    private static final String WORKER     = "https://bannerhub-configs-worker.the412banner.workers.dev";
    private static final String VOTES_SP   = "bh_config_votes";
    private static final String COVERS_SP  = "bh_steam_covers";
    private static final String EXPORT_DIR = "BannerHub/configs";
    // Steam store search (no API key required)
    private static final String STEAM_SEARCH = "https://store.steampowered.com/api/storesearch/?l=english&cc=us&term=";
    private static final String STEAM_HEADER = "https://cdn.akamai.steamstatic.com/steam/apps/%s/header.jpg";

    // ── Colors ───────────────────────────────────────────────────────────────
    private static final int BG       = 0xFF0D0D0D;
    private static final int SURFACE  = 0xFF1A1A1A;
    private static final int ACCENT   = 0xFF6C63FF;
    private static final int WHITE    = 0xFFFFFFFF;
    private static final int GREY     = 0xFFAAAAAA;
    private static final int DIVIDER  = 0xFF2A2A2A;

    // ── Views ────────────────────────────────────────────────────────────────
    private LinearLayout screenGames, screenConfigs, screenDetail;
    private TextView     headerTitle;
    private EditText     searchBox;
    private ListView     gamesListView, configsListView;

    // Screen 3 dynamic views
    private LinearLayout commentsContainer;
    private TextView     votesLabel;
    private Button       voteBtn;

    // ── State ────────────────────────────────────────────────────────────────
    private List<String>     allGames      = new ArrayList<>();
    private List<String>     filteredGames = new ArrayList<>();
    private List<JSONObject> currentConfigs = new ArrayList<>();
    private String     selectedGame;
    private JSONObject selectedConfig;
    private int        currentScreen = 1; // 1=games, 2=configs, 3=detail

    // Cover art: in-memory Bitmap cache (game folder name → Bitmap)
    private final Map<String, Bitmap> coverCache = new HashMap<>();

    private Handler ui = new Handler(Looper.getMainLooper());

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(BG);

        LinearLayout wrapper = new LinearLayout(this);
        wrapper.setOrientation(LinearLayout.VERTICAL);

        wrapper.addView(buildHeader());

        FrameLayout body = new FrameLayout(this);
        screenGames   = buildGamesScreen();
        screenConfigs = buildConfigsScreen();
        screenDetail  = buildDetailScreen();

        body.addView(screenGames,   matchParams());
        body.addView(screenConfigs, matchParams());
        body.addView(screenDetail,  matchParams());

        wrapper.addView(body, new LinearLayout.LayoutParams(-1, 0, 1f));
        root.addView(wrapper, matchParams());
        setContentView(root);

        showScreen(1);
        fetchGames();
    }

    @Override
    public void onBackPressed() {
        if (currentScreen == 3) showScreen(2);
        else if (currentScreen == 2) showScreen(1);
        else finish();
    }

    // ── Header ────────────────────────────────────────────────────────────────

    private LinearLayout buildHeader() {
        LinearLayout h = new LinearLayout(this);
        h.setOrientation(LinearLayout.HORIZONTAL);
        h.setBackgroundColor(SURFACE);
        h.setGravity(Gravity.CENTER_VERTICAL);
        h.setPadding(dp(12), dp(10), dp(12), dp(10));

        Button back = new Button(this);
        back.setText("←");
        back.setTextColor(WHITE);
        back.setBackgroundColor(0x00000000);
        back.setTextSize(18f);
        back.setPadding(0, 0, dp(8), 0);
        back.setOnClickListener(v -> onBackPressed());

        headerTitle = new TextView(this);
        headerTitle.setText("Game Configs");
        headerTitle.setTextColor(WHITE);
        headerTitle.setTextSize(18f);
        headerTitle.setTypeface(null, Typeface.BOLD);

        h.addView(back);
        h.addView(headerTitle);
        return h;
    }

    // ── Screen 1: Games ───────────────────────────────────────────────────────

    private LinearLayout buildGamesScreen() {
        LinearLayout s = new LinearLayout(this);
        s.setOrientation(LinearLayout.VERTICAL);
        s.setBackgroundColor(BG);

        // Search bar
        searchBox = new EditText(this);
        searchBox.setHint("Search games...");
        searchBox.setHintTextColor(GREY);
        searchBox.setTextColor(WHITE);
        searchBox.setBackgroundColor(SURFACE);
        searchBox.setPadding(dp(16), dp(12), dp(16), dp(12));
        searchBox.setSingleLine(true);
        searchBox.addTextChangedListener(new TextWatcher() {
            public void beforeTextChanged(CharSequence s, int a, int b, int c) {}
            public void onTextChanged(CharSequence s, int a, int b, int c) { filterGames(s.toString()); }
            public void afterTextChanged(Editable s) {}
        });

        gamesListView = new ListView(this);
        gamesListView.setBackgroundColor(BG);
        gamesListView.setDivider(null);

        s.addView(searchBox, new LinearLayout.LayoutParams(-1, -2));
        s.addView(gamesListView, new LinearLayout.LayoutParams(-1, 0, 1f));
        return s;
    }

    private void filterGames(String query) {
        filteredGames.clear();
        String q = query.trim().toLowerCase();
        for (String g : allGames) {
            if (q.isEmpty() || g.toLowerCase().contains(q)) filteredGames.add(g);
        }
        refreshGamesList();
    }

    private void refreshGamesList() {
        final List<String> snapshot = new ArrayList<>(filteredGames);
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, snapshot) {
            @Override
            public View getView(int pos, View conv, android.view.ViewGroup parent) {
                // Row: [cover ImageView 160×90dp] [game name text]
                LinearLayout row = new LinearLayout(getContext());
                row.setOrientation(LinearLayout.HORIZONTAL);
                row.setGravity(Gravity.CENTER_VERTICAL);
                row.setBackgroundColor(BG);
                row.setPadding(0, dp(4), dp(16), dp(4));

                // Cover art thumbnail
                ImageView cover = new ImageView(getContext());
                cover.setScaleType(ImageView.ScaleType.CENTER_CROP);
                cover.setBackgroundColor(SURFACE);
                LinearLayout.LayoutParams imgLp = new LinearLayout.LayoutParams(dp(160), dp(90));
                imgLp.rightMargin = dp(16);
                row.addView(cover, imgLp);

                // Game name
                String game = getItem(pos);
                TextView tv = new TextView(getContext());
                tv.setText(game.replace("_", " "));
                tv.setTextColor(WHITE);
                tv.setTextSize(15f);
                tv.setTypeface(null, Typeface.BOLD);
                tv.setLayoutParams(new LinearLayout.LayoutParams(0, -2, 1f));
                row.addView(tv);

                // Tag ImageView with game name to avoid recycled-view mismatches
                cover.setTag(game);
                loadCover(game, cover);

                return row;
            }
        };
        gamesListView.setAdapter(adapter);
        gamesListView.setOnItemClickListener((parent, view, pos, id) -> {
            selectedGame = snapshot.get(pos);
            showScreen(2);
            fetchConfigs(selectedGame);
        });
    }

    // ── Cover art loading ─────────────────────────────────────────────────────

    /**
     * Loads Steam header art (460×215) into iv asynchronously.
     * Lookup order: memory cache → SP (cached appid) → Steam search API → Steam CDN.
     * Tags iv with the game name; skips setImage if the view was recycled.
     */
    private void loadCover(String game, ImageView iv) {
        // Memory cache hit — set immediately
        Bitmap cached = coverCache.get(game);
        if (cached != null) {
            iv.setImageBitmap(cached);
            return;
        }
        iv.setImageBitmap(null);

        new Thread(() -> {
            try {
                SharedPreferences sp = getSharedPreferences(COVERS_SP, 0);
                String appId = sp.getString("appid:" + game, null);

                // Step 1: look up Steam appid if not cached
                if (appId == null) {
                    String query = game.replace("_", " ");
                    HttpURLConnection conn = openGet(STEAM_SEARCH + urlEncode(query));
                    conn.setRequestProperty("User-Agent", "BannerHub/1.0");
                    String body = readResponse(conn);
                    JSONObject json = new JSONObject(body);
                    JSONArray items = json.optJSONArray("items");
                    if (items != null && items.length() > 0) {
                        appId = String.valueOf(items.getJSONObject(0).getInt("id"));
                        sp.edit().putString("appid:" + game, appId).apply();
                    }
                }
                if (appId == null) return;

                // Step 2: download header.jpg
                String imgUrl = String.format(STEAM_HEADER, appId);
                HttpURLConnection imgConn = openGet(imgUrl);
                imgConn.setRequestProperty("User-Agent", "BannerHub/1.0");
                InputStream in = imgConn.getInputStream();
                Bitmap bmp = BitmapFactory.decodeStream(in);
                in.close();

                if (bmp != null) {
                    coverCache.put(game, bmp);
                    ui.post(() -> {
                        // Only set if the ImageView hasn't been recycled to another game
                        if (game.equals(iv.getTag())) iv.setImageBitmap(bmp);
                    });
                }
            } catch (Exception ignored) {
                // Silently fail — ImageView stays as dark placeholder
            }
        }).start();
    }

    // ── Screen 2: Configs ─────────────────────────────────────────────────────

    private LinearLayout buildConfigsScreen() {
        LinearLayout s = new LinearLayout(this);
        s.setOrientation(LinearLayout.VERTICAL);
        s.setBackgroundColor(BG);

        configsListView = new ListView(this);
        configsListView.setBackgroundColor(BG);
        configsListView.setDivider(null);

        s.addView(configsListView, matchLinearParams());
        return s;
    }

    private void refreshConfigsList() {
        List<String> labels = new ArrayList<>();
        for (JSONObject c : currentConfigs) {
            String device = c.optString("device", "Unknown");
            String soc    = c.optString("soc", "");
            String date   = c.optString("date", "");
            int votes     = c.optInt("votes", 0);
            String label  = device.replace("_", " ")
                    + (soc.isEmpty() ? "" : " [" + soc.replace("_", " ") + "]")
                    + "\n" + date + "  ★ " + votes;
            labels.add(label);
        }
        final List<String> finalLabels = labels;
        ArrayAdapter<String> adapter = new ArrayAdapter<String>(this,
                android.R.layout.simple_list_item_1, labels) {
            @Override
            public View getView(int pos, View conv, android.view.ViewGroup parent) {
                LinearLayout row = new LinearLayout(getContext());
                row.setOrientation(LinearLayout.VERTICAL);
                row.setPadding(dp(20), dp(14), dp(20), dp(14));
                row.setBackgroundColor(BG);

                String[] parts = finalLabels.get(pos).split("\n", 2);
                TextView title = new TextView(getContext());
                title.setText(parts[0]);
                title.setTextColor(WHITE);
                title.setTextSize(14f);
                title.setTypeface(null, Typeface.BOLD);

                TextView sub = new TextView(getContext());
                sub.setText(parts.length > 1 ? parts[1] : "");
                sub.setTextColor(GREY);
                sub.setTextSize(12f);

                View div = new View(getContext());
                div.setBackgroundColor(DIVIDER);

                row.addView(title);
                row.addView(sub);
                row.addView(div, new LinearLayout.LayoutParams(-1, 1));
                return row;
            }
        };
        configsListView.setAdapter(adapter);
        configsListView.setOnItemClickListener((parent, view, pos, id) -> {
            selectedConfig = currentConfigs.get(pos);
            populateDetailScreen(selectedConfig);
            showScreen(3);
        });
    }

    // ── Screen 3: Detail ──────────────────────────────────────────────────────

    private LinearLayout buildDetailScreen() {
        LinearLayout s = new LinearLayout(this);
        s.setOrientation(LinearLayout.VERTICAL);
        s.setBackgroundColor(BG);

        ScrollView scroll = new ScrollView(this);
        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setPadding(dp(20), dp(16), dp(20), dp(24));
        content.setTag("detail_content");

        scroll.addView(content, matchParams());
        s.addView(scroll, matchLinearParams());
        return s;
    }

    private void populateDetailScreen(JSONObject config) {
        ScrollView scroll = (ScrollView) screenDetail.getChildAt(0);
        LinearLayout content = (LinearLayout) scroll.getChildAt(0);
        content.removeAllViews();

        String filename = config.optString("filename", "config.json");
        String device   = config.optString("device", "Unknown").replace("_", " ");
        String soc      = config.optString("soc", "").replace("_", " ");
        String date     = config.optString("date", "");
        String sha      = config.optString("sha", "");
        int    votes    = config.optInt("votes", 0);

        headerTitle.setText(filename.length() > 30 ? filename.substring(0, 28) + "…" : filename);

        // Device info card
        LinearLayout card = surface();
        card.setPadding(dp(16), dp(14), dp(16), dp(14));
        addInfoRow(card, "Device",  device);
        if (!soc.isEmpty())  addInfoRow(card, "SOC", soc);
        if (!date.isEmpty()) addInfoRow(card, "Date", date);
        content.addView(card, marginParams(0, 0, 0, dp(12)));

        // Meta card (populated after download if available)
        LinearLayout metaCard = surface();
        metaCard.setPadding(dp(16), dp(14), dp(16), dp(14));
        metaCard.setTag("meta_card");
        content.addView(metaCard, marginParams(0, 0, 0, dp(12)));
        fetchMeta(config, metaCard);

        // Vote row
        LinearLayout voteRow = new LinearLayout(this);
        voteRow.setOrientation(LinearLayout.HORIZONTAL);
        voteRow.setGravity(Gravity.CENTER_VERTICAL);

        votesLabel = new TextView(this);
        votesLabel.setText("★ " + votes + " votes");
        votesLabel.setTextColor(0xFFFFD700);
        votesLabel.setTextSize(16f);
        votesLabel.setTypeface(null, Typeface.BOLD);
        LinearLayout.LayoutParams voteLp = new LinearLayout.LayoutParams(0, -2, 1f);
        voteRow.addView(votesLabel, voteLp);

        voteBtn = new Button(this);
        boolean alreadyVoted = getSharedPreferences(VOTES_SP, 0).contains(sha);
        voteBtn.setText(alreadyVoted ? "Voted ✓" : "Upvote ↑");
        voteBtn.setBackgroundColor(alreadyVoted ? SURFACE : ACCENT);
        voteBtn.setTextColor(WHITE);
        voteBtn.setEnabled(!alreadyVoted);
        voteBtn.setOnClickListener(v -> doVote(config));
        voteRow.addView(voteBtn);

        content.addView(voteRow, marginParams(0, 0, 0, dp(12)));

        // Action buttons
        Button downloadBtn = new Button(this);
        downloadBtn.setText("Download to Device");
        downloadBtn.setBackgroundColor(0xFF2E7D32);
        downloadBtn.setTextColor(WHITE);
        downloadBtn.setOnClickListener(v -> downloadConfig(config));
        content.addView(downloadBtn, marginParams(0, 0, 0, dp(8)));

        TextView applyNote = new TextView(this);
        applyNote.setText("After downloading, use Import Config from a game's settings to apply.");
        applyNote.setTextColor(GREY);
        applyNote.setTextSize(12f);
        content.addView(applyNote, marginParams(0, 0, 0, dp(16)));

        // Divider
        View div = new View(this);
        div.setBackgroundColor(DIVIDER);
        content.addView(div, marginParams(0, 0, 0, dp(16), -1, 1));

        // Comments section
        TextView commentsHeader = new TextView(this);
        commentsHeader.setText("Comments");
        commentsHeader.setTextColor(WHITE);
        commentsHeader.setTextSize(16f);
        commentsHeader.setTypeface(null, Typeface.BOLD);
        content.addView(commentsHeader, marginParams(0, 0, 0, dp(10)));

        commentsContainer = new LinearLayout(this);
        commentsContainer.setOrientation(LinearLayout.VERTICAL);
        content.addView(commentsContainer, matchLinearParams());

        // Add comment box
        LinearLayout commentInput = new LinearLayout(this);
        commentInput.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams ciLp = new LinearLayout.LayoutParams(-1, -2);
        ciLp.topMargin = dp(12);

        EditText commentBox = new EditText(this);
        commentBox.setHint("Add a comment...");
        commentBox.setHintTextColor(GREY);
        commentBox.setTextColor(WHITE);
        commentBox.setBackgroundColor(SURFACE);
        commentBox.setPadding(dp(12), dp(10), dp(12), dp(10));
        commentBox.setMinLines(2);
        commentInput.addView(commentBox, matchLinearParams());

        Button submitBtn = new Button(this);
        submitBtn.setText("Post Comment");
        submitBtn.setBackgroundColor(ACCENT);
        submitBtn.setTextColor(WHITE);
        LinearLayout.LayoutParams sbLp = new LinearLayout.LayoutParams(-1, -2);
        sbLp.topMargin = dp(6);
        submitBtn.setOnClickListener(v -> {
            String text = commentBox.getText().toString().trim();
            if (text.isEmpty()) return;
            postComment(config, text, commentBox);
        });
        commentInput.addView(submitBtn, sbLp);
        content.addView(commentInput, ciLp);

        // Fetch comments
        fetchComments(config);
    }

    private void addInfoRow(LinearLayout parent, String label, String value) {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        LinearLayout.LayoutParams rp = new LinearLayout.LayoutParams(-1, -2);
        rp.bottomMargin = dp(4);

        TextView lbl = new TextView(this);
        lbl.setText(label + ": ");
        lbl.setTextColor(GREY);
        lbl.setTextSize(13f);
        lbl.setMinWidth(dp(80));

        TextView val = new TextView(this);
        val.setText(value);
        val.setTextColor(WHITE);
        val.setTextSize(13f);

        row.addView(lbl);
        row.addView(val);
        parent.addView(row, rp);
    }

    // ── Network: Games ────────────────────────────────────────────────────────

    private void fetchGames() {
        headerTitle.setText("Game Configs");
        new Thread(() -> {
            try {
                HttpURLConnection conn = openGet(WORKER + "/games");
                String body = readResponse(conn);
                JSONArray arr = new JSONArray(body);
                List<String> games = new ArrayList<>();
                for (int i = 0; i < arr.length(); i++) games.add(arr.getString(i));
                ui.post(() -> {
                    allGames.clear();
                    allGames.addAll(games);
                    filteredGames.clear();
                    filteredGames.addAll(games);
                    refreshGamesList();
                    if (games.isEmpty()) {
                        Toast.makeText(this, "No community configs yet", Toast.LENGTH_SHORT).show();
                    }
                });
            } catch (Exception e) {
                ui.post(() -> Toast.makeText(this, "Error loading games: " + e.getMessage(), Toast.LENGTH_LONG).show());
            }
        }).start();
    }

    // ── Network: Configs ──────────────────────────────────────────────────────

    private void fetchConfigs(String game) {
        String displayName = game.replace("_", " ");
        headerTitle.setText(displayName);
        currentConfigs.clear();
        refreshConfigsList();
        new Thread(() -> {
            try {
                HttpURLConnection conn = openGet(WORKER + "/list?game=" + urlEncode(game));
                String body = readResponse(conn);
                JSONArray arr = new JSONArray(body);
                List<JSONObject> configs = new ArrayList<>();
                for (int i = 0; i < arr.length(); i++) configs.add(arr.getJSONObject(i));
                ui.post(() -> {
                    currentConfigs.clear();
                    currentConfigs.addAll(configs);
                    refreshConfigsList();
                    if (configs.isEmpty()) {
                        Toast.makeText(this, "No configs shared yet for " + displayName, Toast.LENGTH_SHORT).show();
                    }
                });
            } catch (Exception e) {
                ui.post(() -> Toast.makeText(this, "Error: " + e.getMessage(), Toast.LENGTH_LONG).show());
            }
        }).start();
    }

    // ── Network: Meta (quick download + parse) ────────────────────────────────

    private void fetchMeta(JSONObject config, LinearLayout metaCard) {
        String game     = config.optString("game_folder", selectedGame);
        String filename = config.optString("filename", "");
        new Thread(() -> {
            try {
                HttpURLConnection conn = openGet(WORKER + "/download?game=" + urlEncode(game) + "&file=" + urlEncode(filename));
                String body = readResponse(conn);
                JSONObject json = new JSONObject(body);
                JSONObject meta = json.optJSONObject("meta");
                int settingsCount  = meta != null ? 0 : json.optJSONObject("settings") != null ? json.getJSONObject("settings").length() : json.length();
                if (json.has("settings")) settingsCount = json.getJSONObject("settings").length();
                int compCount = json.has("components") ? json.getJSONArray("components").length() : 0;
                final JSONObject m = meta;
                final int sc = settingsCount, cc = compCount;
                ui.post(() -> {
                    metaCard.removeAllViews();
                    metaCard.setPadding(dp(16), dp(14), dp(16), dp(14));
                    if (m != null) {
                        String renderer = m.optString("renderer", "");
                        String cpu      = m.optString("cpu", "");
                        String fps      = m.optString("fps", "");
                        String bhVer    = m.optString("bh_version", "");
                        if (!renderer.isEmpty()) addInfoRow(metaCard, "Renderer", renderer);
                        if (!cpu.isEmpty())      addInfoRow(metaCard, "CPU", cpu);
                        if (!fps.isEmpty())      addInfoRow(metaCard, "FPS Cap", fps);
                        if (!bhVer.isEmpty())    addInfoRow(metaCard, "BH Version", bhVer);
                    }
                    addInfoRow(metaCard, "Settings", sc + " keys");
                    addInfoRow(metaCard, "Components", cc + " bundled");
                });
            } catch (Exception e) {
                ui.post(() -> {
                    metaCard.removeAllViews();
                    TextView err = new TextView(this);
                    err.setText("(could not load details)");
                    err.setTextColor(GREY);
                    err.setTextSize(12f);
                    metaCard.addView(err);
                });
            }
        }).start();
    }

    // ── Network: Vote ─────────────────────────────────────────────────────────

    private void doVote(JSONObject config) {
        String sha      = config.optString("sha", "");
        String game     = config.optString("game_folder", selectedGame);
        String filename = config.optString("filename", "");
        voteBtn.setEnabled(false);
        voteBtn.setText("Voting...");
        new Thread(() -> {
            try {
                JSONObject body = new JSONObject();
                body.put("sha",      sha);
                body.put("game",     game);
                body.put("filename", filename);
                HttpURLConnection conn = openPost(WORKER + "/vote", body.toString());
                String resp = readResponse(conn);
                JSONObject r = new JSONObject(resp);
                int newCount = r.optInt("votes", config.optInt("votes", 0) + 1);
                // Mark voted locally
                getSharedPreferences(VOTES_SP, 0).edit().putBoolean(sha, true).apply();
                // Update config object
                config.put("votes", newCount);
                ui.post(() -> {
                    votesLabel.setText("★ " + newCount + " votes");
                    voteBtn.setText("Voted ✓");
                    voteBtn.setBackgroundColor(SURFACE);
                    // Update config list entry too
                    refreshConfigsList();
                });
            } catch (Exception e) {
                ui.post(() -> {
                    voteBtn.setEnabled(true);
                    voteBtn.setText("Upvote ↑");
                    Toast.makeText(this, "Vote failed: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                });
            }
        }).start();
    }

    // ── Network: Download to device ───────────────────────────────────────────

    private void downloadConfig(JSONObject config) {
        String game     = config.optString("game_folder", selectedGame);
        String filename = config.optString("filename", "config.json");
        Toast.makeText(this, "Downloading...", Toast.LENGTH_SHORT).show();
        new Thread(() -> {
            try {
                HttpURLConnection conn = openGet(WORKER + "/download?game=" + urlEncode(game) + "&file=" + urlEncode(filename));
                InputStream in = conn.getInputStream();
                File dir = new File(android.os.Environment.getExternalStorageDirectory(), EXPORT_DIR);
                dir.mkdirs();
                File out = new File(dir, filename);
                FileOutputStream fos = new FileOutputStream(out);
                byte[] buf = new byte[8192];
                int n;
                while ((n = in.read(buf)) != -1) fos.write(buf, 0, n);
                in.close();
                fos.close();
                ui.post(() -> Toast.makeText(this,
                        "Saved to BannerHub/configs/\nUse Import Config in-game to apply.",
                        Toast.LENGTH_LONG).show());
            } catch (Exception e) {
                ui.post(() -> Toast.makeText(this, "Download failed: " + e.getMessage(), Toast.LENGTH_LONG).show());
            }
        }).start();
    }

    // ── Network: Comments ─────────────────────────────────────────────────────

    private void fetchComments(JSONObject config) {
        String game     = config.optString("game_folder", selectedGame);
        String filename = config.optString("filename", "");
        new Thread(() -> {
            try {
                HttpURLConnection conn = openGet(WORKER + "/comments?game=" + urlEncode(game) + "&file=" + urlEncode(filename));
                String body = readResponse(conn);
                JSONArray arr = new JSONArray(body);
                ui.post(() -> renderComments(arr));
            } catch (Exception e) {
                ui.post(() -> {
                    if (commentsContainer != null) {
                        TextView err = new TextView(this);
                        err.setText("Could not load comments");
                        err.setTextColor(GREY);
                        err.setTextSize(12f);
                        commentsContainer.addView(err);
                    }
                });
            }
        }).start();
    }

    private void renderComments(JSONArray arr) {
        if (commentsContainer == null) return;
        commentsContainer.removeAllViews();
        if (arr.length() == 0) {
            TextView empty = new TextView(this);
            empty.setText("No comments yet — be the first!");
            empty.setTextColor(GREY);
            empty.setTextSize(13f);
            LinearLayout.LayoutParams ep = new LinearLayout.LayoutParams(-1, -2);
            ep.bottomMargin = dp(8);
            commentsContainer.addView(empty, ep);
            return;
        }
        for (int i = 0; i < arr.length(); i++) {
            JSONObject c = arr.optJSONObject(i);
            if (c == null) continue;
            String text   = c.optString("text", "");
            String device = c.optString("device", "Anonymous").replace("_", " ");
            String date   = c.optString("date", "");

            LinearLayout bubble = surface();
            bubble.setPadding(dp(12), dp(10), dp(12), dp(10));
            LinearLayout.LayoutParams bp = new LinearLayout.LayoutParams(-1, -2);
            bp.bottomMargin = dp(8);

            TextView meta = new TextView(this);
            meta.setText(device + (date.isEmpty() ? "" : "  " + date));
            meta.setTextColor(GREY);
            meta.setTextSize(11f);

            TextView body = new TextView(this);
            body.setText(text);
            body.setTextColor(WHITE);
            body.setTextSize(13f);
            LinearLayout.LayoutParams tp = new LinearLayout.LayoutParams(-1, -2);
            tp.topMargin = dp(4);

            bubble.addView(meta);
            bubble.addView(body, tp);
            commentsContainer.addView(bubble, bp);
        }
    }

    private void postComment(JSONObject config, String text, EditText commentBox) {
        String game     = config.optString("game_folder", selectedGame);
        String filename = config.optString("filename", "");
        String device   = android.os.Build.MANUFACTURER + "_" + android.os.Build.MODEL;
        commentBox.setEnabled(false);
        new Thread(() -> {
            try {
                JSONObject body = new JSONObject();
                body.put("game",     game);
                body.put("filename", filename);
                body.put("text",     text);
                body.put("device",   device);
                HttpURLConnection conn = openPost(WORKER + "/comment", body.toString());
                String resp = readResponse(conn);
                JSONObject r = new JSONObject(resp);
                if (r.optBoolean("success", false)) {
                    ui.post(() -> {
                        commentBox.setText("");
                        commentBox.setEnabled(true);
                        Toast.makeText(this, "Comment posted", Toast.LENGTH_SHORT).show();
                        fetchComments(config); // refresh
                    });
                } else {
                    throw new Exception(r.optString("error", "Unknown error"));
                }
            } catch (Exception e) {
                ui.post(() -> {
                    commentBox.setEnabled(true);
                    Toast.makeText(this, "Failed: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                });
            }
        }).start();
    }

    // ── Screen management ─────────────────────────────────────────────────────

    private void showScreen(int n) {
        currentScreen = n;
        screenGames.setVisibility(n == 1 ? View.VISIBLE : View.GONE);
        screenConfigs.setVisibility(n == 2 ? View.VISIBLE : View.GONE);
        screenDetail.setVisibility(n == 3 ? View.VISIBLE : View.GONE);
        if (n == 1) headerTitle.setText("Game Configs");
    }

    // ── HTTP helpers ──────────────────────────────────────────────────────────

    private HttpURLConnection openGet(String url) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(15000);
        c.setReadTimeout(15000);
        return c;
    }

    private HttpURLConnection openPost(String url, String jsonBody) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setRequestMethod("POST");
        c.setDoOutput(true);
        c.setConnectTimeout(15000);
        c.setReadTimeout(15000);
        c.setRequestProperty("Content-Type", "application/json");
        OutputStream os = c.getOutputStream();
        os.write(jsonBody.getBytes("UTF-8"));
        os.close();
        return c;
    }

    private String readResponse(HttpURLConnection conn) throws Exception {
        InputStream is = conn.getResponseCode() < 400
                ? conn.getInputStream() : conn.getErrorStream();
        BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
        br.close();
        return sb.toString();
    }

    private String urlEncode(String s) {
        try { return java.net.URLEncoder.encode(s, "UTF-8"); }
        catch (Exception e) { return s; }
    }

    // ── Layout helpers ────────────────────────────────────────────────────────

    private int dp(int v) {
        return (int) (v * getResources().getDisplayMetrics().density);
    }

    private FrameLayout.LayoutParams matchParams() {
        return new FrameLayout.LayoutParams(-1, -1);
    }

    private LinearLayout.LayoutParams matchLinearParams() {
        return new LinearLayout.LayoutParams(-1, -1);
    }

    private LinearLayout.LayoutParams marginParams(int l, int t, int r, int b) {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-1, -2);
        lp.setMargins(l, t, r, b);
        return lp;
    }

    private LinearLayout.LayoutParams marginParams(int l, int t, int r, int b, int w, int h) {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(w, h);
        lp.setMargins(l, t, r, b);
        return lp;
    }

    private LinearLayout surface() {
        LinearLayout ll = new LinearLayout(this);
        ll.setOrientation(LinearLayout.VERTICAL);
        ll.setBackgroundColor(SURFACE);
        return ll;
    }
}
