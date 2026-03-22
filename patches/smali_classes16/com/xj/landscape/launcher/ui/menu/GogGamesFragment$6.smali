.class public final Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;
.super Ljava/lang/Object;

# BannerHub: View$OnClickListener on the Download button in each GOG game card.
# Disables the Download button, shows the card percentage TextView ("0%"), then calls
# GogDownloadManager.startDownload(). The launchButton ref is passed through so
# GogDownloadManager$3 can enable it when download+install completes.

.implements Landroid/view/View$OnClickListener;

.field public final a:Landroid/content/Context;
.field public final b:Lcom/xj/landscape/launcher/ui/menu/GogGame;
.field public final c:Landroid/widget/TextView;
.field public final d:Landroid/widget/Button;


.method public constructor <init>(Landroid/content/Context;Lcom/xj/landscape/launcher/ui/menu/GogGame;Landroid/widget/TextView;Landroid/widget/Button;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;->a:Landroid/content/Context;
    iput-object p2, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;->b:Lcom/xj/landscape/launcher/ui/menu/GogGame;
    iput-object p3, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;->c:Landroid/widget/TextView;
    iput-object p4, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;->d:Landroid/widget/Button;

    return-void
.end method


.method public onClick(Landroid/view/View;)V
    .locals 4

    # Disable the Install button (p1 is the View that was clicked)
    const/4 v0, 0x0
    invoke-virtual {p1, v0}, Landroid/view/View;->setEnabled(Z)V

    # v0 = context
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;->a:Landroid/content/Context;

    # v1 = GogGame
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;->b:Lcom/xj/landscape/launcher/ui/menu/GogGame;

    # Show percentage TextView + initialize to "0%"
    iget-object v2, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;->c:Landroid/widget/TextView;
    const-string v3, "0%"
    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/4 v3, 0x0  # VISIBLE
    invoke-virtual {v2, v3}, Landroid/view/View;->setVisibility(I)V

    # v3 = Launch button (enabled by GogDownloadManager$3 on completion)
    iget-object v3, p0, Lcom/xj/landscape/launcher/ui/menu/GogGamesFragment$6;->d:Landroid/widget/Button;

    invoke-static {v0, v1, v2, v3}, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager;->startDownload(Landroid/content/Context;Lcom/xj/landscape/launcher/ui/menu/GogGame;Landroid/widget/TextView;Landroid/widget/Button;)V

    return-void
.end method
