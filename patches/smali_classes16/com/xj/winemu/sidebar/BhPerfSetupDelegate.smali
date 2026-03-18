.class public Lcom/xj/winemu/sidebar/BhPerfSetupDelegate;
.super Landroid/view/View;
.source "SourceFile"


# direct methods
.method public constructor <init>(Landroid/content/Context;Landroid/util/AttributeSet;)V
    .locals 0

    invoke-direct {p0, p1, p2}, Landroid/view/View;-><init>(Landroid/content/Context;Landroid/util/AttributeSet;)V

    return-void
.end method


# virtual methods
.method protected onAttachedToWindow()V
    .locals 5

    invoke-super {p0}, Landroid/view/View;->onAttachedToWindow()V

    # Get parent view (performance_fl LinearLayout — contains all sibling switches)
    invoke-virtual {p0}, Landroid/view/View;->getParent()Landroid/view/ViewParent;
    move-result-object v0
    if-eqz v0, :cond_done
    check-cast v0, Landroid/view/View;

    # Get context for SharedPreferences
    invoke-virtual {p0}, Landroid/view/View;->getContext()Landroid/content/Context;
    move-result-object v1
    if-eqz v1, :cond_done

    const-string v2, "bh_prefs"
    const/4 v3, 0x0
    invoke-virtual {v1, v2, v3}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v2

    # Sustained Perf switch
    const v1, 0x7f0a0f0e
    invoke-virtual {v0, v1}, Landroid/view/View;->findViewById(I)Landroid/view/View;
    move-result-object v1
    check-cast v1, Lcom/xj/winemu/view/SidebarSwitchItemView;
    if-eqz v1, :cond_adreno

    const-string v3, "sustained_perf"
    const/4 v4, 0x0
    invoke-interface {v2, v3, v4}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
    move-result v3
    invoke-virtual {v1, v3}, Lcom/xj/winemu/view/SidebarSwitchItemView;->setSwitch(Z)V

    new-instance v3, Lcom/xj/winemu/sidebar/SustainedPerfSwitchClickListener;
    invoke-direct {v3, v1}, Lcom/xj/winemu/sidebar/SustainedPerfSwitchClickListener;-><init>(Lcom/xj/winemu/view/SidebarSwitchItemView;)V
    invoke-virtual {v1, v3}, Lcom/xj/winemu/view/SidebarSwitchItemView;->setClickListener(Lkotlin/jvm/functions/Function0;)V

    # Max Adreno Clocks switch
    :cond_adreno
    const v1, 0x7f0a0f0f
    invoke-virtual {v0, v1}, Landroid/view/View;->findViewById(I)Landroid/view/View;
    move-result-object v1
    check-cast v1, Lcom/xj/winemu/view/SidebarSwitchItemView;
    if-eqz v1, :cond_done

    const-string v3, "max_adreno_clocks"
    const/4 v4, 0x0
    invoke-interface {v2, v3, v4}, Landroid/content/SharedPreferences;->getBoolean(Ljava/lang/String;Z)Z
    move-result v3
    invoke-virtual {v1, v3}, Lcom/xj/winemu/view/SidebarSwitchItemView;->setSwitch(Z)V

    new-instance v3, Lcom/xj/winemu/sidebar/MaxAdrenoClickListener;
    invoke-direct {v3, v1}, Lcom/xj/winemu/sidebar/MaxAdrenoClickListener;-><init>(Lcom/xj/winemu/view/SidebarSwitchItemView;)V
    invoke-virtual {v1, v3}, Lcom/xj/winemu/view/SidebarSwitchItemView;->setClickListener(Lkotlin/jvm/functions/Function0;)V

    :cond_done
    return-void
.end method
