/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80026
 Source Host           : localhost:3306
 Source Schema         : second_hand_trading

 Target Server Type    : MySQL
 Target Server Version : 80026
 File Encoding         : 65001

 Date: 08/03/2026 14:45:46
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for sh_address
-- ----------------------------
DROP TABLE IF EXISTS `sh_address`;
CREATE TABLE `sh_address`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `consignee_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '收货人姓名',
  `consignee_phone` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '收货人手机号',
  `province_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '省',
  `city_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '市',
  `region_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '区',
  `detail_address` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '详细地址',
  `default_flag` tinyint NOT NULL COMMENT '是否默认地址',
  `user_id` bigint NOT NULL COMMENT '用户主键id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id_index`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 41 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '地址表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sh_address
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for sh_admin
-- ----------------------------
DROP TABLE IF EXISTS `sh_admin`;
CREATE TABLE `sh_admin`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `account_number` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '管理员账号',
  `admin_password` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '密码',
  `admin_name` varchar(8) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '管理员名字',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `account_number`(`account_number` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '管理员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sh_admin
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for sh_favorite
-- ----------------------------
DROP TABLE IF EXISTS `sh_favorite`;
CREATE TABLE `sh_favorite`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键id',
  `create_time` datetime NOT NULL COMMENT '加入收藏的时间',
  `user_id` bigint NOT NULL COMMENT '用户主键id',
  `idle_id` bigint NOT NULL COMMENT '闲置物主键id',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC, `idle_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 62 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '收藏信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sh_favorite
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for sh_idle_item
-- ----------------------------
DROP TABLE IF EXISTS `sh_idle_item`;
CREATE TABLE `sh_idle_item`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `idle_name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '闲置物名称',
  `idle_details` varchar(2048) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '详情',
  `picture_list` varchar(1024) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '图集',
  `idle_price` decimal(10, 2) NOT NULL COMMENT '价格',
  `idle_place` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '发货地区',
  `idle_label` int NOT NULL COMMENT '分类标签',
  `release_time` datetime NOT NULL COMMENT '发布时间',
  `idle_status` tinyint NOT NULL COMMENT '状态（发布1、下架2、删除0）',
  `user_id` bigint NOT NULL COMMENT '用户主键id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id_index`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 189 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '二手商品表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sh_idle_item
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for sh_message
-- ----------------------------
DROP TABLE IF EXISTS `sh_message`;
CREATE TABLE `sh_message`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `user_id` bigint NOT NULL COMMENT '用户主键id',
  `idle_id` bigint NOT NULL COMMENT '闲置主键id',
  `content` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '留言内容',
  `create_time` datetime NOT NULL COMMENT '留言时间',
  `to_user` bigint NOT NULL COMMENT '所回复的用户',
  `to_message` bigint NULL DEFAULT NULL COMMENT '所回复的留言',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id_index`(`user_id` ASC) USING BTREE,
  INDEX `idle_id_index`(`idle_id` ASC) USING BTREE,
  INDEX `to_user_index`(`to_user` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 57 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '留言表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sh_message
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for sh_order
-- ----------------------------
DROP TABLE IF EXISTS `sh_order`;
CREATE TABLE `sh_order`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `order_number` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '订单编号',
  `user_id` bigint NOT NULL COMMENT '用户主键id',
  `idle_id` bigint NOT NULL COMMENT '闲置物品主键id',
  `order_price` decimal(10, 2) NOT NULL COMMENT '订单总价',
  `payment_status` tinyint NOT NULL COMMENT '支付状态',
  `payment_way` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '支付方式',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `payment_time` datetime NULL DEFAULT NULL COMMENT '支付时间',
  `order_status` tinyint NOT NULL COMMENT '订单状态',
  `is_deleted` tinyint NULL DEFAULT NULL COMMENT '是否删除',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 144 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '订单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sh_order
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for sh_order_address
-- ----------------------------
DROP TABLE IF EXISTS `sh_order_address`;
CREATE TABLE `sh_order_address`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `order_id` bigint NOT NULL COMMENT '订单id',
  `consignee_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '收货人',
  `consignee_phone` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '电话',
  `detail_address` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '收货地址',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `orderId`(`order_id` ASC) USING BTREE,
  INDEX `order_id_index`(`order_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 126 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '订单地址表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sh_order_address
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- ----------------------------
-- Table structure for sh_user
-- ----------------------------
DROP TABLE IF EXISTS `sh_user`;
CREATE TABLE `sh_user`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `account_number` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '账号（手机号）',
  `user_password` varchar(16) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '登录密码',
  `nickname` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '昵称',
  `avatar` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '头像',
  `sign_in_time` datetime NOT NULL COMMENT '注册时间',
  `user_status` tinyint NULL DEFAULT NULL COMMENT '状态（1代表封禁）',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `account_number`(`account_number` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 44 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sh_user
-- ----------------------------

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


SET FOREIGN_KEY_CHECKS = 1;

START TRANSACTION;

ALTER TABLE `sh_idle_item` COMMENT = '二手手机表';

UPDATE `sh_idle_item`
SET
    `idle_name` = CASE `id`
                      WHEN 85 THEN 'iPhone 12 128G'
                      WHEN 89 THEN 'Redmi K70 12+256G'
                      WHEN 90 THEN '一加 12 16+512G'
                      WHEN 91 THEN 'iPhone 14 Plus 128G'
                      WHEN 95 THEN 'iPhone XR 64G'
                      WHEN 96 THEN 'Redmi Note 12 Turbo'
                      WHEN 97 THEN 'OPPO Reno10 12+256G'
                      WHEN 101 THEN '红魔 8 Pro'
                      WHEN 102 THEN '苹果 20W 快充头'
                      WHEN 103 THEN '华为 66W 超级快充'
                      WHEN 106 THEN '三星 S23 8+256G'
                      WHEN 108 THEN 'iQOO Neo9 12+256G'
                      WHEN 109 THEN '荣耀 Magic V2'
                      WHEN 111 THEN 'vivo X100 12+256G'
                      WHEN 112 THEN '小米 MIX Fold 3'
                      WHEN 115 THEN '一加 Ace 3'
                      WHEN 135 THEN 'iPhone 11 128G'
                      WHEN 136 THEN 'iPhone 13 128G'
                      WHEN 137 THEN 'iPhone 13 mini'
                      WHEN 141 THEN '华为 Mate X5'
                      WHEN 142 THEN '三星 Z Flip5'
                      WHEN 143 THEN '魅族 20 Pro'
                      WHEN 149 THEN '荣耀 Magic6'
                      WHEN 150 THEN 'iPhone 14 Pro'
                      WHEN 151 THEN 'ROG 游戏手机 6'
                      WHEN 172 THEN '手机壳套装'
                      WHEN 173 THEN '蓝牙耳机'
                      WHEN 175 THEN '20000mAh 充电宝'
                      WHEN 176 THEN '小米 14'
                      WHEN 177 THEN '华为 nova 12'
                      WHEN 178 THEN '华为 Mate 60'
                      WHEN 179 THEN 'iPhone 15 128G'
                      WHEN 184 THEN '三星 S22 8+128G'
                      WHEN 188 THEN '苹果原装数据线'
                      ELSE `idle_name`
        END,
    `idle_details` = CASE `id`
                         WHEN 85 THEN '国行，128G，面容与摄像头正常，电池健康 86%，日常使用稳定。'
                         WHEN 89 THEN '12+256G，骁龙旗舰芯片，屏幕无暗病，机身轻微使用痕迹。'
                         WHEN 90 THEN '一加旗舰机，16+512G，大内存版本，成色很好，支持线下验机。'
                         WHEN 91 THEN '自用 iPhone 14 Plus，128G，电池健康优秀，箱说齐全。'
                         WHEN 95 THEN '备用机出掉，64G，系统流畅，适合当副机或学生机。'
                         WHEN 96 THEN '国补后换新机，这台转卖，性能强，续航不错。'
                         WHEN 97 THEN '12+256G，外观完整，屏幕和拍照功能均正常。'
                         WHEN 101 THEN '红魔游戏手机，散热和高刷表现好，适合手游玩家。'
                         WHEN 102 THEN '苹果原装 20W 快充头，成色新，支持 iPhone 快充。'
                         WHEN 103 THEN '华为原装超级快充头，支持多机型，充电稳定。'
                         WHEN 106 THEN '三星旗舰小屏机，8+256G，屏幕显示优秀，适合日常主力机。'
                         WHEN 108 THEN 'iQOO Neo9，自用少，性能均衡，适合学生党。'
                         WHEN 109 THEN '荣耀折叠屏，展开体验好，内外屏使用正常。'
                         WHEN 111 THEN 'vivo 影像旗舰，外观成色新，镜头无磕碰。'
                         WHEN 112 THEN '小米折叠屏，商务办公和大屏娱乐都合适。'
                         WHEN 115 THEN '一加 Ace 系列，充电快，屏幕亮度高，成色不错。'
                         WHEN 135 THEN 'iPhone 11 128G，适合预算有限但想体验 iOS 的用户。'
                         WHEN 136 THEN 'iPhone 13，单卡正常，电池续航稳定，支持当面试机。'
                         WHEN 137 THEN '小尺寸 iPhone，轻便好握持，适合女生或备用机。'
                         WHEN 141 THEN '华为 Mate X5 折叠屏，屏幕和转轴状态良好。'
                         WHEN 142 THEN '三星 Z Flip5，小折叠机型，拍照和外观都很在线。'
                         WHEN 143 THEN '魅族旗舰机，屏幕细腻，系统干净，适合日常使用。'
                         WHEN 149 THEN '荣耀新款旗舰，成色新，配置均衡，支持验机。'
                         WHEN 150 THEN 'iPhone 14 Pro，拍照强，外观新，电池表现稳定。'
                         WHEN 151 THEN 'ROG 游戏手机，适合高帧率手游，散热不错。'
                         WHEN 172 THEN '多款透明壳和磁吸壳一起出，适配主流机型。'
                         WHEN 173 THEN '蓝牙耳机，连接稳定，适合手机日常通勤使用。'
                         WHEN 175 THEN '容量足，支持手机快充，出门备用很方便。'
                         WHEN 176 THEN '小米新款旗舰，徕卡影像，整机状态良好。'
                         WHEN 177 THEN '华为 nova 系列，适合日常使用和自拍。'
                         WHEN 178 THEN '华为旗舰直板机，麒麟芯片，商务和日常都合适。'
                         WHEN 179 THEN 'iPhone 15 标准版，128G，机器无拆修。'
                         WHEN 184 THEN '三星上一代旗舰，屏幕和系统都很稳定。'
                         WHEN 188 THEN '苹果原装线，接口正常，无破损。'
                         ELSE `idle_details`
        END,
    `picture_list` = CASE `id`
                         WHEN 85 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 89 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 90 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 91 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 95 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 96 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 97 THEN '["http://localhost:8080/image?imageName=file16524438710431016156.jpg"]'
                         WHEN 101 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 102 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 103 THEN '["http://localhost:8080/image?imageName=file1652443963449101813.jpg"]'
                         WHEN 106 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 108 THEN '["http://localhost:8080/image?imageName=file16524438710431016156.jpg"]'
                         WHEN 109 THEN '["http://localhost:8080/image?imageName=file1652443963449101813.jpg"]'
                         WHEN 111 THEN '["http://localhost:8080/image?imageName=file16524438710431016156.jpg"]'
                         WHEN 112 THEN '["http://localhost:8080/image?imageName=file1652443963449101813.jpg"]'
                         WHEN 115 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 135 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 136 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 137 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 141 THEN '["http://localhost:8080/image?imageName=file1652443963449101813.jpg"]'
                         WHEN 142 THEN '["http://localhost:8080/image?imageName=file1652443963449101813.jpg"]'
                         WHEN 143 THEN '["http://localhost:8080/image?imageName=file16524438710431016156.jpg"]'
                         WHEN 149 THEN '["http://localhost:8080/image?imageName=file16524438710431016156.jpg"]'
                         WHEN 150 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 151 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 172 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 173 THEN '["http://localhost:8080/image?imageName=file16524438710431016156.jpg"]'
                         WHEN 175 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 176 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 177 THEN '["http://localhost:8080/image?imageName=file16524438710431016156.jpg"]'
                         WHEN 178 THEN '["http://localhost:8080/image?imageName=file1652443963449101813.jpg"]'
                         WHEN 179 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         WHEN 184 THEN '["http://localhost:8080/image?imageName=file164569022369110021.jpg"]'
                         WHEN 188 THEN '["http://localhost:8080/image?imageName=file1652444155511102015.jpg"]'
                         ELSE `picture_list`
        END,
    `idle_price` = CASE `id`
                       WHEN 85 THEN 2399.00
                       WHEN 89 THEN 2199.00
                       WHEN 90 THEN 3899.00
                       WHEN 91 THEN 4199.00
                       WHEN 95 THEN 999.00
                       WHEN 96 THEN 1199.00
                       WHEN 97 THEN 1499.00
                       WHEN 101 THEN 2699.00
                       WHEN 102 THEN 60.00
                       WHEN 103 THEN 80.00
                       WHEN 106 THEN 2699.00
                       WHEN 108 THEN 2299.00
                       WHEN 109 THEN 5999.00
                       WHEN 111 THEN 3299.00
                       WHEN 112 THEN 6888.00
                       WHEN 115 THEN 2399.00
                       WHEN 135 THEN 1699.00
                       WHEN 136 THEN 3299.00
                       WHEN 137 THEN 2899.00
                       WHEN 141 THEN 8999.00
                       WHEN 142 THEN 4199.00
                       WHEN 143 THEN 1999.00
                       WHEN 149 THEN 3599.00
                       WHEN 150 THEN 5299.00
                       WHEN 151 THEN 2799.00
                       WHEN 172 THEN 29.00
                       WHEN 173 THEN 199.00
                       WHEN 175 THEN 89.00
                       WHEN 176 THEN 2999.00
                       WHEN 177 THEN 2299.00
                       WHEN 178 THEN 4599.00
                       WHEN 179 THEN 4999.00
                       WHEN 184 THEN 2199.00
                       WHEN 188 THEN 39.00
                       ELSE `idle_price`
        END,
    `idle_label` = CASE `id`
                       WHEN 85 THEN 2
                       WHEN 89 THEN 1
                       WHEN 90 THEN 1
                       WHEN 91 THEN 2
                       WHEN 95 THEN 2
                       WHEN 96 THEN 1
                       WHEN 97 THEN 1
                       WHEN 101 THEN 3
                       WHEN 102 THEN 5
                       WHEN 103 THEN 5
                       WHEN 106 THEN 1
                       WHEN 108 THEN 3
                       WHEN 109 THEN 4
                       WHEN 111 THEN 1
                       WHEN 112 THEN 4
                       WHEN 115 THEN 3
                       WHEN 135 THEN 2
                       WHEN 136 THEN 2
                       WHEN 137 THEN 2
                       WHEN 141 THEN 4
                       WHEN 142 THEN 4
                       WHEN 143 THEN 1
                       WHEN 149 THEN 1
                       WHEN 150 THEN 2
                       WHEN 151 THEN 3
                       WHEN 172 THEN 5
                       WHEN 173 THEN 5
                       WHEN 175 THEN 5
                       WHEN 176 THEN 1
                       WHEN 177 THEN 1
                       WHEN 178 THEN 1
                       WHEN 179 THEN 2
                       WHEN 184 THEN 1
                       WHEN 188 THEN 5
                       ELSE `idle_label`
        END
WHERE `id` IN (85, 89, 90, 91, 95, 96, 97, 101, 102, 103, 106, 108, 109, 111, 112, 115, 135, 136, 137, 141, 142, 143, 149, 150, 151, 172, 173, 175, 176, 177, 178, 179, 184, 188);

DELETE FROM `sh_idle_item` WHERE `id` BETWEEN 189 AND 200;

-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


-- Data rows omitted from the public source snapshot.


COMMIT;

USE second_hand_trading;

-- Normalize shipping address demo data.
UPDATE sh_address
SET
    province_name = '浙江省',
    city_name = '杭州市',
    region_name = '西湖区',
    detail_address = CASE
                         WHEN detail_address IS NULL OR detail_address = '' THEN '文三路 478 号'
                         ELSE detail_address
        END
WHERE province_name IN ('男生宿舍', '女生宿舍')
   OR city_name REGEXP '号楼|楼栋'
   OR region_name REGEXP '层|一层|二层|三层|四层|五层|六层';

-- Normalize idle item location demo data.
UPDATE sh_idle_item
SET idle_place = CASE MOD(id, 6)
                     WHEN 0 THEN '浙江省 / 杭州市 / 西湖区'
                     WHEN 1 THEN '江苏省 / 南京市 / 江宁区'
                     WHEN 2 THEN '广东省 / 深圳市 / 南山区'
                     WHEN 3 THEN '四川省 / 成都市 / 武侯区'
                     WHEN 4 THEN '湖北省 / 武汉市 / 洪山区'
                     ELSE '陕西省 / 西安市 / 雁塔区'
    END
WHERE idle_place REGEXP '宿舍|号楼|楼|层';

-- Optional check.
SELECT id, province_name, city_name, region_name, detail_address
FROM sh_address
ORDER BY id DESC
LIMIT 20;

SELECT id, idle_name, idle_place
FROM sh_idle_item
ORDER BY id DESC
LIMIT 20;

USE second_hand_trading;

-- Compatible with older MySQL versions that do not support ADD COLUMN IF NOT EXISTS.
SET @avatar_column_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'sh_user'
      AND COLUMN_NAME = 'avatar'
);

SET @alter_sql = IF(
        @avatar_column_exists > 0,
        'SELECT ''avatar column already exists''',
        'ALTER TABLE sh_user ADD COLUMN avatar VARCHAR(256) NOT NULL DEFAULT '''' COMMENT ''头像'''
                 );

PREPARE stmt FROM @alter_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Seed avatar URLs from files that already exist in the local xmtp directory.
-- File access path is provided by FileController: /image?imageName=...
UPDATE sh_user
SET avatar = CASE id
                 WHEN 36 THEN 'http://localhost:8080/image?imageName=file17264683773801005OIP-C.jpg'
                 WHEN 37 THEN 'http://localhost:8080/image?imageName=file17264682791321002R-C.jpg'
                 WHEN 38 THEN 'http://localhost:8080/image?imageName=file1726468351394100420204823154758937.jpg'
                 WHEN 39 THEN 'http://localhost:8080/image?imageName=file1726468312095100320230415081411_f2e46.thumb.400_0.jpg'
                 WHEN 40 THEN 'http://localhost:8080/image?imageName=file164689495865510061.png'
                 WHEN 43 THEN 'http://localhost:8080/image?imageName=file165244405499510191556115156156.jpg'
                 ELSE avatar
    END
WHERE id IN (36, 37, 38, 39, 40, 43);

SELECT id, nickname, avatar
FROM sh_user
ORDER BY id;
