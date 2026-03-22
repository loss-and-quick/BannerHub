.class public final Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;
.super Ljava/lang/Object;

# BannerHub: UI-thread Runnable posted by GogDownloadManager$1 to update the
# card-level percentage TextView during download.
# progress 0-99: updates text to "X%".
# progress >= 100: hides TextView and calls setEnabled(true) on the Launch button.

.implements Ljava/lang/Runnable;

.field public final a:Landroid/widget/TextView;
.field public final b:Landroid/widget/Button;
.field public final c:I
.field public final d:Ljava/lang/String;


.method public constructor <init>(Landroid/widget/TextView;Landroid/widget/Button;ILjava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->a:Landroid/widget/TextView;
    iput-object p2, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->b:Landroid/widget/Button;
    iput p3, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->c:I
    iput-object p4, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->d:Ljava/lang/String;

    return-void
.end method


.method public run()V
    .locals 3

    # Build "X%" string from progress int
    iget v1, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->c:I
    invoke-static {v1}, Ljava/lang/Integer;->toString(I)Ljava/lang/String;
    move-result-object v2
    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    const-string v2, "%"
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0  # v0 = "X%"

    # Set text on percentage TextView
    iget-object v2, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->a:Landroid/widget/TextView;
    invoke-virtual {v2, v0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # If progress >= 100: hide TextView and enable Launch button
    iget v1, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->c:I
    const/16 v0, 0x64
    if-lt v1, v0, :run_done

    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->a:Landroid/widget/TextView;
    const/16 v1, 0x8  # GONE
    invoke-virtual {v0, v1}, Landroid/view/View;->setVisibility(I)V

    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/GogDownloadManager$3;->b:Landroid/widget/Button;
    if-eqz v0, :run_done
    const/4 v1, 0x1  # true = enabled
    invoke-virtual {v0, v1}, Landroid/view/View;->setEnabled(Z)V

    :run_done
    return-void
.end method

