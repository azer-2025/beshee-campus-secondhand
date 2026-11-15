package com.second.hand.trading.server.service.impl;

import com.second.hand.trading.server.dao.AdminDao;
import com.second.hand.trading.server.model.AdminModel;
import com.second.hand.trading.server.service.AdminService;
import com.second.hand.trading.server.vo.PageVo;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jakarta.annotation.Resource;
import java.util.List;

@Service
public class AdminServiceImpl implements AdminService {

    @Resource
    private AdminDao adminDao;

    public AdminModel login(String accountNumber, String adminPassword){
        return adminDao.login(accountNumber,adminPassword);
    }

    public PageVo<AdminModel> getAdminList(int page, int nums){
        List<AdminModel> list=adminDao.getList((page-1)*nums,nums);
        int count=adminDao.getCount();
        return new PageVo<>(list,count);
    }

    public boolean addAdmin(AdminModel adminModel){
        if (adminModel == null
                || !StringUtils.hasText(adminModel.getAccountNumber())
                || !StringUtils.hasText(adminModel.getAdminPassword())
                || !StringUtils.hasText(adminModel.getAdminName())) {
            return false;
        }
        if (adminDao.findByAccountNumber(adminModel.getAccountNumber()) != null) {
            return false;
        }
        return adminDao.insert(adminModel)==1;
    }

    @Override
    public PageVo<AdminModel> queryAdminList(String keyword, int page, int nums) {
        if (!StringUtils.hasText(keyword)) {
            return getAdminList(page, nums);
        }

        String searchKeyword = keyword.trim();
        List<AdminModel> list = adminDao.searchList(searchKeyword, (page - 1) * nums, nums);
        int count = adminDao.searchCount(searchKeyword);
        return new PageVo<>(list, count);
    }

    @Override
    public boolean updateAdmin(AdminModel adminModel) {
        if (adminModel == null || adminModel.getId() == null) {
            return false;
        }

        AdminModel currentAdmin = adminDao.selectByPrimaryKey(adminModel.getId());
        if (currentAdmin == null) {
            return false;
        }

        if (StringUtils.hasText(adminModel.getAccountNumber())) {
            AdminModel existingAdmin = adminDao.findByAccountNumber(adminModel.getAccountNumber().trim());
            if (existingAdmin != null && !existingAdmin.getId().equals(adminModel.getId())) {
                return false;
            }
            adminModel.setAccountNumber(adminModel.getAccountNumber().trim());
        } else {
            adminModel.setAccountNumber(null);
        }

        if (StringUtils.hasText(adminModel.getAdminName())) {
            adminModel.setAdminName(adminModel.getAdminName().trim());
        } else {
            adminModel.setAdminName(null);
        }

        if (!StringUtils.hasText(adminModel.getAdminPassword())) {
            adminModel.setAdminPassword(null);
        } else {
            adminModel.setAdminPassword(adminModel.getAdminPassword().trim());
        }

        return adminDao.updateByPrimaryKeySelective(adminModel) == 1;
    }

    @Override
    public boolean deleteAdmin(Long id) {
        if (id == null || adminDao.selectByPrimaryKey(id) == null) {
            return false;
        }
        return adminDao.deleteByPrimaryKey(id) == 1;
    }

}
