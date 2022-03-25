/*
 Navicat Premium Data Transfer

 Source Server         : 47.111.0.135
 Source Server Type    : MySQL
 Source Server Version : 50624
 Source Host           : 47.111.0.135:3306
 Source Schema         : mugu_blog_auth_server

 Target Server Type    : MySQL
 Target Server Version : 50624
 File Encoding         : 65001

 Date: 22/03/2022 10:51:40
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for oauth_client_details
-- ----------------------------
DROP TABLE IF EXISTS `oauth_client_details`;
CREATE TABLE `oauth_client_details`  (
  `client_id` varchar(48) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '客户端id',
  `resource_ids` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '资源的id，多个用逗号分隔',
  `client_secret` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '客户端的秘钥',
  `scope` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '客户端的权限，多个用逗号分隔',
  `authorized_grant_types` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '授权类型，五种，多个用逗号分隔',
  `web_server_redirect_uri` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '授权码模式的跳转uri',
  `authorities` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '权限，多个用逗号分隔',
  `access_token_validity` int(11) NULL DEFAULT NULL COMMENT 'access_token的过期时间，单位毫秒，覆盖掉硬编码',
  `refresh_token_validity` int(11) NULL DEFAULT NULL COMMENT 'refresh_token的过期时间，单位毫秒，覆盖掉硬编码',
  `additional_information` varchar(4096) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '扩展字段，JSON',
  `autoapprove` varchar(256) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '默认false，是否自动授权',
  PRIMARY KEY (`client_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of oauth_client_details
-- ----------------------------
INSERT INTO `oauth_client_details` VALUES ('mugu', 'res1', '$2a$10$HWuOIx8C.YvlhLwp2j5LYe/r8B04xtcFmuu6t1XEBrnr2JLGFcc0q', 'all', 'authorization_code,client_credentials,implicit,refresh_token,password', 'http://www.baidu.com', NULL, NULL, NULL, NULL, 'false');

-- ----------------------------
-- Table structure for sys_meun
-- ----------------------------
DROP TABLE IF EXISTS `sys_meun`;
CREATE TABLE `sys_meun`  (
  `id` bigint(11) NOT NULL,
  `code` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '编码',
  `name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '权限名称',
  `url` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT 'URL权限标识',
  `create_time` datetime(0) NULL DEFAULT NULL,
  `update_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `id`(`id`, `name`) USING BTREE,
  INDEX `id_2`(`id`, `name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '权限表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (1, '获取文章列表', 'POST:/blog-article/admin/article/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (2, '添加文章', 'POST:/blog-article/admin/article/add', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (3, '删除文章', 'POST:/blog-article/admin/article/del', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (4, '根据ID获取文章详情', 'POST:/blog-article/admin/article/getById', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (5, '搜索文章-后台', 'POST:/blog-article/admin/article/search', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (6, '根据ID获取文章详情', 'POST:/blog-article/front/article/getById', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (7, '获取文章列表', 'POST:/blog-article/front/article/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (8, '搜索文章-前台', 'POST:/blog-article/front/article/search', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (9, '底部统计信息', 'POST:/blog-article/front/footer/total', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (10, '添加分类', 'POST:/blog-article/admin/type/add', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (11, '根据ID查询分类详情', 'GET:/blog-article/admin/type/getById', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (12, '分页查询分类', 'POST:/blog-article/admin/type/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (13, '根据ID查询分类详情', 'GET:/blog-article/front/type/getById', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (14, '分页查询分类', 'POST:/blog-article/front/type/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (15, '添加评论', 'POST:/blog-comments/comment/add', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (16, '获取评论列表', 'POST:/blog-comments/comment/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (17, '获取文章的评论总数', 'POST:/blog-comments/comment/total', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (18, '添加留言', 'POST:/blog-comments/message/add', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (19, '获取留言列表', 'POST:/blog-comments/message/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (20, '获取留言总数', 'POST:/blog-comments/message/total', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (21, '上传相册', 'POST:/blog-picture/admin/picture/add', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (22, '删除相册', 'POST:/blog-picture/admin/picture/del', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (23, '获取相册', 'POST:/blog-picture/admin/picture/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (24, '获取相册', 'POST:/blog-picture/front/picture/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (25, '添加友链', 'POST:/blog-friendlinks/admin/friend/links/add', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (26, '删除友链', 'POST:/blog-friendlinks/admin/friend/links/del', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (27, '分页获取友链', 'POST:/blog-friendlinks/admin/friend/links/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');
INSERT INTO `sys_permission` VALUES (28, '分页获取友链', 'POST:/blog-friendlinks/front/friend/links/list', '2021-02-02 14:16:07', '2021-06-16 22:25:24');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '' COMMENT '角色名称',
  `code` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '角色编码',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '角色状态：0-正常；1-停用',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '更新时间',
  `update_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '角色表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'ROOT', 1, '2021-05-21 14:56:51', '2018-12-23 16:00:00');
INSERT INTO `sys_role` VALUES (2, '管理员', 'ADMIN', 1, '2021-03-25 12:39:54', '2018-12-23 16:00:00');
INSERT INTO `sys_role` VALUES (3, 'VIP', 'vip', 1, '2022-03-20 15:48:25', '2022-03-20 15:48:27');

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `id` bigint(11) NOT NULL AUTO_INCREMENT,
  `role_id` bigint(11) NULL DEFAULT NULL COMMENT '角色id',
  `permission_id` bigint(11) NULL DEFAULT NULL COMMENT '资源id',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `role_id`(`role_id`) USING BTREE,
  INDEX `permission_id`(`permission_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 59 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '角色权限表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------
INSERT INTO `sys_role_permission` VALUES (1, 1, 1);
INSERT INTO `sys_role_permission` VALUES (2, 1, 2);
INSERT INTO `sys_role_permission` VALUES (3, 1, 3);
INSERT INTO `sys_role_permission` VALUES (4, 1, 4);
INSERT INTO `sys_role_permission` VALUES (5, 1, 5);
INSERT INTO `sys_role_permission` VALUES (6, 1, 6);
INSERT INTO `sys_role_permission` VALUES (7, 1, 7);
INSERT INTO `sys_role_permission` VALUES (8, 1, 8);
INSERT INTO `sys_role_permission` VALUES (9, 1, 9);
INSERT INTO `sys_role_permission` VALUES (10, 1, 10);
INSERT INTO `sys_role_permission` VALUES (11, 1, 11);
INSERT INTO `sys_role_permission` VALUES (12, 1, 12);
INSERT INTO `sys_role_permission` VALUES (13, 1, 13);
INSERT INTO `sys_role_permission` VALUES (14, 1, 14);
INSERT INTO `sys_role_permission` VALUES (15, 1, 15);
INSERT INTO `sys_role_permission` VALUES (16, 1, 16);
INSERT INTO `sys_role_permission` VALUES (17, 1, 17);
INSERT INTO `sys_role_permission` VALUES (18, 1, 18);
INSERT INTO `sys_role_permission` VALUES (19, 1, 19);
INSERT INTO `sys_role_permission` VALUES (20, 1, 20);
INSERT INTO `sys_role_permission` VALUES (21, 1, 21);
INSERT INTO `sys_role_permission` VALUES (22, 1, 22);
INSERT INTO `sys_role_permission` VALUES (23, 1, 23);
INSERT INTO `sys_role_permission` VALUES (24, 1, 24);
INSERT INTO `sys_role_permission` VALUES (25, 1, 25);
INSERT INTO `sys_role_permission` VALUES (26, 1, 26);
INSERT INTO `sys_role_permission` VALUES (27, 1, 27);
INSERT INTO `sys_role_permission` VALUES (28, 1, 28);
INSERT INTO `sys_role_permission` VALUES (30, 2, 1);
INSERT INTO `sys_role_permission` VALUES (31, 2, 2);
INSERT INTO `sys_role_permission` VALUES (32, 2, 3);
INSERT INTO `sys_role_permission` VALUES (33, 2, 4);
INSERT INTO `sys_role_permission` VALUES (34, 2, 5);
INSERT INTO `sys_role_permission` VALUES (35, 2, 6);
INSERT INTO `sys_role_permission` VALUES (36, 2, 7);
INSERT INTO `sys_role_permission` VALUES (37, 2, 8);
INSERT INTO `sys_role_permission` VALUES (38, 2, 9);
INSERT INTO `sys_role_permission` VALUES (39, 2, 10);
INSERT INTO `sys_role_permission` VALUES (40, 2, 11);
INSERT INTO `sys_role_permission` VALUES (41, 2, 12);
INSERT INTO `sys_role_permission` VALUES (42, 2, 13);
INSERT INTO `sys_role_permission` VALUES (43, 2, 14);
INSERT INTO `sys_role_permission` VALUES (44, 2, 15);
INSERT INTO `sys_role_permission` VALUES (45, 2, 16);
INSERT INTO `sys_role_permission` VALUES (46, 2, 17);
INSERT INTO `sys_role_permission` VALUES (47, 2, 18);
INSERT INTO `sys_role_permission` VALUES (48, 2, 19);
INSERT INTO `sys_role_permission` VALUES (49, 2, 20);
INSERT INTO `sys_role_permission` VALUES (50, 2, 21);
INSERT INTO `sys_role_permission` VALUES (51, 2, 22);
INSERT INTO `sys_role_permission` VALUES (52, 2, 23);
INSERT INTO `sys_role_permission` VALUES (53, 2, 24);
INSERT INTO `sys_role_permission` VALUES (54, 2, 25);
INSERT INTO `sys_role_permission` VALUES (55, 2, 26);
INSERT INTO `sys_role_permission` VALUES (56, 2, 27);
INSERT INTO `sys_role_permission` VALUES (57, 2, 28);
INSERT INTO `sys_role_permission` VALUES (58, 3, 4);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(60) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `username` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户名',
  `nickname` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `gender` tinyint(1) NULL DEFAULT 1 COMMENT '性别：1-男 2-女',
  `password` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '密码',
  `avatar` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '' COMMENT '用户头像',
  `mobile` varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '联系方式',
  `status` tinyint(1) NULL DEFAULT 1 COMMENT '用户状态：1-正常 0-禁用',
  `email` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户邮箱',
  `create_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `login_name`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户信息表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, '7adc94f4b38f45678461fc995ea21b14', 'guest', '不才陈某', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '123@163.com', '2019-10-10 13:41:22', '2022-03-21 11:44:45');
INSERT INTO `sys_user` VALUES (2, '96d42b43c1b24f50b2794e12a7555d2e', 'admin', '系统管理员', 1, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', 'https://gitee.com/haoxr/image/raw/master/20210605215800.png', '17621210366', 1, '123@163.com', '2019-10-10 13:41:22', '2022-02-09 11:07:34');
INSERT INTO `sys_user` VALUES (4, '94dd9d02befd4dac9d6e708ff92f7d82', 'root', '不才陈某', 1, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', 'https://gitee.com/haoxr/image/raw/master/20210605215800.png', '17621210366', 1, '123@163.com', '2021-06-05 01:31:29', '2022-03-20 14:27:57');
INSERT INTO `sys_user` VALUES (5, '7adc94f4b38f45678461fc995ea21b28', '843279946@qq.com', '843279946@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '843279946@qq.com', '2019-10-10 13:41:22', '2022-03-21 09:24:37');
INSERT INTO `sys_user` VALUES (6, '7adc94f4b38f45678461fc995ea21b30', '18653271024@163.com', '18653271024@163.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '18653271024@163.com', '2019-10-10 13:41:22', '2022-03-21 09:24:37');
INSERT INTO `sys_user` VALUES (7, '7adc94f4b38f45678461fc995ea21b31', '952381228@qq.com', '952381228@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '952381228@qq.com', '2019-10-10 13:41:22', '2022-03-21 09:24:37');
INSERT INTO `sys_user` VALUES (8, '7adc94f4b38f45678461fc995ea21b32', '454446828@qq.com', '454446828@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '454446828@qq.com', '2019-10-10 13:41:22', '2022-03-21 09:24:37');
INSERT INTO `sys_user` VALUES (9, '7adc94f4b38f45678461fc995ea21b33', '1798566223@qq.com', '1798566223@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '1798566223@qq.com', '2019-10-10 13:41:22', '2022-03-21 11:11:57');
INSERT INTO `sys_user` VALUES (10, '7adc94f4b38f45678461fc995ea21b34', 'zhouwp95@163.com', 'zhouwp95@163.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, 'zhouwp95@163.com', '2019-10-10 13:41:22', '2022-03-21 11:11:57');
INSERT INTO `sys_user` VALUES (11, '7adc94f4b38f45678461fc995ea21b35', 'greatgong@163.com', 'greatgong@163.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, 'greatgong@163.com', '2019-10-10 13:41:22', '2022-03-21 13:38:37');
INSERT INTO `sys_user` VALUES (12, '7adc94f4b38f45678461fc995ea21b36', '357207879@qq.com', '357207879@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '357207879@qq.com', '2019-10-10 13:41:22', '2022-03-21 13:38:37');
INSERT INTO `sys_user` VALUES (13, '7adc94f4b38f45678461fc995ea21b37', 'ahidayong@sina.com', '357207879@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, 'ahidayong@sina.com', '2019-10-10 13:41:22', '2022-03-21 13:38:37');
INSERT INTO `sys_user` VALUES (14, '7adc94f4b38f45678461fc995ea21b38', 'lee19971111@163.com', '357207879@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, 'lee19971111@163.com', '2019-10-10 13:41:22', '2022-03-21 13:38:37');
INSERT INTO `sys_user` VALUES (15, '7adc94f4b38f45678461fc995ea21b39', 'michael.tang2101@gmail.com', '357207879@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, 'michael.tang2101@gmail.com', '2019-10-10 13:41:22', '2022-03-21 13:38:37');
INSERT INTO `sys_user` VALUES (16, '7adc94f4b38f45678461fc995ea21b40', '728119427@qq.com', '357207879@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '728119427@qq.com', '2019-10-10 13:41:22', '2022-03-21 13:38:37');
INSERT INTO `sys_user` VALUES (17, '7adc94f4b38f45678461fc995ea21b41', '348425574@qq.com', '357207879@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '348425574@qq.com', '2019-10-10 13:41:22', '2022-03-21 13:38:37');
INSERT INTO `sys_user` VALUES (18, '7adc94f4b38f45678461fc995ea21b42', '2538550964@qq.com', '357207879@qq.com', 2, '$2a$10$8ecKl8JVIgA39pknoixkjOC4FRz0CJwYItS7UU0Y5zOa0wZN45CqS', '', '17621590365', 1, '2538550964@qq.com', '2019-10-10 13:41:22', '2022-03-21 13:38:37');

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `id` bigint(11) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(11) NOT NULL COMMENT '用户ID',
  `role_id` bigint(11) NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 18 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '用户和角色关联表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1, 3);
INSERT INTO `sys_user_role` VALUES (2, 2, 2);
INSERT INTO `sys_user_role` VALUES (3, 4, 1);
INSERT INTO `sys_user_role` VALUES (4, 5, 3);
INSERT INTO `sys_user_role` VALUES (5, 6, 3);
INSERT INTO `sys_user_role` VALUES (6, 7, 3);
INSERT INTO `sys_user_role` VALUES (7, 8, 3);
INSERT INTO `sys_user_role` VALUES (8, 9, 3);
INSERT INTO `sys_user_role` VALUES (9, 10, 3);
INSERT INTO `sys_user_role` VALUES (10, 11, 3);
INSERT INTO `sys_user_role` VALUES (11, 12, 3);
INSERT INTO `sys_user_role` VALUES (12, 13, 3);
INSERT INTO `sys_user_role` VALUES (13, 14, 3);
INSERT INTO `sys_user_role` VALUES (14, 15, 3);
INSERT INTO `sys_user_role` VALUES (15, 16, 3);
INSERT INTO `sys_user_role` VALUES (16, 17, 3);
INSERT INTO `sys_user_role` VALUES (17, 18, 3);

-- ----------------------------
-- Table structure for undo_log
-- ----------------------------
DROP TABLE IF EXISTS `undo_log`;
CREATE TABLE `undo_log`  (
  `branch_id` bigint(20) NOT NULL COMMENT 'branch transaction id',
  `xid` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'global transaction id',
  `context` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'undo_log context,such as serialization',
  `rollback_info` longblob NOT NULL COMMENT 'rollback info',
  `log_status` int(11) NOT NULL COMMENT '0:normal status,1:defense status',
  `log_created` datetime(6) NOT NULL COMMENT 'create datetime',
  `log_modified` datetime(6) NOT NULL COMMENT 'modify datetime',
  UNIQUE INDEX `ux_undo_log`(`xid`, `branch_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = 'AT transaction mode undo table' ROW_FORMAT = Compact;

SET FOREIGN_KEY_CHECKS = 1;
