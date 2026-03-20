.class public Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;
.super Landroidx/recyclerview/widget/RecyclerView$Adapter;

# RecyclerView adapter for the component list.
# Card layout: colored accent strip | name TextView (flex) | type badge | arrow ›

.field private activity:Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;
.field private allComponents:[Ljava/io/File;
.field private filteredComponents:[Ljava/io/File;

.method public constructor <init>(Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;)V
    .locals 1
    invoke-direct {p0}, Landroidx/recyclerview/widget/RecyclerView$Adapter;-><init>()V
    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->activity:Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;
    const/4 v0, 0x0
    new-array v0, v0, [Ljava/io/File;
    iput-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->allComponents:[Ljava/io/File;
    iput-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->filteredComponents:[Ljava/io/File;
    return-void
.end method

# ── updateComponents(File[]): replace list, clear filter ──────────────────────
.method public updateComponents([Ljava/io/File;)V
    .locals 0
    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->allComponents:[Ljava/io/File;
    iput-object p1, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->filteredComponents:[Ljava/io/File;
    invoke-virtual {p0}, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->notifyDataSetChanged()V
    return-void
.end method

# ── filter(String): rebuild filteredComponents from allComponents ──────────────
.method public filter(Ljava/lang/String;)V
    .locals 8
    # p1 = query string

    if-eqz p1, :reset
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->isEmpty()Z
    move-result v0
    if-nez v0, :reset

    # lowercase query
    invoke-virtual {p1}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v0   # lower query

    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->allComponents:[Ljava/io/File;
    array-length v2, v1

    new-instance v3, Ljava/util/ArrayList;
    invoke-direct {v3}, Ljava/util/ArrayList;-><init>()V

    const/4 v4, 0x0
    :filter_loop
    if-ge v4, v2, :filter_done
    aget-object v5, v1, v4
    invoke-virtual {v5}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v6}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v6
    invoke-virtual {v6, v0}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v7
    if-eqz v7, :filter_skip
    invoke-interface {v3, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :filter_skip
    add-int/lit8 v4, v4, 0x1
    goto :filter_loop

    :filter_done
    invoke-interface {v3}, Ljava/util/Collection;->size()I
    move-result v4
    new-array v5, v4, [Ljava/io/File;
    invoke-interface {v3, v5}, Ljava/util/Collection;->toArray([Ljava/lang/Object;)[Ljava/lang/Object;
    move-result-object v5
    check-cast v5, [Ljava/io/File;
    iput-object v5, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->filteredComponents:[Ljava/io/File;
    invoke-virtual {p0}, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->notifyDataSetChanged()V
    return-void

    :reset
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->allComponents:[Ljava/io/File;
    iput-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->filteredComponents:[Ljava/io/File;
    invoke-virtual {p0}, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->notifyDataSetChanged()V
    return-void
.end method

# ── getFiltered(int): return filteredComponents[pos] ──────────────────────────
.method public getFiltered(I)Ljava/io/File;
    .locals 1
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->filteredComponents:[Ljava/io/File;
    aget-object v0, v0, p1
    return-object v0
.end method

# ── getItemCount() ────────────────────────────────────────────────────────────
.method public getItemCount()I
    .locals 1
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->filteredComponents:[Ljava/io/File;
    array-length v0, v0
    return v0
.end method

# ── onItemTapped(int adapterPos): find real index in allComponents, show dialog
.method public onItemTapped(I)V
    .locals 5
    # p1 = adapter position in filteredComponents
    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->filteredComponents:[Ljava/io/File;
    aget-object v0, v0, p1    # filteredFile

    # find index in allComponents
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->allComponents:[Ljava/io/File;
    array-length v2, v1
    const/4 v3, 0x0
    const/4 v4, 0x0

    :find_loop
    if-ge v3, v2, :find_done
    aget-object v4, v1, v3
    invoke-virtual {v4, v0}, Ljava/lang/Object;->equals(Ljava/lang/Object;)Z
    move-result v4
    if-nez v4, :found
    add-int/lit8 v3, v3, 0x1
    goto :find_loop

    :found
    # v3 = real index
    :find_done
    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->activity:Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;
    invoke-virtual {v1, v3}, Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;->showOptionsDialog(I)V
    return-void
.end method

# ── getTypeName(String name) ──────────────────────────────────────────────────
.method public static getTypeName(Ljava/lang/String;)Ljava/lang/String;
    .locals 2
    invoke-virtual {p0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;
    move-result-object v0

    const-string v1, "dxvk"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-eqz v1, :not_dxvk
    const-string v1, "DXVK"
    return-object v1

    :not_dxvk
    const-string v1, "vkd3d"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-eqz v1, :not_vkd3d
    const-string v1, "VKD3D"
    return-object v1

    :not_vkd3d
    const-string v1, "box64"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-eqz v1, :not_box64
    const-string v1, "Box64"
    return-object v1

    :not_box64
    const-string v1, "fex"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-eqz v1, :not_fex
    const-string v1, "FEX"
    return-object v1

    :not_fex
    const-string v1, "turnip"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :is_gpu
    const-string v1, "vulkan"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :is_gpu
    const-string v1, "adreno"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :is_gpu
    const-string v1, "driver"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-nez v1, :is_gpu
    const-string v1, "gpu"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-eqz v1, :not_gpu

    :is_gpu
    const-string v1, "GPU"
    return-object v1

    :not_gpu
    const-string v1, "WCP"
    return-object v1
.end method

# ── getTypeColor(String typeName) ─────────────────────────────────────────────
.method public static getTypeColor(Ljava/lang/String;)I
    .locals 1
    const-string v0, "DXVK"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :not_dxvk
    const v0, 0xFF4D8FFF
    return v0

    :not_dxvk
    const-string v0, "VKD3D"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :not_vkd3d
    const v0, 0xFF9B59B6
    return v0

    :not_vkd3d
    const-string v0, "Box64"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :not_box64
    const v0, 0xFF47B24F
    return v0

    :not_box64
    const-string v0, "FEX"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :not_fex
    const v0, 0xFFE67E22
    return v0

    :not_fex
    const-string v0, "GPU"
    invoke-virtual {p0, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :not_gpu
    const v0, 0xFFF0C140
    return v0

    :not_gpu
    const v0, 0xFF888E99
    return v0
.end method

# ── onCreateViewHolder: build card view programmatically ──────────────────────
.method public onCreateViewHolder(Landroid/view/ViewGroup;I)Landroidx/recyclerview/widget/RecyclerView$ViewHolder;
    .locals 15

    invoke-virtual {p1}, Landroid/view/View;->getContext()Landroid/content/Context;
    move-result-object v0   # ctx

    iget-object v1, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->activity:Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;

    # dp helper via activity.dp(N)
    # v2 = 4dp, v3 = 8dp, v4 = 12dp, v5 = 36dp

    const/4 v14, 0x4
    invoke-virtual {v1, v14}, Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;->dp(I)I
    move-result v2    # 4dp px

    const/4 v14, 0x8
    invoke-virtual {v1, v14}, Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;->dp(I)I
    move-result v3    # 8dp px

    const/16 v14, 0xc
    invoke-virtual {v1, v14}, Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;->dp(I)I
    move-result v4    # 12dp px

    const/16 v14, 0x24
    invoke-virtual {v1, v14}, Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;->dp(I)I
    move-result v5    # 36dp px

    # ── Outer card: horizontal LinearLayout ───────────────────────────────────
    new-instance v6, Landroid/widget/LinearLayout;
    invoke-direct {v6, v0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v14, 0x0
    invoke-virtual {v6, v14}, Landroid/widget/LinearLayout;->setOrientation(I)V      # HORIZONTAL
    const/16 v14, 0x10
    invoke-virtual {v6, v14}, Landroid/widget/LinearLayout;->setGravity(I)V          # CENTER_VERTICAL

    # Card background: dark rounded rect
    new-instance v7, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v7}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    const v14, 0xFF252535
    invoke-virtual {v7, v14}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V
    int-to-float v14, v3    # 8dp as float for corner radius
    invoke-virtual {v7, v14}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v6, v7}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    # Card padding: 12dp all sides
    invoke-virtual {v6, v4, v4, v4, v4}, Landroid/widget/LinearLayout;->setPadding(IIII)V

    # Card layout params: MATCH_PARENT width, WRAP_CONTENT height, margins 12/4/12/4
    new-instance v7, Landroid/widget/LinearLayout$LayoutParams;
    const/4 v14, -0x1   # MATCH_PARENT
    const/4 v13, -0x2   # WRAP_CONTENT
    invoke-direct {v7, v14, v13}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v7, v4, v2, v4, v2}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v6, v7}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    # ── Accent strip (left colored bar) ──────────────────────────────────────
    new-instance v8, Landroid/view/View;
    invoke-direct {v8, v0}, Landroid/view/View;-><init>(Landroid/content/Context;)V

    # GradientDrawable for accent (stored in ViewHolder to change color in onBind)
    new-instance v9, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v9}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    int-to-float v14, v2    # 4dp corner radius
    invoke-virtual {v9, v14}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v8, v9}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V

    # Strip layout: 4dp wide, 36dp tall, right margin 12dp
    new-instance v7, Landroid/widget/LinearLayout$LayoutParams;
    invoke-direct {v7, v2, v5}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v7, v14, v14, v4, v14}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v6, v8, v7}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    # ── Text column: vertical LinearLayout (flex) ─────────────────────────────
    new-instance v10, Landroid/widget/LinearLayout;
    invoke-direct {v10, v0}, Landroid/widget/LinearLayout;-><init>(Landroid/content/Context;)V
    const/4 v14, 0x1
    invoke-virtual {v10, v14}, Landroid/widget/LinearLayout;->setOrientation(I)V    # VERTICAL

    # ── Name TextView ─────────────────────────────────────────────────────────
    new-instance v11, Landroid/widget/TextView;
    invoke-direct {v11, v0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const/high16 v14, 0x41700000    # 15.0f sp
    invoke-virtual {v11, v14}, Landroid/widget/TextView;->setTextSize(F)V
    const v14, 0xFFFFFFFF
    invoke-virtual {v11, v14}, Landroid/widget/TextView;->setTextColor(I)V
    const/4 v14, 0x1
    invoke-virtual {v11, v14}, Landroid/widget/TextView;->setMaxLines(I)V
    sget-object v14, Landroid/text/TextUtils$TruncateAt;->END:Landroid/text/TextUtils$TruncateAt;
    invoke-virtual {v11, v14}, Landroid/widget/TextView;->setEllipsize(Landroid/text/TextUtils$TruncateAt;)V

    invoke-virtual {v10, v11}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ── Type badge TextView ───────────────────────────────────────────────────
    new-instance v12, Landroid/widget/TextView;
    invoke-direct {v12, v0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const/high16 v14, 0x41300000    # 11.0f sp
    invoke-virtual {v12, v14}, Landroid/widget/TextView;->setTextSize(F)V
    # Badge background GradientDrawable (stored in ViewHolder)
    new-instance v13, Landroid/graphics/drawable/GradientDrawable;
    invoke-direct {v13}, Landroid/graphics/drawable/GradientDrawable;-><init>()V
    int-to-float v14, v2
    invoke-virtual {v13, v14}, Landroid/graphics/drawable/GradientDrawable;->setCornerRadius(F)V
    invoke-virtual {v12, v13}, Landroid/view/View;->setBackground(Landroid/graphics/drawable/Drawable;)V
    # Badge padding: 6/2/6/2
    const/16 v14, 0x6
    invoke-virtual {v1, v14}, Lcom/xj/landscape/launcher/ui/menu/ComponentManagerActivity;->dp(I)I
    move-result v14
    invoke-virtual {v12, v14, v2, v14, v2}, Landroid/widget/TextView;->setPadding(IIII)V
    # Top margin 4dp on badge
    new-instance v7, Landroid/widget/LinearLayout$LayoutParams;
    const/4 p2, -0x2    # WRAP_CONTENT
    invoke-direct {v7, p2, p2}, Landroid/widget/LinearLayout$LayoutParams;-><init>(II)V
    invoke-virtual {v7, v14, v3, v14, v14}, Landroid/widget/LinearLayout$LayoutParams;->setMargins(IIII)V
    invoke-virtual {v10, v12, v7}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    # Add text column to card with weight=1
    new-instance v7, Landroid/widget/LinearLayout$LayoutParams;
    const/4 p2, 0x0
    const/4 v14, -0x2   # WRAP_CONTENT
    const/high16 v15, 0x3f800000  # 1.0f
    invoke-direct {v7, p2, v14, v15}, Landroid/widget/LinearLayout$LayoutParams;-><init>(IIF)V
    invoke-virtual {v6, v10, v7}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;Landroid/view/ViewGroup$LayoutParams;)V

    # ── Arrow TextView ────────────────────────────────────────────────────────
    new-instance v7, Landroid/widget/TextView;
    invoke-direct {v7, v0}, Landroid/widget/TextView;-><init>(Landroid/content/Context;)V
    const-string v14, "\u203a"
    invoke-virtual {v7, v14}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    const/high16 v14, 0x41a00000    # 20.0f sp
    invoke-virtual {v7, v14}, Landroid/widget/TextView;->setTextSize(F)V
    const v14, 0xFF666666
    invoke-virtual {v7, v14}, Landroid/widget/TextView;->setTextColor(I)V
    invoke-virtual {v6, v7}, Landroid/widget/LinearLayout;->addView(Landroid/view/View;)V

    # ── Wrap card in a FrameLayout for full-width swipe hit area ──────────────
    # Actually just use the LinearLayout itself; RecyclerView wraps it.
    # Set MATCH_PARENT width explicitly so swipe covers full row.
    new-instance v7, Landroidx/recyclerview/widget/RecyclerView$LayoutParams;
    const/4 v14, -0x1
    const/4 p2, -0x2
    invoke-direct {v7, v14, p2}, Landroidx/recyclerview/widget/RecyclerView$LayoutParams;-><init>(II)V
    invoke-virtual {v6, v7}, Landroid/view/View;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    # ── Create and return ViewHolder ──────────────────────────────────────────
    new-instance v7, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter$ViewHolder;
    invoke-direct/range {v7 .. v13}, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter$ViewHolder;-><init>(Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;Landroid/view/View;Landroid/view/View;Landroid/widget/TextView;Landroid/widget/TextView;Landroid/graphics/drawable/GradientDrawable;)V
    return-object v7
.end method

# ── onBindViewHolder ──────────────────────────────────────────────────────────
.method public onBindViewHolder(Landroidx/recyclerview/widget/RecyclerView$ViewHolder;I)V
    .locals 6
    # p1=ViewHolder  p2=position
    check-cast p1, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter$ViewHolder;

    iget-object v0, p0, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->filteredComponents:[Ljava/io/File;
    aget-object v0, v0, p2    # File at position

    invoke-virtual {v0}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v1    # name

    invoke-static {v1}, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->getTypeName(Ljava/lang/String;)Ljava/lang/String;
    move-result-object v2    # typeName

    invoke-static {v2}, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter;->getTypeColor(Ljava/lang/String;)I
    move-result v3    # typeColor

    # Set name
    iget-object v4, p1, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter$ViewHolder;->nameText:Landroid/widget/TextView;
    invoke-virtual {v4, v1}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    # Set type badge text + color
    iget-object v4, p1, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter$ViewHolder;->typeBadge:Landroid/widget/TextView;
    invoke-virtual {v4, v2}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V
    invoke-virtual {v4, v3}, Landroid/widget/TextView;->setTextColor(I)V

    # Badge background: type color at 25% alpha
    and-int/lit16 v5, v3, 0xFFFF
    int-to-long v5, v5   # nope - just bit ops
    # (typeColor & 0x00FFFFFF) | 0x33000000
    const v5, 0x00FFFFFF
    and-int/2addr v5, v3
    const v4, 0x33000000
    or-int/2addr v5, v4
    iget-object v4, p1, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter$ViewHolder;->badgeBg:Landroid/graphics/drawable/GradientDrawable;
    invoke-virtual {v4, v5}, Landroid/graphics/drawable/GradientDrawable;->setColor(I)V

    # Accent strip color
    iget-object v4, p1, Lcom/xj/landscape/launcher/ui/menu/BhComponentAdapter$ViewHolder;->accentStrip:Landroid/view/View;
    invoke-virtual {v4, v3}, Landroid/view/View;->setBackgroundColor(I)V

    return-void
.end method
