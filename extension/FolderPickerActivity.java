package app.revanced.extension.gamehub;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Typeface;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.Gravity;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 * In-app folder picker for cloud save directory selection.
 *
 * Opens at getFilesDir() — the app's private files directory, which
 * contains all Wine containers.
 *
 * Navigates into subdirectories; "Select this folder" returns the
 * currently displayed directory path via setResult().
 *
 * Result extras:
 *   "path" (String) — absolute path of the selected folder
 */
public class FolderPickerActivity extends Activity {

    private File currentDir;
    private TextView pathTV;
    private LinearLayout listContainer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        currentDir = getFilesDir();
        buildUi();
    }

    private void buildUi() {
        LinearLayout root = new LinearLayout(this);
        root.setOrientation(LinearLayout.VERTICAL);
        root.setBackgroundColor(0xFF0D0D0D);

        // ── Header ────────────────────────────────────────────────────────────
        LinearLayout header = new LinearLayout(this);
        header.setOrientation(LinearLayout.VERTICAL);
        header.setBackgroundColor(0xFF1A1A2E);
        header.setPadding(dp(12), dp(10), dp(12), dp(10));

        TextView titleTV = new TextView(this);
        titleTV.setText("Select Folder");
        titleTV.setTextColor(0xFFFFFFFF);
        titleTV.setTextSize(16f);
        titleTV.setTypeface(null, Typeface.BOLD);
        header.addView(titleTV);

        pathTV = new TextView(this);
        pathTV.setTextColor(0xFF8888AA);
        pathTV.setTextSize(11f);
        pathTV.setPadding(0, dp(4), 0, 0);
        header.addView(pathTV);

        root.addView(header, new LinearLayout.LayoutParams(-1, -2));

        // ── Select this folder button ─────────────────────────────────────────
        Button selectBtn = makeBtn("✓  Select this folder", 0xFF2E7D32);
        selectBtn.setOnClickListener(v -> {
            Intent result = new Intent();
            result.putExtra("path", currentDir.getAbsolutePath());
            setResult(RESULT_OK, result);
            finish();
        });
        LinearLayout.LayoutParams selLp = new LinearLayout.LayoutParams(-1, dp(48));
        selLp.setMargins(dp(12), dp(8), dp(12), dp(4));
        root.addView(selectBtn, selLp);

        // ── Directory list ────────────────────────────────────────────────────
        ScrollView scroll = new ScrollView(this);
        listContainer = new LinearLayout(this);
        listContainer.setOrientation(LinearLayout.VERTICAL);
        listContainer.setPadding(dp(12), dp(4), dp(12), dp(24));
        scroll.addView(listContainer);
        root.addView(scroll, new LinearLayout.LayoutParams(-1, 0, 1f));

        setContentView(root);
        refreshList();
    }

    private void refreshList() {
        listContainer.removeAllViews();
        updatePathLabel();

        // ── "↑ Up" row ────────────────────────────────────────────────────────
        File parent = currentDir.getParentFile();
        if (parent != null && !currentDir.equals(getFilesDir())) {
            // Don't let navigation escape above getFilesDir()
            if (currentDir.getAbsolutePath().startsWith(getFilesDir().getAbsolutePath())) {
                listContainer.addView(makeDirRow("↑  Up", parent, true));
            }
        }

        // ── Subdirectories ────────────────────────────────────────────────────
        File[] files = currentDir.listFiles();
        if (files == null) {
            TextView tv = new TextView(this);
            tv.setText("(empty or no read permission)");
            tv.setTextColor(0xFF555577);
            tv.setTextSize(13f);
            listContainer.addView(tv);
            return;
        }

        List<File> dirs = new ArrayList<>();
        for (File f : files) {
            if (f.isDirectory()) dirs.add(f);
        }
        Collections.sort(dirs, (a, b) -> a.getName().compareToIgnoreCase(b.getName()));

        if (dirs.isEmpty()) {
            TextView tv = new TextView(this);
            tv.setText("(no subdirectories)");
            tv.setTextColor(0xFF555577);
            tv.setTextSize(13f);
            listContainer.addView(tv);
        } else {
            for (File dir : dirs) {
                listContainer.addView(makeDirRow("📁  " + dir.getName(), dir, false));
            }
        }
    }

    private void updatePathLabel() {
        String abs = currentDir.getAbsolutePath();
        String[] parts = abs.split("/");
        // Show last 3 segments
        if (parts.length <= 3) {
            pathTV.setText(abs);
        } else {
            pathTV.setText("…/" + parts[parts.length - 2] + "/" + parts[parts.length - 1]);
        }
    }

    private LinearLayout makeDirRow(String label, File target, boolean isUp) {
        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(12), dp(10), dp(12), dp(10));

        GradientDrawable bg = new GradientDrawable();
        bg.setColor(isUp ? 0xFF1E1A2E : 0xFF1A1E2E);
        bg.setCornerRadius(dp(6));
        bg.setStroke(dp(1), 0xFF2A2A3A);
        row.setBackground(bg);

        TextView tv = new TextView(this);
        tv.setText(label);
        tv.setTextColor(isUp ? 0xFFAAAAAA : 0xFFDDDDFF);
        tv.setTextSize(13f);
        row.addView(tv, new LinearLayout.LayoutParams(0, -2, 1f));

        if (!isUp) {
            TextView arrowTV = new TextView(this);
            arrowTV.setText("›");
            arrowTV.setTextColor(0xFF555577);
            arrowTV.setTextSize(18f);
            row.addView(arrowTV, new LinearLayout.LayoutParams(-2, -2));
        }

        row.setOnClickListener(v -> {
            currentDir = target;
            refreshList();
        });

        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-1, -2);
        lp.bottomMargin = dp(6);
        row.setLayoutParams(lp);
        return row;
    }

    private Button makeBtn(String text, int color) {
        Button btn = new Button(this);
        btn.setText(text);
        btn.setTextColor(0xFFFFFFFF);
        btn.setTextSize(14f);
        btn.setTypeface(null, Typeface.BOLD);
        GradientDrawable bg = new GradientDrawable();
        bg.setColor(color);
        bg.setCornerRadius(dp(8));
        btn.setBackground(bg);
        return btn;
    }

    private int dp(int v) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v,
                getResources().getDisplayMetrics());
    }
}
