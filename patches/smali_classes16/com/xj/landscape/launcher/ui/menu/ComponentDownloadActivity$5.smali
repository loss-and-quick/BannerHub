# InjectRunnable — UI thread: call injectComponent (which toasts internally), then finish activity
.class final Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;

.field final this$0:Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity;
.field final val$uri:Landroid/net/Uri;
.field final val$type:I
.field final val$filename:Ljava/lang/String;

.method constructor <init>(Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity;Landroid/net/Uri;ILjava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;->this$0:Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity;
    iput-object p2, p0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;->val$uri:Landroid/net/Uri;
    iput p3, p0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;->val$type:I
    iput-object p4, p0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;->val$filename:Ljava/lang/String;
    return-void
.end method

.method public run()V
    .locals 7
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;->this$0:Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity;
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;->val$uri:Landroid/net/Uri;
    iget v2, p0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;->val$type:I

    invoke-static {v0, v1, v2}, Lcom/xj/landscape/launcher/ui/menu/ComponentInjectorHelper;->injectComponent(Landroid/content/Context;Landroid/net/Uri;I)V

    # === Record source in SharedPreferences ===
    # v1 = mDownloadFilename (val$filename)
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity$5;->val$filename:Ljava/lang/String;

    # Strip extension: baseName = v1.substring(0, lastIndexOf('.'))
    const/16 v2, 0x2e
    invoke-virtual {v1, v2}, Ljava/lang/String;->lastIndexOf(I)I
    move-result v2
    if-lez v2, :no_strip
    const/4 v3, 0x0
    invoke-virtual {v1, v3, v2}, Ljava/lang/String;->substring(II)Ljava/lang/String;
    move-result-object v1
    :no_strip

    # v2 = mCurrentRepo (repo display name)
    iget-object v2, v0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity;->mCurrentRepo:Ljava/lang/String;
    if-nez v2, :repo_ok
    const-string v2, "BannerHub"
    :repo_ok

    # v3 = mDownloadUrl — build "dl:url" key
    iget-object v3, v0, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity;->mDownloadUrl:Ljava/lang/String;
    new-instance v4, Ljava/lang/StringBuilder;
    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V
    const-string v5, "dl:"
    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v3   # v3 = "dl:url"

    # Get SP + editor
    const-string v4, "banners_sources"
    const/4 v5, 0x0
    invoke-virtual {v0, v4, v5}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v4
    invoke-interface {v4}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v4   # v4 = editor

    # baseName (v1) → repoName (v2)
    invoke-interface {v4, v1, v2}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    move-result-object v5

    # "dl:url" (v3) → "1"
    const-string v5, "1"
    invoke-interface {v4, v3, v5}, Landroid/content/SharedPreferences$Editor;->putString(Ljava/lang/String;Ljava/lang/String;)Landroid/content/SharedPreferences$Editor;
    move-result-object v5

    invoke-interface {v4}, Landroid/content/SharedPreferences$Editor;->apply()V

    invoke-virtual {v0}, Lcom/xj/landscape/launcher/ui/menu/ComponentDownloadActivity;->finish()V
    return-void
.end method
