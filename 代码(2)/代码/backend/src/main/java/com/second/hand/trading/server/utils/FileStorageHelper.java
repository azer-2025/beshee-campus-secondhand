package com.second.hand.trading.server.utils;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.File;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Component
public class FileStorageHelper {

    @Value("${userFilePath:}")
    private String userFilePath;

    public File resolveUploadDir() {
        List<File> candidateDirs = getCandidateDirs();
        for (File dir : candidateDirs) {
            if (dir.exists() && dir.isDirectory()) {
                return dir;
            }
        }

        for (File dir : candidateDirs) {
            File parent = dir.getAbsoluteFile().getParentFile();
            if (parent == null || parent.exists()) {
                return dir;
            }
        }

        return new File("xmtp");
    }

    public Optional<File> findFile(String fileName) {
        if (fileName == null || fileName.trim().isEmpty()) {
            return Optional.empty();
        }

        for (File dir : getCandidateDirs()) {
            File file = new File(dir, fileName);
            if (file.isFile()) {
                return Optional.of(file);
            }
        }

        return Optional.empty();
    }

    public boolean isManagedImageUrl(String url) {
        return extractImageName(url) != null;
    }

    public boolean imageExistsByUrl(String url) {
        String imageName = extractImageName(url);
        return imageName != null && findFile(imageName).isPresent();
    }

    public String extractImageName(String url) {
        if (url == null || url.trim().isEmpty()) {
            return null;
        }

        String marker = "imageName=";
        int index = url.indexOf(marker);
        if (index < 0) {
            return null;
        }

        String imageName = url.substring(index + marker.length());
        int nextParamIndex = imageName.indexOf('&');
        if (nextParamIndex >= 0) {
            imageName = imageName.substring(0, nextParamIndex);
        }

        imageName = URLDecoder.decode(imageName, StandardCharsets.UTF_8);
        return imageName.trim().isEmpty() ? null : imageName;
    }

    private List<File> getCandidateDirs() {
        Set<String> uniquePaths = new LinkedHashSet<>();
        List<File> dirs = new ArrayList<>();

        addCandidate(dirs, uniquePaths, userFilePath);
        addCandidate(dirs, uniquePaths, "xmtp");
        addCandidate(dirs, uniquePaths, "../xmtp");
        addCandidate(dirs, uniquePaths, "../../xmtp");

        return dirs;
    }

    private void addCandidate(List<File> dirs, Set<String> uniquePaths, String path) {
        if (path == null || path.trim().isEmpty()) {
            return;
        }

        File dir = new File(path);
        String absolutePath = dir.getAbsoluteFile().toURI().normalize().getPath();
        if (uniquePaths.add(absolutePath)) {
            dirs.add(dir);
        }
    }
}
