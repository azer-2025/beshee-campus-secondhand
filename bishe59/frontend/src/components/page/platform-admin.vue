<template>
    <div class="admin-layout">
        <header class="admin-header">
            <div class="header-content">
                <div class="header-left">
                    <div class="logo-wrapper">
                        <div class="logo-icon">
                            <i class="el-icon-mobile-phone"></i>
                        </div>
                        <span class="app-title">二手手机交易平台管理</span>
                    </div>
                </div>
                <div class="header-right">
                    <div class="user-profile">
                        <div class="avatar-circle">
                            {{ admin.nickname?.charAt(0)?.toUpperCase() || 'A' }}
                        </div>
                        <div class="user-details">
                            <span class="role-badge">系统管理员</span>
                            <span class="username">{{ admin.nickname }}</span>
                        </div>
                    </div>
                    <el-button class="logout-btn" @click="logout">
                        <i class="el-icon-switch-button"></i>
                        <span>退出</span>
                    </el-button>
                </div>
            </div>
        </header>

        <div class="admin-body">
            <aside class="admin-sidebar">
                <div class="sidebar-inner">
                    <el-menu
                        :default-active="mode.toString()"
                        class="modern-menu"
                        @select="handleSelect">
                        <el-menu-item index="1">
                            <div class="menu-item-content">
                                <i class="el-icon-mobile-phone"></i>
                                <span>手机商品管理</span>
                            </div>
                        </el-menu-item>
                        <el-menu-item index="2">
                            <div class="menu-item-content">
                                <i class="el-icon-tickets"></i>
                                <span>订单交易管理</span>
                            </div>
                        </el-menu-item>
                        <el-menu-item index="3">
                            <div class="menu-item-content">
                                <i class="el-icon-user"></i>
                                <span>平台用户管理</span>
                            </div>
                        </el-menu-item>
                        <el-menu-item index="4">
                            <div class="menu-item-content">
                                <i class="el-icon-pie-chart"></i>
                                <span>数据中心</span>
                            </div>
                        </el-menu-item>
                        <el-menu-item index="5">
                            <div class="menu-item-content">
                                <i class="el-icon-monitor"></i>
                                <span>系统监控</span>
                            </div>
                        </el-menu-item>
                    </el-menu>
                </div>
            </aside>

            <main class="admin-main">
                <div class="content-wrapper">
                    <transition name="fade-up" mode="out-in" v-if="authChecked">
                        <div :key="mode" class="page-container">
                            <IdleGoods v-if="mode === 1" />
                            <orderList v-if="mode === 2" />
                            <userList v-if="mode === 3" />
                            <DataStatistics v-if="mode === 4" />
                            <SystemMonitor v-if="mode === 5" />
                        </div>
                    </transition>
                </div>
            </main>
        </div>
    </div>
</template>

<script>
import IdleGoods from '../common/IdleGoods.vue';
import orderList from '../common/orderList.vue';
import userList from '../common/userList.vue';
import DataStatistics from '../common/DataStatistics.vue';
import SystemMonitor from '../common/SystemMonitor.vue';

export default {
    name: 'platform-admin',
    components: {
        IdleGoods,
        orderList,
        userList,
        DataStatistics,
        SystemMonitor
    },
    data() {
        return {
            mode: 1,
            authChecked: false,
            admin: {
                nickname: ''
            }
        };
    },
    created() {
        const pageParam = Number.parseInt(this.$route.query.page, 10);
        if (Number.isInteger(pageParam) && pageParam > 0) {
            this.mode = pageParam;
        }

        this.hydrateAdminName();
        this.validateAdminSession();
    },
    mounted() {
        window.addEventListener('admin-profile-updated', this.handleAdminProfileUpdated);
    },
    beforeUnmount() {
        window.removeEventListener('admin-profile-updated', this.handleAdminProfileUpdated);
    },
    methods: {
        handleAdminProfileUpdated(event) {
            const nextAdminName = event?.detail?.adminName;
            if (nextAdminName) {
                this.admin.nickname = nextAdminName;
            }
        },
        hydrateAdminName() {
            const adminName = this.$sta.adminName || sessionStorage.getItem('admin_name') || '';
            if (adminName) {
                this.admin.nickname = adminName;
            }
        },
        clearAdminSession() {
            this.$sta.isLogin = false;
            this.$sta.adminName = '';
            sessionStorage.removeItem('admin_is_login');
            sessionStorage.removeItem('admin_name');
        },
        validateAdminSession() {
            this.$api.getCurrentAdmin().then(res => {
                if (res.status_code === 1 && res.data) {
                    const adminName = res.data.adminName || 'Admin';
                    this.$sta.isLogin = true;
                    this.$sta.adminName = adminName;
                    sessionStorage.setItem('admin_is_login', '1');
                    sessionStorage.setItem('admin_name', adminName);
                    this.admin.nickname = adminName;
                    this.authChecked = true;
                    return;
                }

                this.handleAuthExpired(res.msg || '管理员登录状态已失效，请重新登录');
            }).catch(error => {
                console.log('Failed to fetch current admin:', error);
                this.handleAuthExpired('管理员登录状态已失效，请重新登录');
            });
        },
        handleAuthExpired(message) {
            this.clearAdminSession();
            this.authChecked = false;
            this.$message.warning(message);
            this.$router.replace({ path: '/login-admin' });
        },
        logout() {
            this.$api.loginOut({}).then(res => {
                if (res.status_code === 1) {
                    this.clearAdminSession();
                    this.$router.push({ path: '/login-admin' });
                    return;
                }

                this.handleAuthExpired(res.msg || '管理员登录状态已失效，请重新登录');
            }).catch(error => {
                console.log(error);
                this.handleAuthExpired('管理员登录状态已失效，请重新登录');
            });
        },
        handleSelect(val) {
            const nextMode = Number.parseInt(val, 10);
            if (this.mode === nextMode) {
                return;
            }

            this.mode = nextMode;
            this.$router.push({
                query: {
                    ...this.$route.query,
                    page: val
                }
            });
        }
    }
};
</script>

<style scoped>
.admin-layout {
    height: 100vh;
    display: flex;
    flex-direction: column;
    background-color: var(--bg-main);
    overflow: hidden;
}

.admin-header {
    height: 72px;
    background: var(--bg-glass);
    backdrop-filter: var(--glass-blur);
    -webkit-backdrop-filter: var(--glass-blur);
    border-bottom: 1px solid rgba(226, 232, 240, 0.5);
    position: sticky;
    top: 0;
    z-index: 100;
    display: flex;
    align-items: center;
}

.header-content {
    width: 100%;
    padding: 0 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo-wrapper {
    display: flex;
    align-items: center;
    gap: 12px;
}

.logo-icon {
    width: 40px;
    height: 40px;
    background: var(--brand-gradient);
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 20px;
    box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.app-title {
    font-size: 1.25rem;
    font-weight: 700;
    background: linear-gradient(to right, var(--text-primary), var(--brand-primary));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    letter-spacing: -0.02em;
}

.header-right {
    display: flex;
    align-items: center;
    gap: 20px;
}

.user-profile {
    display: flex;
    align-items: center;
    gap: 12px;
    padding-right: 20px;
    border-right: 1px solid #e2e8f0;
}

.avatar-circle {
    width: 40px;
    height: 40px;
    background: #f1f5f9;
    border: 2px solid white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    color: var(--brand-primary);
    box-shadow: var(--shadow-soft);
}

.user-details {
    display: flex;
    flex-direction: column;
}

.role-badge {
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    color: var(--brand-primary);
    background: var(--brand-primary-light);
    padding: 2px 8px;
    border-radius: 20px;
    width: fit-content;
}

.username {
    font-size: 14px;
    font-weight: 600;
    color: var(--text-primary);
}

.logout-btn {
    background: white !important;
    border: 1px solid #e2e8f0 !important;
    color: var(--text-secondary) !important;
    box-shadow: none !important;
}

.logout-btn:hover {
    border-color: var(--danger-red) !important;
    color: var(--danger-red) !important;
    background: #fef2f2 !important;
}

.admin-body {
    flex: 1;
    display: flex;
    overflow: hidden;
}

.admin-sidebar {
    width: 260px;
    padding: 24px 0 24px 24px;
    background: var(--bg-main);
}

.sidebar-inner {
    height: 100%;
    background: white;
    border-radius: var(--radius-xl);
    display: flex;
    flex-direction: column;
    box-shadow: var(--shadow-soft);
    border: 1px solid rgba(226, 232, 240, 0.8);
    overflow: hidden;
}

.modern-menu {
    border-right: none !important;
    padding: 16px 12px;
    flex: 1;
}

.modern-menu :deep(.el-menu-item) {
    height: 54px !important;
    line-height: 54px !important;
    margin-bottom: 8px;
    border-radius: var(--radius-md);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.modern-menu :deep(.el-menu-item.is-active) {
    background: var(--brand-primary-light) !important;
    color: var(--brand-primary) !important;
    font-weight: 600;
}

.modern-menu :deep(.el-menu-item:hover) {
    background: #f8fafc;
}

.menu-item-content {
    display: flex;
    align-items: center;
    gap: 12px;
}

.menu-item-content i {
    font-size: 18px;
}

.admin-main {
    flex: 1;
    padding: 24px;
    overflow-y: auto;
    scroll-behavior: smooth;
}

.content-wrapper {
    width: 100%;
    height: 100%;
}

.page-container {
    animation: fadeUp 0.6s cubic-bezier(0.22, 1, 0.36, 1);
}

@keyframes fadeUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }

    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.admin-main::-webkit-scrollbar {
    width: 6px;
}

.admin-main::-webkit-scrollbar-thumb {
    background: #e2e8f0;
    border-radius: 10px;
}

@media (max-width: 1024px) {
    .admin-sidebar {
        width: 80px;
        padding: 16px;
    }

    .app-title,
    .role-badge,
    .menu-item-content span {
        display: none;
    }

    .modern-menu {
        padding: 12px 8px;
    }

    .menu-item-content {
        justify-content: center;
    }
}
</style>
