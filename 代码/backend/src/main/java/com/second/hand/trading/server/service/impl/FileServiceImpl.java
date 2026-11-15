package com.second.hand.trading.server.service.impl;

import com.second.hand.trading.server.service.FileService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;

@Service
public class FileServiceImpl implements FileService {

    @Value("${userFilePath}")
    private String userFilePath;

    public boolean uploadFile(MultipartFile multipartFile,String fileName)throws IOException {
        File fileDir = resolveFileDir();
        if (!fileDir.exists()) {
            if (!fileDir.mkdirs()) {
                return false;
            }
        }
//        System.out.println(fileDir.getAbsolutePath() +"/"+fileName);
        File file = new File(fileDir.getAbsolutePath() +"/"+fileName);
        if (file.exists()) {
            if (!file.delete()) {
                return false;
            }
        }
        if (file.createNewFile()) {
            multipartFile.transferTo(file);
            return true;
        }
        return false;
    }

    private File resolveFileDir() {
        File configuredDir = new File(userFilePath);
        if (configuredDir.exists()) {
            return configuredDir;
        }

        File localDir = new File("xmtp");
        if (localDir.exists()) {
            return localDir;
        }

        File siblingDir = new File("../xmtp");
        if (siblingDir.exists()) {
            return siblingDir;
        }

        return configuredDir;
    }
}
