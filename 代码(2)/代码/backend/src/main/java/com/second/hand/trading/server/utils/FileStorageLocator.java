package com.second.hand.trading.server.utils;

import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;

public final class FileStorageLocator {

    private FileStorageLocator() {
    }

    public static File resolveReadableFile(String configuredPath, String fileName) {
        for (File dir : resolveCandidateDirs(configuredPath)) {
            File file = new File(dir, fileName);
            if (file.isFile()) {
                return file;
            }
        }
        return null;
    }

    public static File resolveWritableDir(String configuredPath) {
        List<File> candidates = resolveCandidateDirs(configuredPath);
        for (File dir : candidates) {
            if (dir.exists() && dir.isDirectory()) {
                return dir;
            }
        }

        for (File dir : resolvePreferredLocalDirs()) {
            if (dir.exists() || dir.mkdirs()) {
                return dir;
            }
        }

        if (hasText(configuredPath)) {
            File configuredDir = new File(configuredPath.trim());
            if (configuredDir.exists() || configuredDir.mkdirs()) {
                return configuredDir;
            }
        }

        return new File("xmtp");
    }

    private static List<File> resolveCandidateDirs(String configuredPath) {
        LinkedHashSet<String> paths = new LinkedHashSet<>();

        if (hasText(configuredPath)) {
            paths.add(new File(configuredPath.trim()).getAbsolutePath());
        }

        for (File dir : resolvePreferredLocalDirs()) {
            paths.add(dir.getAbsolutePath());
        }

        List<File> dirs = new ArrayList<>(paths.size());
        for (String path : paths) {
            dirs.add(new File(path));
        }
        return dirs;
    }

    private static List<File> resolvePreferredLocalDirs() {
        List<File> dirs = new ArrayList<>(2);
        Path userDir = Paths.get(System.getProperty("user.dir", ".")).toAbsolutePath().normalize();
        Path parent = userDir.getParent();
        boolean runningFromBackendModule = userDir.getFileName() != null
                && "backend".equalsIgnoreCase(userDir.getFileName().toString());

        if (runningFromBackendModule && parent != null) {
            dirs.add(parent.resolve("xmtp").toFile());
            dirs.add(userDir.resolve("xmtp").toFile());
            return dirs;
        }

        dirs.add(userDir.resolve("xmtp").toFile());
        if (parent != null) {
            dirs.add(parent.resolve("xmtp").toFile());
        }
        return dirs;
    }

    private static boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
