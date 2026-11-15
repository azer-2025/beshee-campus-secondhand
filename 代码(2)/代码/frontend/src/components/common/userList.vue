<template>
  <div class="premium-card management-panel">
    <div class="panel-header">
      <div class="header-left">
        <h2 class="panel-title">平台用户权限中心</h2>
        <p class="panel-subtitle">管理员可维护普通用户、封禁用户和管理团队。</p>
      </div>
      <div class="header-right">
        <div v-if="mode !== 3" class="search-box-v2">
          <i class="el-icon-search search-icon"></i>
          <input
            v-model="searchValue"
            type="text"
            placeholder="按账号或昵称搜索"
            @keyup.enter="searchUsers"
          />
          <el-button type="primary" size="small" @click="searchUsers">搜索</el-button>
        </div>
        <el-button type="primary" class="premium-add-btn" @click="openCreateDialog">
          <i class="el-icon-plus"></i>
          <span>{{ mode === 3 ? '新增管理员' : '新增用户' }}</span>
        </el-button>
      </div>
    </div>

    <div class="modern-tabs">
      <div :class="['tab-item', activeTab === '1' ? 'active' : '']" @click="switchTab('1')">
        <i class="el-icon-user"></i>
        <span>普通用户</span>
      </div>
      <div :class="['tab-item', activeTab === '2' ? 'active' : '']" @click="switchTab('2')">
        <i class="el-icon-lock"></i>
        <span>封禁列表</span>
      </div>
      <div :class="['tab-item', activeTab === '3' ? 'active' : '']" @click="switchTab('3')">
        <i class="el-icon-setting"></i>
        <span>管理团队</span>
      </div>
    </div>

    <div class="table-wrapper" v-loading="tableLoading">
      <el-table
        :data="currentTableData"
        class="premium-table"
        style="width: 100%"
        :header-cell-style="headerStyle"
      >
        <el-table-column v-if="mode !== 3" label="账户概览" min-width="320">
          <template #default="scope">
            <div class="user-main-info">
              <div class="avatar-wrapper">
                <img :src="getAvatar(scope.row.avatar)" alt="avatar" @error="onAvatarError" />
              </div>
              <div class="name-box">
                <span class="u-nickname">{{ scope.row.nickname || '未命名用户' }}</span>
                <span class="u-account">账号：{{ scope.row.accountNumber || '-' }}</span>
              </div>
            </div>
          </template>
        </el-table-column>

        <el-table-column v-if="mode !== 3" prop="signInTime" label="加入时间" min-width="180">
          <template #default="scope">
            <div class="time-cell">
              <i class="el-icon-time"></i>
              <span>{{ scope.row.signInTime || '-' }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column v-if="mode !== 3" label="状态" width="120">
          <template #default="scope">
            <div :class="['status-badge', Number(scope.row.userStatus) === 1 ? 's-danger' : 's-success']">
              {{ Number(scope.row.userStatus) === 1 ? '已封禁' : '正常' }}
            </div>
          </template>
        </el-table-column>

        <el-table-column v-if="mode === 3" prop="accountNumber" label="管理员账号" min-width="220">
          <template #default="scope">
            <span class="admin-account-tag">@{{ scope.row.accountNumber }}</span>
          </template>
        </el-table-column>

        <el-table-column v-if="mode === 3" prop="adminName" label="管理员名称" min-width="200">
          <template #default="scope">
            <div class="admin-role-badge">
              <i class="el-icon-medal"></i>
              <span>{{ scope.row.adminName }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="操作" width="240" align="center">
          <template #default="scope">
            <div class="action-btns">
              <el-button size="small" class="btn-edit" @click="openEditDialog(scope.row)">编辑</el-button>
              <el-button
                v-if="mode !== 3 && Number(scope.row.userStatus) === 0"
                size="small"
                class="btn-danger-soft"
                @click="updateUserStatus(scope.row, 1)"
              >
                封禁
              </el-button>
              <el-button
                v-if="mode !== 3 && Number(scope.row.userStatus) === 1"
                size="small"
                class="btn-success-soft"
                @click="updateUserStatus(scope.row, 0)"
              >
                解封
              </el-button>
              <el-button size="small" class="btn-delete" @click="confirmDelete(scope.row)">删除</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <div class="panel-footer">
      <div class="total-info">共 {{ total }} 条记录</div>
      <el-pagination
        v-model:current-page="nowPage"
        :page-size="8"
        layout="prev, pager, next"
        :total="total"
        class="premium-pagination"
        @current-change="handleCurrentChange"
      />
    </div>

    <el-dialog
      v-model="userDialogVisible"
      :title="userEditing ? '编辑用户' : '新增用户'"
      width="560px"
      class="premium-dialog"
      append-to-body
    >
      <div class="dialog-form">
        <div class="double-grid">
          <div class="input-group">
            <label>账号</label>
            <el-input v-model="userForm.accountNumber" placeholder="请输入手机号或学号" />
          </div>
          <div class="input-group">
            <label>昵称</label>
            <el-input v-model="userForm.nickname" placeholder="请输入昵称" />
          </div>
        </div>

        <div class="double-grid">
          <div class="input-group">
            <label>{{ userEditing ? '重置密码（留空则不修改）' : '登录密码' }}</label>
            <el-input
              v-model="userForm.userPassword"
              type="password"
              show-password
              placeholder="请输入密码"
            />
          </div>
          <div class="input-group">
            <label>状态</label>
            <el-select v-model="userForm.userStatus" placeholder="请选择状态" style="width: 100%">
              <el-option label="正常" :value="0" />
              <el-option label="封禁" :value="1" />
            </el-select>
          </div>
        </div>

        <div class="input-group">
          <label>头像</label>
          <el-upload
            :action="uploadAction"
            :show-file-list="false"
            accept="image/*"
            :on-success="handleAvatarUploadSuccess"
          >
            <el-button plain>上传头像</el-button>
          </el-upload>
          <el-input v-model="userForm.avatar" placeholder="可直接填写头像地址" />
        </div>
      </div>

      <template #footer>
        <div class="dialog-btns">
          <el-button @click="userDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitUser">
            {{ userEditing ? '保存修改' : '立即新增' }}
          </el-button>
        </div>
      </template>
    </el-dialog>

    <el-dialog
      v-model="adminDialogVisible"
      :title="adminEditing ? '编辑管理员' : '新增管理员'"
      width="520px"
      class="premium-dialog"
      append-to-body
    >
      <div class="dialog-form">
        <div class="input-group">
          <label>管理员名称</label>
          <el-input v-model="adminForm.adminName" placeholder="例如：超级管理员" />
        </div>
        <div class="input-group">
          <label>管理员账号</label>
          <el-input v-model="adminForm.accountNumber" placeholder="请输入管理员账号" />
        </div>
        <div class="input-group">
          <label>{{ adminEditing ? '重置密码（留空则不修改）' : '登录密码' }}</label>
          <el-input
            v-model="adminForm.adminPassword"
            type="password"
            show-password
            placeholder="请输入密码"
          />
        </div>
      </div>

      <template #footer>
        <div class="dialog-btns">
          <el-button @click="adminDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitAdmin">
            {{ adminEditing ? '保存修改' : '立即新增' }}
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { DEFAULT_AVATAR, resolveAssetUrl } from '../../utils/asset';

const uploadAction = import.meta.env.DEV
  ? '/api/file'
  : `${(import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080').replace(/\/$/, '')}/file`;

function createUserForm(defaultStatus = 0) {
  return {
    id: null,
    accountNumber: '',
    nickname: '',
    userPassword: '',
    avatar: '',
    userStatus: defaultStatus,
  };
}

function createAdminForm() {
  return {
    id: null,
    adminName: '',
    accountNumber: '',
    adminPassword: '',
  };
}

export default {
  name: 'UserList',
  data() {
    return {
      uploadAction,
      mode: 1,
      activeTab: '1',
      nowPage: 1,
      total: 0,
      searchValue: '',
      tableLoading: false,
      normalUsers: [],
      bannedUsers: [],
      adminUsers: [],
      userDialogVisible: false,
      userEditing: false,
      userForm: createUserForm(),
      adminDialogVisible: false,
      adminEditing: false,
      adminForm: createAdminForm(),
      headerStyle: {
        background: '#f8fafc',
        color: '#64748b',
        fontWeight: '700',
        fontSize: '12px',
        borderBottom: '1px solid #e2e8f0',
      },
    };
  },
  computed: {
    currentTableData() {
      if (this.mode === 1) {
        return this.normalUsers;
      }
      if (this.mode === 2) {
        return this.bannedUsers;
      }
      return this.adminUsers;
    },
  },
  created() {
    this.refreshCurrent();
  },
  methods: {
    getAvatar(avatar) {
      return resolveAssetUrl(avatar, DEFAULT_AVATAR);
    },
    onAvatarError(event) {
      event.target.src = DEFAULT_AVATAR;
    },
    applyPageResult(res, targetKey) {
      if (res.status_code !== 1) {
        return;
      }
      const list = res.data?.list || [];
      const count = Number(res.data?.count || 0);
      this[targetKey] = list;
      this.total = Math.max(count, list.length);
    },
    refreshCurrent() {
      if (this.mode !== 3 && this.searchValue) {
        this.searchUsers();
        return;
      }
      if (this.mode === 1) {
        this.loadUsers(0, 'normalUsers');
      } else if (this.mode === 2) {
        this.loadUsers(1, 'bannedUsers');
      } else {
        this.loadAdmins();
      }
    },
    loadUsers(status, targetKey) {
      this.tableLoading = true;
      this.$api
        .getUserData({ page: this.nowPage, nums: 8, status })
        .then((res) => {
          this.applyPageResult(res, targetKey);
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    loadAdmins() {
      this.tableLoading = true;
      this.$api
        .getUserManage({ page: this.nowPage, nums: 8 })
        .then((res) => {
          this.applyPageResult(res, 'adminUsers');
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    switchTab(name) {
      if (this.activeTab === name) {
        return;
      }
      this.activeTab = name;
      this.mode = Number(name);
      this.nowPage = 1;
      if (this.mode === 3) {
        this.searchValue = '';
      }
      this.refreshCurrent();
    },
    searchUsers() {
      if (this.mode === 3) {
        this.loadAdmins();
        return;
      }
      if (!this.searchValue) {
        this.refreshCurrent();
        return;
      }
      this.tableLoading = true;
      this.$api
        .queryUser({
          searchValue: this.searchValue,
          mode: this.mode,
          page: this.nowPage,
          nums: 8,
        })
        .then((res) => {
          if (res.status_code !== 1) {
            return;
          }
          const list = res.data?.list || [];
          const count = Number(res.data?.count || 0);
          if (this.mode === 1) {
            this.normalUsers = list;
          } else {
            this.bannedUsers = list;
          }
          this.total = Math.max(count, list.length);
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    handleCurrentChange(val) {
      this.nowPage = val;
      this.refreshCurrent();
    },
    openCreateDialog() {
      if (this.mode === 3) {
        this.adminEditing = false;
        this.adminForm = createAdminForm();
        this.adminDialogVisible = true;
        return;
      }
      this.userEditing = false;
      this.userForm = createUserForm(this.mode === 2 ? 1 : 0);
      this.userDialogVisible = true;
    },
    openEditDialog(row) {
      if (this.mode === 3) {
        this.adminEditing = true;
        this.adminForm = {
          id: row.id,
          adminName: row.adminName || '',
          accountNumber: row.accountNumber || '',
          adminPassword: '',
        };
        this.adminDialogVisible = true;
        return;
      }
      this.userEditing = true;
      this.userForm = {
        id: row.id,
        accountNumber: row.accountNumber || '',
        nickname: row.nickname || '',
        userPassword: '',
        avatar: row.avatar || '',
        userStatus: Number(row.userStatus ?? 0),
      };
      this.userDialogVisible = true;
    },
    handleAvatarUploadSuccess(response) {
      if (response.status_code !== 1) {
        this.$message.error(response.msg || '头像上传失败');
        return;
      }
      this.userForm.avatar = response.data;
      this.$message.success('头像上传成功');
    },
    submitUser() {
      if (!this.userForm.accountNumber || !this.userForm.nickname) {
        this.$message.warning('请填写用户账号和昵称');
        return;
      }
      if (!this.userEditing && !this.userForm.userPassword) {
        this.$message.warning('请填写登录密码');
        return;
      }
      const payload = {
        id: this.userForm.id,
        accountNumber: this.userForm.accountNumber,
        nickname: this.userForm.nickname,
        avatar: this.userForm.avatar || '',
        userStatus: Number(this.userForm.userStatus),
      };
      if (this.userForm.userPassword) {
        payload.userPassword = this.userForm.userPassword;
      }

      const request = this.userEditing
        ? this.$api.updateAdminUser(payload)
        : this.$api.addAdminUser(payload);

      this.tableLoading = true;
      request
        .then((res) => {
          if (res.status_code !== 1) {
            this.$message.error(res.msg || '保存失败');
            return;
          }
          this.$message.success(this.userEditing ? '用户更新成功' : '用户新增成功');
          this.userDialogVisible = false;
          this.refreshCurrent();
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    submitAdmin() {
      if (!this.adminForm.adminName || !this.adminForm.accountNumber) {
        this.$message.warning('请填写管理员名称和账号');
        return;
      }
      if (!this.adminEditing && !this.adminForm.adminPassword) {
        this.$message.warning('请填写管理员密码');
        return;
      }
      const payload = {
        id: this.adminForm.id,
        adminName: this.adminForm.adminName,
        accountNumber: this.adminForm.accountNumber,
      };
      if (this.adminForm.adminPassword) {
        payload.adminPassword = this.adminForm.adminPassword;
      }

      const request = this.adminEditing
        ? this.$api.updateAdministrator(payload)
        : this.$api.regAdministrator(payload);

      this.tableLoading = true;
      request
        .then((res) => {
          if (res.status_code !== 1) {
            this.$message.error(res.msg || '保存失败');
            return;
          }
          this.$message.success(this.adminEditing ? '管理员更新成功' : '管理员新增成功');
          this.adminDialogVisible = false;
          this.loadAdmins();
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    updateUserStatus(row, status) {
      const actionText = status === 1 ? '封禁' : '解封';
      this.$confirm(`确认${actionText}该用户吗？`, '系统提示', {
        confirmButtonClass: status === 1 ? 'el-button--danger' : '',
        type: status === 1 ? 'warning' : 'success',
      }).then(() => {
        this.tableLoading = true;
        this.$api
          .updateUserStatus({ id: row.id, status })
          .then((res) => {
            if (res.status_code !== 1) {
              this.$message.error(res.msg || `${actionText}失败`);
              return;
            }
            this.$message.success(`${actionText}成功`);
            this.refreshCurrent();
          })
          .finally(() => {
            this.tableLoading = false;
          });
      });
    },
    confirmDelete(row) {
      const isAdmin = this.mode === 3;
      const message = isAdmin ? '确认删除该管理员吗？' : '确认删除该用户吗？';
      this.$confirm(message, '系统提示', {
        confirmButtonClass: 'el-button--danger',
        type: 'warning',
      }).then(() => {
        this.tableLoading = true;
        const request = isAdmin
          ? this.$api.deleteAdministrator({ id: row.id })
          : this.$api.deleteAdminUser({ id: row.id });
        request
          .then((res) => {
            if (res.status_code !== 1) {
              this.$message.error(res.msg || '删除失败');
              return;
            }
            this.$message.success('删除成功');
            this.refreshCurrent();
          })
          .finally(() => {
            this.tableLoading = false;
          });
      });
    },
  },
};
</script>

<style scoped>
.management-panel {
  display: flex;
  flex-direction: column;
  min-height: calc(100vh - 120px);
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  margin-bottom: 32px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 12px;
}

.panel-title {
  font-size: 24px;
  font-weight: 800;
  color: var(--text-primary);
}

.panel-subtitle {
  margin-top: 4px;
  font-size: 14px;
  color: var(--text-tertiary);
}

.search-box-v2 {
  display: flex;
  align-items: center;
  width: 320px;
  padding: 4px 4px 4px 16px;
  border: 1px solid #e2e8f0;
  border-radius: var(--radius-md);
  background: #f8fafc;
}

.search-box-v2 input {
  flex: 1;
  border: none;
  outline: none;
  background: transparent;
  padding: 8px 12px;
  font-size: 14px;
}

.premium-add-btn {
  height: 44px;
  padding: 0 20px !important;
  border-radius: var(--radius-md) !important;
}

.modern-tabs {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}

.tab-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border-radius: var(--radius-md);
  color: var(--text-secondary);
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s;
}

.tab-item:hover {
  background: #f1f5f9;
}

.tab-item.active {
  background: var(--brand-primary-light);
  color: var(--brand-primary);
}

.table-wrapper {
  flex: 1;
}

.user-main-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.avatar-wrapper {
  width: 44px;
  height: 44px;
  overflow: hidden;
  border-radius: 50%;
  border: 2px solid white;
  box-shadow: var(--shadow-soft);
}

.avatar-wrapper img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.name-box {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.u-nickname {
  font-size: 14px;
  font-weight: 700;
  color: var(--text-primary);
}

.u-account {
  font-size: 12px;
  color: var(--text-tertiary);
}

.time-cell {
  display: flex;
  align-items: center;
  gap: 6px;
  color: var(--text-secondary);
}

.status-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 4px 12px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 700;
}

.s-success {
  background: #ecfdf5;
  color: #059669;
}

.s-danger {
  background: #fef2f2;
  color: #dc2626;
}

.admin-account-tag {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 6px;
  background: var(--brand-primary-light);
  color: var(--brand-primary);
  font-family: 'JetBrains Mono', monospace;
  font-weight: 600;
}

.admin-role-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 6px 14px;
  border-radius: 999px;
  background: #ecfdf5;
  color: #059669;
  font-weight: 700;
}

.action-btns {
  display: flex;
  justify-content: center;
  gap: 8px;
  flex-wrap: wrap;
}

.btn-edit {
  background: #eff6ff !important;
  border: none !important;
  color: #2563eb !important;
}

.btn-danger-soft {
  background: #fff1f2 !important;
  border: none !important;
  color: #f43f5e !important;
}

.btn-success-soft {
  background: #ecfdf5 !important;
  border: none !important;
  color: #10b981 !important;
}

.btn-delete {
  background: #fef2f2 !important;
  border: none !important;
  color: #ef4444 !important;
}

.panel-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 32px;
  padding-top: 24px;
  border-top: 1px solid #f1f5f9;
}

.total-info {
  font-size: 13px;
  color: var(--text-tertiary);
}

.dialog-form {
  display: flex;
  flex-direction: column;
  gap: 18px;
}

.double-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
}

.input-group label {
  display: block;
  margin-bottom: 8px;
  color: var(--text-secondary);
  font-size: 12px;
  font-weight: 700;
}

.dialog-btns {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
}

@media (max-width: 1024px) {
  .panel-header,
  .header-right {
    flex-direction: column;
    align-items: stretch;
  }

  .search-box-v2 {
    width: 100%;
  }

  .double-grid {
    grid-template-columns: 1fr;
  }
}
</style>
