.class public final Lcom/xj/winemu/sidebar/BhHudOpacityListener;
.super Ljava/lang/Object;
.source "SourceFile"

# OnSeekBarChangeListener for the HUD Opacity slider.
# Saves "hud_opacity" (0–100) to bh_prefs and immediately applies
# setAlpha(progress/100f) to the BhFrameRating view in the DecorView.

.implements Landroid/widget/SeekBar$OnSeekBarChangeListener;

.field public final a:Landroid/content/Context;

# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/xj/winemu/sidebar/BhHudOpacityListener;->a:Landroid/content/Context;
    return-void
.end method

# virtual methods
.method public onProgressChanged(Landroid/widget/SeekBar;IZ)V
    .locals 4
    # p1 = SeekBar, p2 = progress (0-100), p3 = fromUser (ignored)

    # Save "hud_opacity" pref
    iget-object v0, p0, Lcom/xj/winemu/sidebar/BhHudOpacityListener;->a:Landroid/content/Context;
    const-string v1, "bh_prefs"
    const/4 v2, 0x0
    invoke-virtual {v0, v1, v2}, Landroid/content/Context;->getSharedPreferences(Ljava/lang/String;I)Landroid/content/SharedPreferences;
    move-result-object v1
    invoke-interface {v1}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;
    move-result-object v1
    const-string v2, "hud_opacity"
    invoke-interface {v1, v2, p2}, Landroid/content/SharedPreferences$Editor;->putInt(Ljava/lang/String;I)Landroid/content/SharedPreferences$Editor;
    invoke-interface {v1}, Landroid/content/SharedPreferences$Editor;->apply()V

    # Find BhFrameRating in DecorView and apply alpha = progress / 100
    iget-object v0, p0, Lcom/xj/winemu/sidebar/BhHudOpacityListener;->a:Landroid/content/Context;
    check-cast v0, Landroid/app/Activity;
    invoke-virtual {v0}, Landroid/app/Activity;->getWindow()Landroid/view/Window;
    move-result-object v1
    invoke-virtual {v1}, Landroid/view/Window;->getDecorView()Landroid/view/View;
    move-result-object v1
    const-string v2, "bh_frame_rating"
    invoke-virtual {v1, v2}, Landroid/view/View;->findViewWithTag(Ljava/lang/Object;)Landroid/view/View;
    move-result-object v1
    if-eqz v1, :done

    # alpha = progress * 255 / 100 (integer) — background only, text stays opaque
    const/16 v2, 0xFF
    mul-int v2, p2, v2
    const/16 v3, 0x64
    div-int v2, v2, v3
    const/4 v3, 0x0
    invoke-static {v2, v3, v3, v3}, Landroid/graphics/Color;->argb(IIII)I
    move-result v2
    invoke-virtual {v1, v2}, Landroid/view/View;->setBackgroundColor(I)V

    :done
    return-void
.end method

.method public onStartTrackingTouch(Landroid/widget/SeekBar;)V
    .locals 0
    return-void
.end method

.method public onStopTrackingTouch(Landroid/widget/SeekBar;)V
    .locals 0
    return-void
.end method
