.class public final Lcom/xj/landscape/launcher/ui/menu/WcpExtractor;
.super Ljava/lang/Object;

# Detects WCP (zstd or XZ compressed tar) and ZIP files by magic bytes,
# then extracts them into destDir.
# ZIP -> flat extraction (Turnip/adrenotools)
# zstd tar -> preserve system32/syswow64 (DXVK, VKD3D, Box64) or flattenToRoot if profile.json says FEXCore
# XZ tar -> same logic

.method public static extract(Landroid/content/ContentResolver;Landroid/net/Uri;Ljava/io/File;)V
    .locals 8

    # Clear destDir before injection, then recreate
    invoke-static {p2}, Lcom/xj/landscape/launcher/ui/menu/WcpExtractor;->clearDir(Ljava/io/File;)V
    invoke-virtual {p2}, Ljava/io/File;->mkdirs()Z

    # v0 = byte[4] header
    const/4 v0, 0x4
    new-array v0, v0, [B

    # v1 = InputStream (first open, read header only)
    invoke-virtual {p0, p1}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;
    move-result-object v1

    const/4 v2, 0x0
    const/4 v3, 0x4
    invoke-virtual {v1, v0, v2, v3}, Ljava/io/InputStream;->read([BII)I

    invoke-virtual {v1}, Ljava/io/InputStream;->close()V

    # Load header bytes (sign-extended ints from aget-byte)
    const/4 v2, 0x0
    aget-byte v3, v0, v2
    const/4 v2, 0x1
    aget-byte v4, v0, v2
    const/4 v2, 0x2
    aget-byte v5, v0, v2
    const/4 v2, 0x3
    aget-byte v6, v0, v2

    # Reopen stream for actual extraction
    invoke-virtual {p0, p1}, Landroid/content/ContentResolver;->openInputStream(Landroid/net/Uri;)Ljava/io/InputStream;
    move-result-object v1

    # Check ZIP: 0x50 0x4B 0x03 0x04
    const/16 v2, 0x50
    if-ne v3, v2, :not_zip
    const/16 v2, 0x4B
    if-ne v4, v2, :not_zip
    const/4 v2, 0x3
    if-ne v5, v2, :not_zip
    const/4 v2, 0x4
    if-ne v6, v2, :not_zip

    invoke-static {v1, p2}, Lcom/xj/landscape/launcher/ui/menu/WcpExtractor;->extractZip(Ljava/io/InputStream;Ljava/io/File;)V
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    return-void

    :not_zip
    # Check zstd magic (little-endian): bytes 0x28 0xB5(=-75) 0x2F 0xFD(=-3)
    const/16 v2, 0x28
    if-ne v3, v2, :not_zstd
    const/16 v2, -0x4B
    if-ne v4, v2, :not_zstd
    const/16 v2, 0x2F
    if-ne v5, v2, :not_zstd
    const/4 v2, -0x3
    if-ne v6, v2, :not_zstd

    new-instance v7, Lio/airlift/compress/zstd/ZstdInputStream;
    invoke-direct {v7, v1}, Lio/airlift/compress/zstd/ZstdInputStream;-><init>(Ljava/io/InputStream;)V
    invoke-static {v7, p2}, Lcom/xj/landscape/launcher/ui/menu/WcpExtractor;->extractTar(Ljava/io/InputStream;Ljava/io/File;)V
    invoke-virtual {v7}, Ljava/io/InputStream;->close()V
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    return-void

    :not_zstd
    # Check XZ magic: 0xFD(=-3) 0x37 0x7A 0x58
    const/4 v2, -0x3
    if-ne v3, v2, :unknown_format
    const/16 v2, 0x37
    if-ne v4, v2, :unknown_format
    const/16 v2, 0x7A
    if-ne v5, v2, :unknown_format
    const/16 v2, 0x58
    if-ne v6, v2, :unknown_format

    # Use XZCompressorInputStream from commons-compress (avoids direct tukaani constructor call)
    new-instance v7, Lorg/apache/commons/compress/compressors/xz/XZCompressorInputStream;
    invoke-direct {v7, v1}, Lorg/apache/commons/compress/compressors/xz/XZCompressorInputStream;-><init>(Ljava/io/InputStream;)V
    invoke-static {v7, p2}, Lcom/xj/landscape/launcher/ui/menu/WcpExtractor;->extractTar(Ljava/io/InputStream;Ljava/io/File;)V
    invoke-virtual {v7}, Ljava/io/InputStream;->close()V
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    return-void

    :unknown_format
    invoke-virtual {v1}, Ljava/io/InputStream;->close()V
    new-instance v2, Ljava/lang/Exception;
    const-string v3, "Unknown file format (not ZIP/zstd/XZ)"
    invoke-direct {v2, v3}, Ljava/lang/Exception;-><init>(Ljava/lang/String;)V
    throw v2

.end method

# Recursively delete all contents of dir (but keep dir itself)
.method private static clearDir(Ljava/io/File;)V
    .locals 5

    invoke-virtual {p0}, Ljava/io/File;->listFiles()[Ljava/io/File;
    move-result-object v0
    if-eqz v0, :done

    array-length v1, v0
    const/4 v2, 0x0

    :loop
    if-ge v2, v1, :done
    aget-object v3, v0, v2
    invoke-virtual {v3}, Ljava/io/File;->isDirectory()Z
    move-result v4
    if-eqz v4, :del_file

    # Recurse into subdir, then delete the empty dir
    invoke-static {v3}, Lcom/xj/landscape/launcher/ui/menu/WcpExtractor;->clearDir(Ljava/io/File;)V
    invoke-virtual {v3}, Ljava/io/File;->delete()Z
    goto :next

    :del_file
    invoke-virtual {v3}, Ljava/io/File;->delete()Z

    :next
    add-int/lit8 v2, v2, 0x1
    goto :loop

    :done
    return-void

.end method

# ZIP extraction: flat (just filename, no subdirs) — for Turnip/adrenotools
.method private static extractZip(Ljava/io/InputStream;Ljava/io/File;)V
    .locals 7

    new-instance v0, Ljava/util/zip/ZipInputStream;
    invoke-direct {v0, p0}, Ljava/util/zip/ZipInputStream;-><init>(Ljava/io/InputStream;)V

    const/16 v2, 0x2000
    new-array v2, v2, [B

    :zip_loop
    invoke-virtual {v0}, Ljava/util/zip/ZipInputStream;->getNextEntry()Ljava/util/zip/ZipEntry;
    move-result-object v1
    if-eqz v1, :zip_done

    invoke-virtual {v1}, Ljava/util/zip/ZipEntry;->isDirectory()Z
    move-result v3
    if-nez v3, :zip_skip

    # Flatten: get basename only
    invoke-virtual {v1}, Ljava/util/zip/ZipEntry;->getName()Ljava/lang/String;
    move-result-object v4
    new-instance v5, Ljava/io/File;
    invoke-direct {v5, v4}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v5}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v4

    new-instance v5, Ljava/io/File;
    invoke-direct {v5, p1, v4}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    new-instance v6, Ljava/io/FileOutputStream;
    invoke-direct {v6, v5}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    :zip_read_loop
    invoke-virtual {v0, v2}, Ljava/io/InputStream;->read([B)I
    move-result v3
    if-lez v3, :zip_read_done
    const/4 v4, 0x0
    invoke-virtual {v6, v2, v4, v3}, Ljava/io/OutputStream;->write([BII)V
    goto :zip_read_loop

    :zip_read_done
    invoke-virtual {v6}, Ljava/io/OutputStream;->close()V

    :zip_skip
    invoke-virtual {v0}, Ljava/util/zip/ZipInputStream;->closeEntry()V
    goto :zip_loop

    :zip_done
    invoke-virtual {v0}, Ljava/util/zip/ZipInputStream;->close()V
    return-void

.end method

# Tar extraction (decompressed stream already provided)
# Reads profile.json to detect FEXCore (flattenToRoot).
# FEXCore -> files land at component root.
# Others (DXVK/VKD3D/Box64/Turnip) -> preserve system32/syswow64 structure.
.method private static extractTar(Ljava/io/InputStream;Ljava/io/File;)V
    .locals 11

    # v0 = TarArchiveInputStream
    new-instance v0, Lorg/apache/commons/compress/archivers/tar/TarArchiveInputStream;
    invoke-direct {v0, p0}, Lorg/apache/commons/compress/archivers/tar/TarArchiveInputStream;-><init>(Ljava/io/InputStream;)V

    # v3 = flattenToRoot (0=false)
    const/4 v3, 0x0

    # v4 = buffer
    const/16 v4, 0x2000
    new-array v4, v4, [B

    :tar_loop
    invoke-virtual {v0}, Lorg/apache/commons/compress/archivers/tar/TarArchiveInputStream;->getNextTarEntry()Lorg/apache/commons/compress/archivers/tar/TarArchiveEntry;
    move-result-object v1
    if-eqz v1, :tar_done

    # Skip directories
    invoke-virtual {v1}, Lorg/apache/commons/compress/archivers/tar/TarArchiveEntry;->isDirectory()Z
    move-result v5
    if-nez v5, :tar_loop

    # Get entry name
    invoke-virtual {v1}, Lorg/apache/commons/compress/archivers/tar/TarArchiveEntry;->getName()Ljava/lang/String;
    move-result-object v2

    # Check if this is profile.json (read it to detect FEXCore type)
    const-string v7, "profile.json"
    invoke-virtual {v2, v7}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z
    move-result v7
    if-eqz v7, :not_profile

    # Read profile.json into ByteArrayOutputStream
    new-instance v6, Ljava/io/ByteArrayOutputStream;
    invoke-direct {v6}, Ljava/io/ByteArrayOutputStream;-><init>()V

    :profile_read_loop
    invoke-virtual {v0, v4}, Ljava/io/InputStream;->read([B)I
    move-result v5
    if-lez v5, :profile_read_done
    const/4 v7, 0x0
    invoke-virtual {v6, v4, v7, v5}, Ljava/io/OutputStream;->write([BII)V
    goto :profile_read_loop

    :profile_read_done
    invoke-virtual {v6}, Ljava/io/ByteArrayOutputStream;->toString()Ljava/lang/String;
    move-result-object v8
    const-string v7, "FEXCore"
    invoke-virtual {v8, v7}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v7
    if-eqz v7, :tar_loop
    const/4 v3, 0x1
    goto :tar_loop

    :not_profile
    # Strip leading "./" from entry name
    const-string v7, "./"
    invoke-virtual {v2, v7}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v7
    if-eqz v7, :no_strip
    const/4 v7, 0x2
    invoke-virtual {v2, v7}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v2

    :no_strip
    # Determine dest file based on flattenToRoot
    if-eqz v3, :preserve_path

    # flattenToRoot: use just the basename
    new-instance v9, Ljava/io/File;
    invoke-direct {v9, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V
    invoke-virtual {v9}, Ljava/io/File;->getName()Ljava/lang/String;
    move-result-object v8
    new-instance v9, Ljava/io/File;
    invoke-direct {v9, p1, v8}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    goto :write_entry

    :preserve_path
    # Preserve system32/syswow64 directory structure
    new-instance v9, Ljava/io/File;
    invoke-direct {v9, p1, v2}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V
    invoke-virtual {v9}, Ljava/io/File;->getParentFile()Ljava/io/File;
    move-result-object v8
    if-eqz v8, :write_entry
    invoke-virtual {v8}, Ljava/io/File;->mkdirs()Z

    :write_entry
    new-instance v10, Ljava/io/FileOutputStream;
    invoke-direct {v10, v9}, Ljava/io/FileOutputStream;-><init>(Ljava/io/File;)V

    :write_loop
    invoke-virtual {v0, v4}, Ljava/io/InputStream;->read([B)I
    move-result v5
    if-lez v5, :write_done
    const/4 v7, 0x0
    invoke-virtual {v10, v4, v7, v5}, Ljava/io/OutputStream;->write([BII)V
    goto :write_loop

    :write_done
    invoke-virtual {v10}, Ljava/io/OutputStream;->close()V
    goto :tar_loop

    :tar_done
    invoke-virtual {v0}, Lorg/apache/commons/compress/archivers/tar/TarArchiveInputStream;->close()V
    return-void

.end method
