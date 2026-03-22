.class public final Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;
.super Ljava/lang/Object;

# BannerHub: View$OnClickListener on the Launch button in each GOG game card.
# Shows a cover-art preview AlertDialog (title + cover image) before handing
# off to EditImportedGameInfoDialog via LandscapeLauncherMainActivity.B3().
# Cover image is loaded from gog_cover_{gameId} prefs key (saved during install).
# GogGamesFragment$9 is the "Launch" button listener.

.implements Landroid/view/View$OnClickListener;

.field public final a:Landroid/content/Context;
.field public final b:Lcom/xj/landscape/launcher/ui/menu/GogGame;


.method public constructor <init>(Landroid/content/Context;Lcom/xj/landscape/launcher/ui/menu/GogGame;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;->a:Landroid/content/Context;
    iput-object p2, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;->b:Lcom/xj/landscape/launcher/ui/menu/GogGame;

    return-void
.end method


.method public onClick(Landroid/view/View;)V
    .locals 12
    # p0=v12 (4-bit valid), p1=v13 (view — unused)
    # v0  = context
    # v1  = GogGame
    # v2  = gameId
    # v3  = scratch (SharedPreferences, raw strings)
    # v4  = scratch (key strings, boolean results, const flags)
    # v5  = exePath normalized (persistent until $9 construction)
    # v6  = cover path or Bitmap
    # v7  = ImageView
    # v8  = GogGamesFragment$9 listener
    # v9  = AlertDialog$Builder
    # v10 = scratch (title / button strings)
    # v11 = null const for negative button

    # ── Load fields ───────────────────────────────────────────────────────────
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;->a:Landroid/content/Context;
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;->b:Lcom/xj/landscape/launcher/ui/menu/GogGame;
    iget-object v2, v1, Lcom/xj/landscape/launcher/ui/menu/GogGame;->gameId:Ljava/lang/String;
    if-eqz v2, :launch_done

    # ── Read exePath (gog_exe_{gameId}) from prefs ────────────────────────────
    const-string v3, "bh_gog_prefs"
    const/4 v4, 0x0
    invoke-virtual {v0, v3, v4}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v3

    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "gog_exe_"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4

    const-string v5, ""
    invoke-interface {v3, v4, v5}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3  # v3 = raw exePath or ""

    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z
    move-result v4
    if-eqz v4, :exe_ready

    const-string v4, "Reinstall game to enable launch"
    const/4 v5, 0x0
    invoke-static {v0, v4, v5}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;
    move-result-object v4
    invoke-virtual {v4}, Landroid/widget/Toast;->show()V
    goto :launch_done

    :exe_ready

    # Normalize backslashes → v5 = exePath (persistent)
    const-string v4, "\\"
    const-string v5, "/"
    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v5  # v5 = normalized exePath

    # ── Read cover path (gog_cover_{gameId}) from prefs ───────────────────────
    const-string v3, "bh_gog_prefs"
    const/4 v4, 0x0
    invoke-virtual {v0, v3, v4}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v3

    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v6, "gog_cover_"
    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v4

    const-string v6, ""
    invoke-interface {v3, v4, v6}, Landroid/content/SharedPreferences;->getString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    move-result-object v3  # v3 = cover path or ""

    # ── Load cover bitmap into v6 (null if unavailable) ───────────────────────
    const/4 v6, 0x0
    invoke-virtual {v3}, Ljava/lang/String;->isEmpty()Z
    move-result v4
    if-nez v4, :no_cover
    invoke-static {v3}, Landroid/graphics/BitmapFactory;->decodeFile(Ljava/lang/String;)Landroid/graphics/Bitmap;
    move-result-object v6  # v6 = Bitmap or null
    :no_cover

    # ── Build ImageView ───────────────────────────────────────────────────────
    new-instance v7, Landroid/widget/ImageView;
    invoke-direct {v7, v0}, Landroid/widget/ImageView;-><init>(Landroid/content/Context;)V

    if-eqz v6, :skip_bitmap
    invoke-virtual {v7, v6}, Landroid/widget/ImageView;->setImageBitmap(Landroid/graphics/Bitmap;)V
    :skip_bitmap

    const/4 v4, 0x1
    invoke-virtual {v7, v4}, Landroid/widget/ImageView;->setAdjustViewBounds(Z)V

    # ── Create $9 launch confirm listener ─────────────────────────────────────
    new-instance v8, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$9;
    invoke-direct {v8, v0, v5}, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$9;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    # ── Build and show cover-art preview AlertDialog ──────────────────────────
    new-instance v9, Landroid/app/AlertDialog$Builder;
    invoke-direct {v9, v0}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    iget-object v10, v1, Lcom/xj/landscape/launcher/ui/menu/GogGame;->title:Ljava/lang/String;
    invoke-virtual {v9, v10}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v9, v7}, Landroid/app/AlertDialog$Builder;->setView(Landroid/view/View;)Landroid/app/AlertDialog$Builder;

    const-string v10, "Launch"
    invoke-virtual {v9, v10, v8}, Landroid/app/AlertDialog$Builder;->setPositiveButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    const-string v10, "Cancel"
    const/4 v11, 0x0
    invoke-virtual {v9, v10, v11}, Landroid/app/AlertDialog$Builder;->setNegativeButton(Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    invoke-virtual {v9}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    :launch_done
    return-void
.end method

