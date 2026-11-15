package com.second.hand.trading.server.controller;

import com.second.hand.trading.server.enums.ErrorMsg;
import com.second.hand.trading.server.service.IdleItemService;
import com.second.hand.trading.server.service.OrderService;
import com.second.hand.trading.server.service.UserService;
import com.second.hand.trading.server.utils.FileStorageLocator;
import com.second.hand.trading.server.vo.ResultVo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpSession;
import java.io.File;
import java.lang.management.ManagementFactory;
import java.lang.management.RuntimeMXBean;
import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("statistics")
public class StatisticsController {

    @Value("${baseUrl:http://localhost:8080}")
    private String baseUrl;

    @Value("${userFilePath:}")
    private String userFilePath;

    @Value("${spring.datasource.url:}")
    private String datasourceUrl;

    @Value("${server.port:8080}")
    private String serverPort;

    @Autowired
    private IdleItemService idleItemService;

    @Autowired
    private OrderService orderService;

    @Autowired
    private UserService userService;

    /**
     * 获取平台交易数据统计，包括总交易量、总交易额等
     */
    @GetMapping("/trading-data")
    public ResultVo getTradingData(HttpSession session) {
        if (session.getAttribute("admin") == null) {
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }

        Map<String, Object> data = new HashMap<>();
        
        // 获取总交易数
        int totalOrders = orderService.getTotalOrderCount();
        data.put("totalOrders", totalOrders);
        
        // 获取总交易金额
        BigDecimal totalAmount = orderService.getTotalOrderAmount();
        data.put("totalAmount", totalAmount);
        
        // 获取当月交易数
        int currentMonthOrders = orderService.getCurrentMonthOrderCount();
        data.put("currentMonthOrders", currentMonthOrders);
        
        // 获取当月交易金额
        BigDecimal currentMonthAmount = orderService.getCurrentMonthOrderAmount();
        data.put("currentMonthAmount", currentMonthAmount);
        
        return ResultVo.success(data);
    }

    /**
     * 获取过去6个月的交易统计数据
     */
    @GetMapping("/monthly-statistics")
    public ResultVo getMonthlyStatistics(HttpSession session) {
        if (session.getAttribute("admin") == null) {
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }

        List<Map<String, Object>> monthlyData = orderService.getMonthlyOrderStatistics();
        return ResultVo.success(monthlyData);
    }

    /**
     * 获取商品分类统计数据
     */
    @GetMapping("/category-statistics")
    public ResultVo getCategoryStatistics(HttpSession session) {
        if (session.getAttribute("admin") == null) {
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }

        List<Map<String, Object>> categoryData = idleItemService.getCategoryStatistics();
        return ResultVo.success(categoryData);
    }

    /**
     * 获取用户注册统计数据
     */
    @GetMapping("/user-statistics")
    public ResultVo getUserStatistics(HttpSession session) {
        if (session.getAttribute("admin") == null) {
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }

        Map<String, Object> userData = new HashMap<>();
        
        // 获取总用户数
        int totalUsers = userService.getTotalUserCount();
        userData.put("totalUsers", totalUsers);
        
        // 获取本月新增用户数
        int newUsers = userService.getNewUserCount();
        userData.put("newUsers", newUsers);
        
        // 获取活跃用户数（有发布或购买行为的用户）
        int activeUsers = userService.getActiveUserCount();
        userData.put("activeUsers", activeUsers);
        
        return ResultVo.success(userData);
    }

    @GetMapping("/system-config")
    public ResultVo getSystemConfig(HttpSession session) {
        if (session.getAttribute("admin") == null) {
            return ResultVo.fail(ErrorMsg.COOKIE_ERROR);
        }

        RuntimeMXBean runtimeMXBean = ManagementFactory.getRuntimeMXBean();
        File uploadDir = FileStorageLocator.resolveWritableDir(userFilePath);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("appName", "校园二手交易平台 Admin");
        data.put("serverPort", serverPort);
        data.put("baseUrl", baseUrl);
        data.put("uploadDir", uploadDir == null ? "" : uploadDir.getAbsolutePath());
        data.put("datasource", sanitizeDatasourceUrl(datasourceUrl));
        data.put("javaVersion", System.getProperty("java.version"));
        data.put("javaVendor", System.getProperty("java.vendor"));
        data.put("osName", System.getProperty("os.name"));
        data.put("osArch", System.getProperty("os.arch"));
        data.put("timezone", TimeZone.getDefault().getID());
        data.put("userDir", System.getProperty("user.dir"));
        data.put("startTime", new Date(runtimeMXBean.getStartTime()));
        data.put("uptimeMinutes", runtimeMXBean.getUptime() / 60000);
        data.put("availableProcessors", Runtime.getRuntime().availableProcessors());
        data.put("maxMemoryMb", Runtime.getRuntime().maxMemory() / 1024 / 1024);
        data.put("totalMemoryMb", Runtime.getRuntime().totalMemory() / 1024 / 1024);
        data.put("freeMemoryMb", Runtime.getRuntime().freeMemory() / 1024 / 1024);
        return ResultVo.success(data);
    }

    private String sanitizeDatasourceUrl(String url) {
        if (url == null || url.isEmpty()) {
            return "";
        }
        return url.replaceAll("password=[^&]*", "password=******");
    }
} 
