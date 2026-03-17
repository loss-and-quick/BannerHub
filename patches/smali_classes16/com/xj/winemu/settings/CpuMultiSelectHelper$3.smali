.class final Lcom/xj/winemu/settings/CpuMultiSelectHelper$3;
.super Ljava/lang/Object;
.implements Landroid/content/DialogInterface$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/xj/winemu/settings/CpuMultiSelectHelper;->show(Landroid/view/View;Ljava/lang/String;ILkotlin/jvm/functions/Function1;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

# Negative button ("No Limit") — saves 0 (no CPU affinity).
# Callback NOT invoked (avoids j3 NPE — u0 lambda expects DialogSettingListItemEntity, not View).
.field final synthetic a:Lcom/blankj/utilcode/util/SPUtils;
.field final synthetic b:Ljava/lang/String;

.method constructor <init>(Lcom/blankj/utilcode/util/SPUtils;Ljava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$3;->a:Lcom/blankj/utilcode/util/SPUtils;
    iput-object p2, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$3;->b:Ljava/lang/String;
    return-void
.end method

# onClick(DialogInterface dialog, int which)
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 2

    # Save 0 (No Limit — no CPU affinity)
    iget-object v0, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$3;->a:Lcom/blankj/utilcode/util/SPUtils;
    iget-object v1, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$3;->b:Ljava/lang/String;
    const/4 p2, 0x0
    invoke-virtual {v0, v1, p2}, Lcom/blankj/utilcode/util/SPUtils;->m(Ljava/lang/String;I)V

    return-void
.end method
