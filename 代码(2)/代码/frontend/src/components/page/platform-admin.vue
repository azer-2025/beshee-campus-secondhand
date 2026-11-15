<template>
  <div class="admin-layout">
    <header class="admin-header">
      <div class="header-content">
        <div class="header-left">
          <div class="logo-wrapper">
            <div class="logo-icon">
              <i class="el-icon-shopping-cart-full"></i>
            </div>
            <span class="app-title">校园二手交易平台管理</span>
          </div>
        </div>

        <div class="header-right">
          <div class="user-profile">
            <div class="avatar-circle">
              {{ adminInitial }}
            </div>
            <div class="user-details">
              <span class="role-badge">系统管理员</span>
              <span class="username">{{ adminName }}</span>
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
          <el-menu :default-active="String(mode)" class="modern-menu" @select="handleSelect">
            <el-menu-item index="1">
              <div class="menu-item-content">
                <i class="el-icon-goods"></i>
                <span>闲置商品管理</span>
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
                <span>可视化数据中心</span>
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
          <transition name="fade-up" mode="out-in">
            <div :key="mode" class="page-container">
              <IdleGoods v-if="mode === 1" />
              <OrderList v-else-if="mode === 2" />
              <UserList v-else-if="mode === 3" />
              <DataStatistics v-else-if="mode === 4" />
              <SystemMonitor v-else />
            </div>
          </transition>
        </div>
      </main>
    </div>
  </div>
</template>

<script>
import IdleGoods from '../common/IdleGoods.vue';
import OrderList from '../common/orderList.vue';
import UserList from '../common/userList.vue';
import DataStatistics from '../common/DataStatistics.vue';
import SystemMonitor from '../common/SystemMonitor.vue';

export default {
  name: 'PlatformAdmin',
  components: {
    IdleGoods,
    OrderList,
    UserList,
    DataStatistics,
    SystemMonitor,
  },
  data() {
    return {
      mode: 1,
    };
  },
  computed: {
    adminName() {
      return this.$globalData.adminInfo?.adminName || this.$sta.adminName || '管理员';
    },
    adminInitial() {
      return this.adminName.slice(0, 1).toUpperCase();
    },
  },
  created() {
    this.syncModeFromRoute();
  },
  watch: {
    '$route.query.page'() {
      this.syncModeFromRoute();
    },
  },
  methods: {
    syncModeFromRoute() {
      const pageValue = Number(this.$route.query.page || 1);
      this.mode = [1, 2, 3, 4, 5].includes(pageValue) ? pageValue : 1;
    },
    logout() {
      this.$api.loginOut({}).then((res) => {
        if (res.status_code !== 1) {
          return;
        }
        this.$sta.isLogin = false;
        this.$sta.adminName = '';
        this.$globalData.adminInfo = { adminName: '' };
        this.$router.push({ path: '/login-admin' });
      });
    },
    handleSelect(value) {
      const nextMode = Number(value);
      if (this.mode === nextMode) {
        return;
      }
      this.mode = nextMode;
      this.$router.push({
        path: '/platform-admin',
        query: {
          ...this.$route.query,
          page: String(nextMode),
        },
      });
    },
  },
};
</script>

<style scoped>
.admin-layout {
  height: 100vh;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background-color: var(--bg-main);
}

.admin-header {
  position: sticky;
  top: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  height: 72px;
  border-bottom: 1px solid rgba(226, 232, 240, 0.5);
  background: var(--bg-glass);
  backdrop-filter: var(--glass-blur);
  -webkit-backdrop-filter: var(--glass-blur);
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
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  background: var(--brand-gradient);
  color: white;
  font-size: 20px;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.app-title {
  font-size: 1.25rem;
  font-weight: 700;
  letter-spacing: -0.02em;
  background: linear-gradient(to right, var(--text-primary), var(--brand-primary));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
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
  display: flex;
  align-items: center;
  justify-content: center;
  border: 2px solid white;
  border-radius: 50%;
  background: #f1f5f9;
  color: var(--brand-primary);
  font-weight: 700;
  box-shadow: var(--shadow-soft);
}

.user-details {
  display: flex;
  flex-direction: column;
}

.role-badge {
  width: fit-content;
  padding: 2px 8px;
  border-radius: 20px;
  background: var(--brand-primary-light);
  color: var(--brand-primary);
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
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
  overflow: hidden;
  display: flex;
  flex-direction: column;
  border: 1px solid rgba(226, 232, 240, 0.8);
  border-radius: var(--radius-xl);
  background: white;
  box-shadow: var(--shadow-soft);
}

.modern-menu {
  flex: 1;
  border-right: none !important;
  padding: 16px 12px;
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
  overflow-y: auto;
  padding: 24px;
  scroll-behavior: smooth;
}

.content-wrapper {
  max-width: 1400px;
  height: 100%;
  margin: 0 auto;
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
  border-radius: 10px;
  background: #e2e8f0;
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
