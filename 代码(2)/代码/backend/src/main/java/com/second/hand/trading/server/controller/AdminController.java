package com.second.hand.trading.server.controller;

import com.second.hand.trading.server.enums.ErrorMsg;
import com.second.hand.trading.server.model.AdminModel;
import com.second.hand.trading.server.model.IdleItemModel;
import com.second.hand.trading.server.model.OrderModel;
import com.second.hand.trading.server.model.UserModel;
import com.second.hand.trading.server.service.AdminService;
import com.second.hand.trading.server.service.IdleItemService;
import com.second.hand.trading.server.service.OrderService;
import com.second.hand.trading.server.service.UserService;
import com.second.hand.trading.server.vo.ResultVo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.util.Date;

@RestController
@RequestMapping("admin")
public class AdminController {

    @Autowired
    private AdminService adminService;

    @Autowired
    private IdleItemService idleItemService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private UserService userService;

    @GetMapping("login")
    public ResultVo login(@RequestParam("accountNumber") @NotNull @NotEmpty String accountNumber,
                          @RequestParam("adminPassword") @NotNull @NotEmpty String adminPassword,
                          HttpSession session){
        AdminModel adminModel=adminService.login(accountNumber,adminPassword);
        if (null == adminModel) {
            return ResultVo.fail(ErrorMsg.EMAIL_LOGIN_ERROR);
        }
        session.setAttribute("admin",adminModel);
        return ResultVo.success(adminModel);
    }

    @GetMapping("loginOut")
    public ResultVo loginOut( HttpSession session){
        session.removeAttribute("admin");
        return ResultVo.success();
    }

    @GetMapping("list")
    public ResultVo getAdminList(HttpSession session,
                                 @RequestParam(value = "page",required = false) Integer page,
                                 @RequestParam(value = "nums",required = false) Integer nums){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        int p=1;
        int n=8;
        if(null!=page){
            p=page>0?page:1;
        }
        if(null!=nums){
            n=nums>0?nums:8;
        }
        return ResultVo.success(adminService.getAdminList(p,n));
    }

    @PostMapping("add")
    public ResultVo addAdmin(HttpSession session,
                             @RequestBody AdminModel adminModel){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if(adminService.addAdmin(adminModel)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.PARAM_ERROR);
    }

    @PostMapping("update")
    public ResultVo updateAdmin(HttpSession session,
                                @RequestBody AdminModel adminModel) {
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if(adminService.updateAdmin(adminModel)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @PostMapping("delete")
    public ResultVo deleteAdmin(HttpSession session,
                                @RequestParam("id") @NotNull Long id){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if(adminService.deleteAdmin(id)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @GetMapping("idleList")
    public ResultVo idleList(HttpSession session,
                             @RequestParam("status") @NotNull Integer status,
                             @RequestParam(value = "page",required = false) Integer page,
                             @RequestParam(value = "nums",required = false) Integer nums){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        int p=1;
        int n=8;
        if(null!=page){
            p=page>0?page:1;
        }
        if(null!=nums){
            n=nums>0?nums:8;
        }
        return ResultVo.success(idleItemService.adminGetIdleList(status,p,n));
    }

    @PostMapping("idle/add")
    public ResultVo addIdle(HttpSession session,
                            @RequestBody IdleItemModel idleItemModel) {
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if (idleItemModel.getReleaseTime() == null) {
            idleItemModel.setReleaseTime(new Date());
        }
        if (idleItemModel.getIdleStatus() == null) {
            idleItemModel.setIdleStatus((byte) 1);
        }
        if(idleItemService.addIdleItem(idleItemModel)){
            return ResultVo.success(idleItemModel);
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @PostMapping("idle/update")
    public ResultVo updateIdle(HttpSession session,
                               @RequestBody IdleItemModel idleItemModel) {
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if(idleItemService.updateIdleItem(idleItemModel)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @GetMapping("updateIdleStatus")
    public ResultVo updateIdleStatus(HttpSession session,
                                     @RequestParam("id") @NotNull Long id,
                                     @RequestParam("status") @NotNull Integer status
                                     ){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        IdleItemModel idleItemModel=new IdleItemModel();
        idleItemModel.setId(id);
        idleItemModel.setIdleStatus(status.byteValue());
        if(idleItemService.updateIdleItem(idleItemModel)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @GetMapping("orderList")
    public ResultVo orderList(HttpSession session,
                              @RequestParam(value = "page",required = false) Integer page,
                              @RequestParam(value = "nums",required = false) Integer nums){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        int p=1;
        int n=8;
        if(null!=page){
            p=page>0?page:1;
        }
        if(null!=nums){
            n=nums>0?nums:8;
        }
        return ResultVo.success(orderService.getAllOrder(p,n));
    }

    @PostMapping("order/add")
    public ResultVo addOrder(HttpSession session,
                             @RequestBody OrderModel orderModel) {
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if (orderModel.getOrderNumber() == null || "".equals(orderModel.getOrderNumber())) {
            orderModel.setOrderNumber(com.second.hand.trading.server.utils.IdFactoryUtil.getOrderId());
        }
        if (orderModel.getCreateTime() == null) {
            orderModel.setCreateTime(new Date());
        }
        if (orderModel.getPaymentStatus() == null) {
            orderModel.setPaymentStatus((byte) 0);
        }
        if (orderModel.getOrderStatus() == null) {
            orderModel.setOrderStatus((byte) 0);
        }
        if (orderModel.getIsDeleted() == null) {
            orderModel.setIsDeleted((byte) 0);
        }
        if (orderModel.getPaymentStatus().equals((byte) 1) && orderModel.getPaymentTime() == null) {
            orderModel.setPaymentTime(new Date());
        }
        if(orderService.addOrder(orderModel)){
            return ResultVo.success(orderModel);
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @PostMapping("order/update")
    public ResultVo updateOrder(HttpSession session,
                                @RequestBody OrderModel orderModel) {
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if (orderModel.getPaymentStatus() != null
                && orderModel.getPaymentStatus().equals((byte) 1)
                && orderModel.getPaymentTime() == null) {
            orderModel.setPaymentTime(new Date());
        }
        if(orderService.updateOrder(orderModel)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @GetMapping("deleteOrder")
    public ResultVo deleteOrder(HttpSession session,
                              @RequestParam("id") @NotNull Long id){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if(orderService.deleteOrder(id)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @GetMapping("userList")
    public ResultVo userList(HttpSession session,
                             @RequestParam(value = "page",required = false) Integer page,
                             @RequestParam(value = "nums",required = false) Integer nums,
                             @RequestParam("status") @NotNull Integer status){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        int p=1;
        int n=8;
        if(null!=page){
            p=page>0?page:1;
        }
        if(null!=nums){
            n=nums>0?nums:8;
        }
        return ResultVo.success(userService.getUserByStatus(status,p,n));
    }

    @PostMapping("user/add")
    public ResultVo addUser(HttpSession session,
                            @RequestBody UserModel userModel) {
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if (userModel.getSignInTime() == null) {
            userModel.setSignInTime(new java.sql.Timestamp(System.currentTimeMillis()));
        }
        if (userModel.getAvatar() == null) {
            userModel.setAvatar("");
        }
        if (userModel.getUserStatus() == null) {
            userModel.setUserStatus((byte) 0);
        }
        if(userService.addUser(userModel)){
            return ResultVo.success(userModel);
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @PostMapping("user/update")
    public ResultVo updateUser(HttpSession session,
                               @RequestBody UserModel userModel) {
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if(userService.updateUserInfo(userModel)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @PostMapping("user/delete")
    public ResultVo deleteUser(HttpSession session,
                               @RequestParam("id") @NotNull Long id) {
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        if(userService.deleteUser(id)){
            return ResultVo.success();
        }
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }

    @GetMapping("updateUserStatus")
    public ResultVo updateUserStatus(HttpSession session,
                                     @RequestParam("id") @NotNull Long id,
                                     @RequestParam("status") @NotNull Integer status){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        UserModel userModel=new UserModel();
        userModel.setId(id);
        userModel.setUserStatus(status.byteValue());
        if(userService.updateUserInfo(userModel))
            return ResultVo.success();
        return ResultVo.fail(ErrorMsg.SYSTEM_ERROR);
    }


    // 按订单闲置物品名称查询
    @GetMapping("queryIdle")
    public ResultVo queryIdle(@RequestParam(value = "findValue",required = false) String findValue,
                              @RequestParam(value = "page",required = false) Integer page,
                              @RequestParam(value = "nums",required = false) Integer nums,
                              @RequestParam("status") @NotNull Integer status){
            if(null==findValue){
                findValue="";
            }
            int p=1;
            int n=8;
            if(null!=page){
                p=page>0?page:1;
            }
            if(null!=nums){
                n=nums>0?nums:8;
            }

        System.out.println(findValue + " " + page + " " + nums + " " + status);

            if(status == 1)
                return ResultVo.success(idleItemService.findIdleItem(findValue,p,n));
            return ResultVo.success(idleItemService.findIdleItem1(findValue,status,p,n));

    }

    // 按订单号查询订单
    @GetMapping("queryOrder")
    public ResultVo queryOrder(HttpSession session,
                              @RequestParam(value = "page",required = false) Integer page,
                              @RequestParam(value = "nums",required = false) Integer nums,
                              @RequestParam(value = "searchValue",required = false) String searchValue){

        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }

        int p=1;
        int n=8;
        if(null!=page){
            p=page>0?page:1;
        }
        if(null!=nums){
            n=nums>0?nums:8;
        }

//        System.out.println("---------------------" + searchValue + "--------------");
        if(null == searchValue || "".equals(searchValue))
            return ResultVo.success(orderService.getAllOrder(p,n));
        return ResultVo.success(orderService.findOrderByNumber(searchValue, p, n));
    }




    // 根据用户账号来查找信息
    @GetMapping("queryUser")
    public ResultVo queryUser(HttpSession session,
                              @RequestParam(value = "searchValue",required = false) String searchValue,
                              @RequestParam(value = "mode",required = false) Integer mode,
                              @RequestParam(value = "page",required = false) Integer page,
                              @RequestParam(value = "nums",required = false) Integer nums){
        if(session.getAttribute("admin")==null){
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }
        int p=1;
        int n=8;
        if(null!=page){
            p=page>0?page:1;
        }
        if(null!=nums){
            n=nums>0?nums:8;
        }
//        return ResultVo.success(userService.getUserByStatus(0,p,n));

        if(mode == 1){
            if(null == searchValue || "".equals(searchValue)){
                return ResultVo.success(userService.getUserByStatus(0,p,n));
            }else{
                return ResultVo.success(userService.getUserByNumber(searchValue,mode));
            }
        }else if(mode == 2){
            if(null == searchValue || "".equals(searchValue)){
                return ResultVo.success(userService.getUserByStatus(1,p,n));
            }else{
                return ResultVo.success(userService.getUserByNumber(searchValue,mode));
            }
        }else
            return ResultVo.success(adminService.getAdminList(p,n));



    }

}
