package com.second.hand.trading.server.service;

import com.second.hand.trading.server.model.AdminModel;
import com.second.hand.trading.server.vo.PageVo;

public interface AdminService {

    AdminModel login(String accountNumber, String adminPassword);

    PageVo<AdminModel> getAdminList(int page, int nums);

    PageVo<AdminModel> queryAdminList(String keyword, int page, int nums);

    boolean addAdmin(AdminModel adminModel);

    boolean updateAdmin(AdminModel adminModel);

    boolean deleteAdmin(Long id);

}
