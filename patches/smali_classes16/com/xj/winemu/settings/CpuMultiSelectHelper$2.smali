.class final Lcom/xj/winemu/settings/CpuMultiSelectHelper$2;
.super Ljava/lang/Object;
.implements Landroid/content/DialogInterface$OnClickListener;

.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/xj/winemu/settings/CpuMultiSelectHelper;->show(Landroid/view/View;Ljava/lang/String;ILkotlin/jvm/functions/Function1;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation

# Positive button ("Apply") — computes bitmask from checked[], saves via SPUtils.
# Callback NOT invoked (avoids j3 NPE — u0 lambda expects DialogSettingListItemEntity, not View).
.field final synthetic a:[Z
.field final synthetic b:Lcom/blankj/utilcode/util/SPUtils;
.field final synthetic c:Ljava/lang/String;

.method constructor <init>([ZLcom/blankj/utilcode/util/SPUtils;Ljava/lang/String;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$2;->a:[Z
    iput-object p2, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$2;->b:Lcom/blankj/utilcode/util/SPUtils;
    iput-object p3, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$2;->c:Ljava/lang/String;
    return-void
.end method

# onClick(DialogInterface dialog, int which)
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3

    iget-object v0, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$2;->a:[Z
    const/4 v1, 0x0    # newMask = 0

    # Core 0 (mask = 1)
    const/4 v2, 0x0
    aget-boolean v2, v0, v2
    if-eqz v2, :cond_s0
    const/4 v2, 0x1
    or-int/2addr v1, v2
    :cond_s0

    # Core 1 (mask = 2)
    const/4 v2, 0x1
    aget-boolean v2, v0, v2
    if-eqz v2, :cond_s1
    const/4 v2, 0x2
    or-int/2addr v1, v2
    :cond_s1

    # Core 2 (mask = 4)
    const/4 v2, 0x2
    aget-boolean v2, v0, v2
    if-eqz v2, :cond_s2
    const/4 v2, 0x4
    or-int/2addr v1, v2
    :cond_s2

    # Core 3 (mask = 8)
    const/4 v2, 0x3
    aget-boolean v2, v0, v2
    if-eqz v2, :cond_s3
    const/16 v2, 0x8
    or-int/2addr v1, v2
    :cond_s3

    # Core 4 (mask = 16 = 0x10)
    const/4 v2, 0x4
    aget-boolean v2, v0, v2
    if-eqz v2, :cond_s4
    const/16 v2, 0x10
    or-int/2addr v1, v2
    :cond_s4

    # Core 5 (mask = 32 = 0x20)
    const/4 v2, 0x5
    aget-boolean v2, v0, v2
    if-eqz v2, :cond_s5
    const/16 v2, 0x20
    or-int/2addr v1, v2
    :cond_s5

    # Core 6 (mask = 64 = 0x40)
    const/4 v2, 0x6
    aget-boolean v2, v0, v2
    if-eqz v2, :cond_s6
    const/16 v2, 0x40
    or-int/2addr v1, v2
    :cond_s6

    # Core 7 (mask = 128 = 0x80)
    const/4 v2, 0x7
    aget-boolean v2, v0, v2
    if-eqz v2, :cond_s7
    const/16 v2, 0x80
    or-int/2addr v1, v2
    :cond_s7

    # Save: sputils.m(key, newMask)
    iget-object v0, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$2;->b:Lcom/blankj/utilcode/util/SPUtils;
    iget-object v2, p0, Lcom/xj/winemu/settings/CpuMultiSelectHelper$2;->c:Ljava/lang/String;
    invoke-virtual {v0, v2, v1}, Lcom/blankj/utilcode/util/SPUtils;->m(Ljava/lang/String;I)V

    return-void
.end method
