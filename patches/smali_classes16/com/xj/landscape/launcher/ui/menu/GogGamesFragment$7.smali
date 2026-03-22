.class public final Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;
.super Ljava/lang/Object;

# BannerHub: Launch click listener for installed GOG games.
# Reads the stored exe path from bh_gog_prefs (gog_exe_{gameId}),
# casts context to LandscapeLauncherMainActivity, and calls B3(exePath)
# which triggers the built-in Import Game flow (EditImportedGameInfoDialog).

.implements Landroid/content/DialogInterface$OnClickListener;

.field public final a:Landroid/content/Context;
.field public final b:Lcom/xj/landscape/launcher/ui/menu/GogGame;


.method public constructor <init>(Landroid/content/Context;Lcom/xj/landscape/launcher/ui/menu/GogGame;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;->a:Landroid/content/Context;
    iput-object p2, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;->b:Lcom/xj/landscape/launcher/ui/menu/GogGame;

    return-void
.end method


.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 6

    # v0 = context
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;->a:Landroid/content/Context;

    # v1 = GogGame
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$7;->b:Lcom/xj/landscape/launcher/ui/menu/GogGame;

    # v2 = gameId
    iget-object v2, v1, Lcom/xj/landscape/launcher/ui/menu/GogGame;->gameId:Ljava/lang/String;
    if-eqz v2, :launch_done

    # Read gog_exe_{gameId} from bh_gog_prefs
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
    move-result-object v3  # full absolute exe path

    # If no exe path stored, toast and bail
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

    # Normalize: replace any backslashes with forward slashes
    const-string v4, "\\"
    const-string v5, "/"
    invoke-virtual {v3, v4, v5}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
    move-result-object v3  # exePath (absolute Android path)

    # Cast context to LandscapeLauncherMainActivity and call B3(exePath).
    # B3 shows EditImportedGameInfoDialog — the built-in Import Game flow.
    check-cast v0, Lcom/xj/landscape/launcher/ui/main/LandscapeLauncherMainActivity;
    invoke-virtual {v0, v3}, Lcom/xj/landscape/launcher/ui/main/LandscapeLauncherMainActivity;->B3(Ljava/lang/String;)V

    :launch_done
    return-void
.end method
