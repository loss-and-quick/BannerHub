.class public final Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$9;
.super Ljava/lang/Object;

# BannerHub: DialogInterface$OnClickListener — "Launch" button in the
# cover-art preview dialog shown by GogGamesFragment$7.
# Casts context to LandscapeLauncherMainActivity and calls B3(exePath)
# to open the built-in Import Game flow (EditImportedGameInfoDialog).

.implements Landroid/content/DialogInterface$OnClickListener;

.field public final a:Landroid/content/Context;
.field public final b:Ljava/lang/String;  # absolute normalized exe path


.method public constructor <init>(Landroid/content/Context;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$9;->a:Landroid/content/Context;
    iput-object p2, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$9;->b:Ljava/lang/String;

    return-void
.end method


.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2

    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$9;->a:Landroid/content/Context;
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$9;->b:Ljava/lang/String;

    check-cast v0, Lcom/xj/landscape/launcher/ui/main/LandscapeLauncherMainActivity;
    invoke-virtual {v0, v1}, Lcom/xj/landscape/launcher/ui/main/LandscapeLauncherMainActivity;->B3(Ljava/lang/String;)V

    return-void
.end method

