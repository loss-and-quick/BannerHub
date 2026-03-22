.class public final Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;
.super Ljava/lang/Object;

# BannerHub: "Copy to Downloads" neutral button listener in the GOG game detail dialog.
# Implements both DialogInterface$OnClickListener and Runnable.
# onClick() starts a background thread (this as Runnable).
# run() reads gog_dir_{gameId} from bh_gog_prefs, copies
#   {filesDir}/gog_games/{dir}/ → Downloads/{dir}/
# recursively via copyDir → copyFile (8KB buffer).
# Posts a Toast on completion (or error) via Handler + GogDownloadManager$2.

.implements Landroid/content/DialogInterface$OnClickListener;
.implements Ljava/lang/Runnable;

.field public final a:Landroid/content/Context;
.field public final b:Lcom/xj/landscape/launcher/ui/menu/GogGame;


.method public constructor <init>(Landroid/content/Context;Lcom/xj/landscape/launcher/ui/menu/GogGame;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->a:Landroid/content/Context;
    iput-object p2, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->b:Lcom/xj/landscape/launcher/ui/menu/GogGame;

    return-void
.end method


# ── onClick: spawn background thread (this as Runnable) ──────────────────────
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1

    new-instance v0, Ljava/lang/Thread;
    invoke-direct {v0, p0}, Ljava/lang/Thread;-><init>(Ljava/lang/Runnable;)V
    invoke-virtual {v0}, Ljava/lang/Thread;->start()V

    return-void
.end method


# ── run: copy gog_games/{dir} → Downloads/{dir} ───────────────────────────────
# .locals 11 → v0-v10 locals, p0=v11
.method public run()V
    .locals 11

    # ── Load context + game ───────────────────────────────────────────────────
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->a:Landroid/content/Context;
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->b:Lcom/xj/landscape/launcher/ui/menu/GogGame;

    # ── Read gog_dir_{gameId} from bh_gog_prefs ───────────────────────────────
    const-string v2, "bh_gog_prefs"
    const/4 v3, 0x0
    invoke-virtual {v0, v2, v3}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v2   # SharedPreferences

    iget-object v3, v1, Lcom/xj/landscape/launcher/ui/menu/GogGame;->gameId:Ljava/lang/String;

    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "gog_dir_"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4   # key = "gog_dir_{gameId}"

    const/4 v5, 0x0
    invoke-interface {v2, v4, v5}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v4   # dirName or null

    if-nez v4, :have_dir

    const-string v9, "Game not installed"
    invoke-direct {p0, v0, v9}, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->showToast(Landroid/content/Context;Ljava/lang/String;)V
    return-void

    :have_dir

    # ── src = GogInstallPath.getInstallDir(ctx, dirName) ──────────────────────
    invoke-static {v0, v4}, Lcom/xj/landscape/launcher/ui/menu/GogInstallPath;->getInstallDir(Landroid/content/Context;Ljava/lang/String;)Ljava/io/File;
    move-result-object v5   # src File

    invoke-virtual {v5}, Ljava/io/File;->exists()Z
    move-result v6
    if-nez v6, :src_exists

    const-string v9, "Install folder not found"
    invoke-direct {p0, v0, v9}, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->showToast(Landroid/content/Context;Ljava/lang/String;)V
    return-void

    :src_exists

    # ── dest = new File(Downloads, dirName) ───────────────────────────────────
    sget-object v6, Landroid/os/Environment;->DIRECTORY_DOWNLOADS:Ljava/lang/String;
    invoke-static {v6}, Landroid/os/Environment;->getExternalStoragePublicDirectory(Ljava/lang/String;)Ljava/io/File;
    move-result-object v6   # Downloads dir

    new-instance v7, Ljava/io/File;
    invoke-direct {v7, v6, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    # v7 = dest

    # ── Recursive copy ────────────────────────────────────────────────────────
    invoke-direct {p0, v5, v7}, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->copyDir(Ljava/io/File;Ljava/io/File;)V

    # ── Toast "Copied to Downloads/{dirName}" ─────────────────────────────────
    new-instance v8, Ljava/lang/StringBuilder;
    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V
    const-string v9, "Copied to Downloads/"
    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v8, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v8   # message

    invoke-direct {p0, v0, v8}, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->showToast(Landroid/content/Context;Ljava/lang/String;)V

    return-void
.end method


# ── showToast: post Toast to main thread via Handler + GogDownloadManager$2 ──
# .locals 3 → v0-v2 locals, p0=v3, p1=v4 (Context), p2=v5 (String)
.method private showToast(Landroid/content/Context;Ljava/lang/String;)V
    .locals 3

    new-instance v0, Landroid/os/Handler;
    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v1
    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    new-instance v2, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$2;
    invoke-direct {v2, p1, p2}, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$2;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    invoke-virtual {v0, v2}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    return-void
.end method


# ── copyDir: recursively copy src dir contents into dest ─────────────────────
# .locals 8 → v0-v7 locals, p0=v8 (this), p1=v9 (src), p2=v10 (dest)
.method private copyDir(Ljava/io/File;Ljava/io/File;)V
    .locals 8

    # Create destination directory (and any missing parents)
    invoke-virtual {p2}, Ljava/io/File;->mkdirs()Z

    # List source files
    invoke-virtual {p1}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v0   # File[] or null
    if-nez v0, :have_files
    return-void

    :have_files
    array-length v1, v0     # count
    const/4 v2, 0x0         # i = 0

    :loop_start
    if-ge v2, v1, :loop_done

    aget-object v3, v0, v2  # file = files[i]

    # destChild = new File(dest, file.getName())
    invoke-virtual {v3}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v4

    new-instance v5, Ljava/io/File;
    invoke-direct {v5, p2, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    invoke-virtual {v3}, Ljava/io/File;->isDirectory()Z
    move-result v6
    if-eqz v6, :is_file

    # Directory → recurse
    invoke-direct {p0, v3, v5}, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->copyDir(Ljava/io/File;Ljava/io/File;)V
    goto :next

    :is_file
    invoke-direct {p0, v3, v5}, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$11;->copyFile(Ljava/io/File;Ljava/io/File;)V

    :next
    add-int/lit8 v2, v2, 0x1
    goto :loop_start

    :loop_done
    return-void
.end method


# ── copyFile: copy a single file using an 8KB buffer ─────────────────────────
# .locals 6 → v0-v5 locals, p0=v6 (this), p1=v7 (src), p2=v8 (dest)
.method private copyFile(Ljava/io/File;Ljava/io/File;)V
    .locals 6

    :try_start
    new-instance v0, Ljava/io/FileInputStream;
    invoke-direct {v0, p1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    new-instance v1, Ljava/io/FileOutputStream;
    invoke-direct {v1, p2}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    const/16 v2, 0x2000     # buffer size = 8192
    new-array v3, v2, [B    # byte[] buf

    :read_loop
    invoke-virtual {v0, v3}, Ljava/io/InputStream;->read([B)I
    move-result v4
    const/4 v5, -0x1        # -1 = EOF
    if-eq v4, v5, :read_done
    const/4 v5, 0x0         # offset = 0
    invoke-virtual {v1, v3, v5, v4}, Ljava/io/OutputStream;->write([BII)V
    goto :read_loop

    :read_done
    invoke-virtual {v0}, Ljava/io/InputStream;->close()V
    invoke-virtual {v1}, Ljava/io/OutputStream;->close()V
    :try_end

    return-void

    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch_all
    :catch_all
    return-void
.end method
