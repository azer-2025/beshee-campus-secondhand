<template>
    <div class="premium-card management-panel">
        <div class="panel-header">
            <div class="header-left">
                <h2 class="panel-title">平台用户权限中心</h2>
                <p class="panel-subtitle">管理普通用户、封禁名单以及后台管理员账号</p>
            </div>
            <div class="header-right">
                <div class="search-box-v2">
                    <i class="el-icon-search search-icon"></i>
                    <input
                        v-model.trim="searchValue"
                        :placeholder="searchPlaceholder"
                        type="text"
                        @keyup.enter="searchList"
                    />
                    <el-button type="primary" size="small" @click="searchList">搜索</el-button>
                </div>
                <el-button
                    v-if="mode === 3"
                    type="primary"
                    class="premium-add-btn"
                    @click="openCreateDialog"
                >
                    <i class="el-icon-plus"></i>
                    <span>新增管理员</span>
                </el-button>
            </div>
        </div>

        <div class="modern-tabs">
            <div
                :class="['tab-item', activeTab === '1' ? 'active' : '']"
                @click="switchTab('1')"
            >
                <i class="el-icon-user"></i>
                <span>常规用户</span>
            </div>
            <div
                :class="['tab-item', activeTab === '2' ? 'active' : '']"
                @click="switchTab('2')"
            >
                <i class="el-icon-lock"></i>
                <span>封禁列表</span>
            </div>
            <div
                :class="['tab-item', activeTab === '3' ? 'active' : '']"
                @click="switchTab('3')"
            >
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
                empty-text="暂无数据"
            >
                <el-table-column v-if="mode !== 3" label="账户概览" min-width="260">
                    <template #default="{ row }">
                        <div class="user-main-info">
                            <div class="avatar-wrapper">
                                <img :src="row.avatar || defaultAvatar" alt="avatar" />
                            </div>
                            <div class="name-box">
                                <span class="u-nickname">{{ row.nickname }}</span>
                                <span class="u-account">ID: {{ row.accountNumber }}</span>
                            </div>
                        </div>
                    </template>
                </el-table-column>

                <template v-else>
                    <el-table-column prop="accountNumber" label="管理员账号" min-width="220">
                        <template #default="{ row }">
                            <span class="admin-account-tag">@{{ row.accountNumber }}</span>
                        </template>
                    </el-table-column>
                    <el-table-column prop="adminName" label="管理员名称" min-width="220">
                        <template #default="{ row }">
                            <div class="admin-role-badge">
                                <i class="el-icon-medal"></i>
                                <span>{{ row.adminName }}</span>
                            </div>
                        </template>
                    </el-table-column>
                </template>

                <el-table-column v-if="mode !== 3" prop="signInTime" label="加入时间" min-width="220">
                    <template #default="{ row }">
                        <div class="time-cell">
                            <i class="el-icon-time"></i>
                            <span>{{ formatDateTime(row.signInTime) }}</span>
                        </div>
                    </template>
                </el-table-column>

                <el-table-column
                    v-if="mode !== 3"
                    label="账户控制"
                    width="160"
                    align="center"
                >
                    <template #default="{ row }">
                        <el-button
                            v-if="mode === 1"
                            size="small"
                            class="btn-danger-soft"
                            @click="confirmSealUser(row)"
                        >
                            <i class="el-icon-lock"></i> 封禁账户
                        </el-button>
                        <el-button
                            v-else
                            size="small"
                            class="btn-success-soft"
                            @click="confirmUnsealUser(row)"
                        >
                            <i class="el-icon-unlock"></i> 恢复正常
                        </el-button>
                    </template>
                </el-table-column>

                <el-table-column
                    v-if="mode === 3"
                    label="操作"
                    width="220"
                    align="center"
                >
                    <template #default="{ row }">
                        <div class="admin-actions">
                            <el-button size="small" class="btn-edit-soft" @click="openEditDialog(row)">
                                编辑
                            </el-button>
                            <el-button size="small" class="btn-danger-soft" @click="confirmDeleteAdmin(row)">
                                删除
                            </el-button>
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
            v-model="adminDialogVisible"
            :title="isEditingAdmin ? '编辑管理员' : '新增管理员'"
            width="460px"
            class="premium-dialog"
            append-to-body
            @close="resetAdminForm"
        >
            <div class="dialog-form-v2">
                <div class="input-group">
                    <label>管理员名称</label>
                    <el-input v-model.trim="adminForm.adminName" placeholder="例如：内容审核员" />
                </div>
                <div class="input-group">
                    <label>登录账号</label>
                    <el-input v-model.trim="adminForm.accountNumber" placeholder="请输入管理员账号" />
                </div>
                <div class="input-group">
                    <label>{{ isEditingAdmin ? '重置密码' : '登录密码' }}</label>
                    <el-input
                        v-model.trim="adminForm.adminPassword"
                        type="password"
                        show-password
                        :placeholder="isEditingAdmin ? '不修改可留空' : '请输入管理员密码'"
                    />
                </div>
                <div class="input-group">
                    <label>{{ isEditingAdmin ? '确认新密码' : '确认密码' }}</label>
                    <el-input
                        v-model.trim="adminForm.adminRePassword"
                        type="password"
                        show-password
                        :placeholder="isEditingAdmin ? '不修改可留空' : '请再次输入管理员密码'"
                    />
                </div>
            </div>
            <template #footer>
                <div class="dialog-btns">
                    <el-button @click="adminDialogVisible = false" class="btn-secondary">取消</el-button>
                    <el-button type="primary" class="btn-primary-gradient" @click="submitAdminForm">
                        {{ isEditingAdmin ? '保存修改' : '确认新增' }}
                    </el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<script>
export default {
    name: 'userList',
    data() {
        return {
            mode: 1,
            activeTab: '1',
            nowPage: 1,
            total: 0,
            tableLoading: false,
            searchValue: '',
            userData: [],
            badUserData: [],
            adminData: [],
            currentAdminId: null,
            adminDialogVisible: false,
            isEditingAdmin: false,
            adminForm: {
                id: null,
                adminName: '',
                accountNumber: '',
                adminPassword: '',
                adminRePassword: ''
            },
            defaultAvatar: 'https://cube.elemecdn.com/e/fd/0fc7d20532fdaf769a25683617711png.png',
            headerStyle: {
                background: '#f8fafc',
                color: '#64748b',
                fontWeight: '700',
                fontSize: '12px',
                borderBottom: '1px solid #e2e8f0'
            }
        };
    },
    computed: {
        currentTableData() {
            if (this.mode === 1) {
                return this.userData;
            }
            if (this.mode === 2) {
                return this.badUserData;
            }
            return this.adminData;
        },
        searchPlaceholder() {
            if (this.mode === 3) {
                return '搜索管理员账号或名称...';
            }
            return '搜索用户账号或昵称...';
        }
    },
    created() {
        this.fetchCurrentAdmin();
        this.refreshCurrentTab();
    },
    methods: {
        fetchCurrentAdmin() {
            this.$api.getCurrentAdmin().then(res => {
                if (res.status_code === 1 && res.data) {
                    this.currentAdminId = res.data.id;
                }
            }).catch(() => {});
        },
        formatDateTime(value) {
            if (!value) {
                return '-';
            }
            return value.length >= 19 ? value.substring(0, 19).replace('T', ' ') : value;
        },
        switchTab(name) {
            if (this.activeTab === name) {
                return;
            }
            this.activeTab = name;
            this.mode = Number.parseInt(name, 10);
            this.nowPage = 1;
            this.searchValue = '';
            this.refreshCurrentTab();
        },
        refreshCurrentTab() {
            if (this.mode === 1) {
                this.getUserData();
                return;
            }
            if (this.mode === 2) {
                this.getBadUserData();
                return;
            }
            this.getAdminData();
        },
        getUserData() {
            this.tableLoading = true;
            this.$api.getUserData({ page: this.nowPage, nums: 8, status: 0 }).then(res => {
                if (res.status_code === 1) {
                    this.userData = res.data.list || [];
                    this.total = res.data.count || 0;
                }
            }).finally(() => {
                this.tableLoading = false;
            });
        },
        getBadUserData() {
            this.tableLoading = true;
            this.$api.getUserData({ page: this.nowPage, nums: 8, status: 1 }).then(res => {
                if (res.status_code === 1) {
                    this.badUserData = res.data.list || [];
                    this.total = res.data.count || 0;
                }
            }).finally(() => {
                this.tableLoading = false;
            });
        },
        getAdminData() {
            this.tableLoading = true;
            this.$api.getUserManage({ page: this.nowPage, nums: 8 }).then(res => {
                if (res.status_code === 1) {
                    this.adminData = res.data.list || [];
                    this.total = res.data.count || 0;
                }
            }).finally(() => {
                this.tableLoading = false;
            });
        },
        searchList() {
            if (!this.searchValue) {
                this.nowPage = 1;
                this.refreshCurrentTab();
                return;
            }

            this.tableLoading = true;
            this.$api.queryUser({
                searchValue: this.searchValue,
                mode: this.mode,
                page: this.nowPage,
                nums: 8
            }).then(res => {
                if (res.status_code === 1) {
                    if (this.mode === 1) {
                        this.userData = res.data.list || [];
                    } else if (this.mode === 2) {
                        this.badUserData = res.data.list || [];
                    } else {
                        this.adminData = res.data.list || [];
                    }
                    this.total = res.data.count || 0;
                }
            }).finally(() => {
                this.tableLoading = false;
            });
        },
        handleCurrentChange(val) {
            this.nowPage = val;
            if (this.searchValue) {
                this.searchList();
                return;
            }
            this.refreshCurrentTab();
        },
        confirmSealUser(row) {
            this.$confirm('确定要封禁该用户吗？封禁后该用户将无法继续登录。', '操作确认', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                confirmButtonClass: 'el-button--danger',
                type: 'warning'
            }).then(() => {
                this.tableLoading = true;
                this.$api.updateUserStatus({ id: row.id, status: 1 }).then(res => {
                    if (res.status_code === 1) {
                        this.$message.success('用户已封禁');
                        this.refreshCurrentTab();
                    } else {
                        this.$message.error(res.msg || '操作失败');
                    }
                }).finally(() => {
                    this.tableLoading = false;
                });
            }).catch(() => {});
        },
        confirmUnsealUser(row) {
            this.$confirm('确定恢复该用户账号吗？恢复后将重新获得正常权限。', '操作确认', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'success'
            }).then(() => {
                this.tableLoading = true;
                this.$api.updateUserStatus({ id: row.id, status: 0 }).then(res => {
                    if (res.status_code === 1) {
                        this.$message.success('用户已恢复正常');
                        this.refreshCurrentTab();
                    } else {
                        this.$message.error(res.msg || '操作失败');
                    }
                }).finally(() => {
                    this.tableLoading = false;
                });
            }).catch(() => {});
        },
        openCreateDialog() {
            this.isEditingAdmin = false;
            this.adminDialogVisible = true;
        },
        openEditDialog(row) {
            this.isEditingAdmin = true;
            this.adminForm = {
                id: row.id,
                adminName: row.adminName || '',
                accountNumber: row.accountNumber || '',
                adminPassword: '',
                adminRePassword: ''
            };
            this.adminDialogVisible = true;
        },
        resetAdminForm() {
            this.adminDialogVisible = false;
            this.isEditingAdmin = false;
            this.adminForm = {
                id: null,
                adminName: '',
                accountNumber: '',
                adminPassword: '',
                adminRePassword: ''
            };
        },
        validateAdminForm() {
            if (!this.adminForm.adminName || !this.adminForm.accountNumber) {
                this.$message.warning('请完整填写管理员名称和账号');
                return false;
            }

            const hasPasswordInput = Boolean(this.adminForm.adminPassword || this.adminForm.adminRePassword);
            if (!this.isEditingAdmin && !hasPasswordInput) {
                this.$message.warning('请填写管理员密码');
                return false;
            }

            if (hasPasswordInput && this.adminForm.adminPassword !== this.adminForm.adminRePassword) {
                this.$message.error('两次输入的密码不一致');
                return false;
            }

            return true;
        },
        submitAdminForm() {
            if (!this.validateAdminForm()) {
                return;
            }

            const payload = {
                id: this.adminForm.id,
                adminName: this.adminForm.adminName,
                accountNumber: this.adminForm.accountNumber,
                adminPassword: this.adminForm.adminPassword
            };

            const request = this.isEditingAdmin
                ? this.$api.updateAdministrator(payload)
                : this.$api.regAdministrator(payload);

            this.tableLoading = true;
            request.then(res => {
                if (res.status_code !== 1) {
                    this.$message.error(res.msg || (this.isEditingAdmin ? '管理员更新失败' : '管理员新增失败'));
                    return;
                }

                if (this.isEditingAdmin) {
                    this.$message.success('管理员信息已更新');
                    if (this.currentAdminId && this.currentAdminId === this.adminForm.id) {
                        this.$sta.adminName = this.adminForm.adminName;
                        sessionStorage.setItem('admin_name', this.adminForm.adminName);
                        window.dispatchEvent(new CustomEvent('admin-profile-updated', {
                            detail: {
                                adminName: this.adminForm.adminName
                            }
                        }));
                    }
                } else {
                    this.$message.success('管理员已新增');
                }

                this.resetAdminForm();
                this.nowPage = 1;
                if (this.searchValue) {
                    this.searchList();
                } else {
                    this.getAdminData();
                }
            }).finally(() => {
                this.tableLoading = false;
            });
        },
        confirmDeleteAdmin(row) {
            const deletingSelf = this.currentAdminId && this.currentAdminId === row.id;
            const message = deletingSelf
                ? '确定删除当前登录的管理员账号吗？删除后将立即退出后台。'
                : `确定删除管理员“${row.adminName}”吗？此操作不可恢复。`;

            this.$confirm(message, '删除确认', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.tableLoading = true;
                this.$api.deleteAdministrator({ id: row.id }).then(res => {
                    if (res.status_code !== 1) {
                        this.$message.error(res.msg || '管理员删除失败');
                        return;
                    }

                    if (res.data === 'logout') {
                        this.$sta.isLogin = false;
                        this.$sta.adminName = '';
                        sessionStorage.removeItem('admin_is_login');
                        sessionStorage.removeItem('admin_name');
                        this.$message.success('当前管理员已删除，请重新登录');
                        this.$router.replace({ path: '/login-admin' });
                        return;
                    }

                    this.$message.success('管理员已删除');
                    if (this.currentTableData.length === 1 && this.nowPage > 1) {
                        this.nowPage -= 1;
                    }
                    if (this.searchValue) {
                        this.searchList();
                    } else {
                        this.getAdminData();
                    }
                }).finally(() => {
                    this.tableLoading = false;
                });
            }).catch(() => {});
        }
    }
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
    align-items: flex-start;
    gap: 16px;
    margin-bottom: 32px;
}

.panel-title {
    font-size: 24px;
    font-weight: 800;
    color: var(--text-primary);
}

.panel-subtitle {
    margin-top: 6px;
    font-size: 14px;
    color: var(--text-tertiary);
}

.header-right {
    display: flex;
    align-items: center;
    gap: 12px;
}

.search-box-v2 {
    display: flex;
    align-items: center;
    background: #f8fafc;
    border: 1px solid #e2e8f0;
    border-radius: var(--radius-md);
    padding: 4px 4px 4px 16px;
    width: 320px;
}

.search-box-v2 input {
    border: none;
    background: transparent;
    flex: 1;
    padding: 8px 12px;
    font-size: 14px;
    outline: none;
}

.premium-add-btn {
    height: 44px;
    padding: 0 24px !important;
    border-radius: var(--radius-md) !important;
}

.modern-tabs {
    display: flex;
    gap: 12px;
    margin-bottom: 24px;
    flex-wrap: wrap;
}

.tab-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 10px 20px;
    border-radius: var(--radius-md);
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    color: var(--text-secondary);
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
    border-radius: 50%;
    overflow: hidden;
    border: 2px solid white;
    box-shadow: var(--shadow-soft);
    flex-shrink: 0;
}

.avatar-wrapper img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.name-box {
    display: flex;
    flex-direction: column;
}

.u-nickname {
    font-weight: 700;
    color: var(--text-primary);
    font-size: 14px;
}

.u-account {
    font-size: 11px;
    color: var(--text-tertiary);
    font-family: monospace;
}

.admin-account-tag {
    display: inline-flex;
    align-items: center;
    font-family: 'JetBrains Mono', monospace;
    font-weight: 600;
    color: var(--brand-primary);
    background: var(--brand-primary-light);
    padding: 4px 10px;
    border-radius: 6px;
}

.admin-role-badge {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: #059669;
    font-weight: 700;
    background: #ecfdf5;
    padding: 6px 14px;
    border-radius: 20px;
}

.time-cell {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    color: var(--text-secondary);
}

.admin-actions {
    display: flex;
    justify-content: center;
    gap: 8px;
}

.btn-danger-soft {
    background: #fff1f2 !important;
    border: none !important;
    color: #f43f5e !important;
    font-weight: 700 !important;
}

.btn-success-soft {
    background: #ecfdf5 !important;
    border: none !important;
    color: #10b981 !important;
    font-weight: 700 !important;
}

.btn-edit-soft {
    background: #eff6ff !important;
    border: none !important;
    color: #2563eb !important;
    font-weight: 700 !important;
}

.panel-footer {
    margin-top: 32px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding-top: 24px;
    border-top: 1px solid #f1f5f9;
}

.total-info {
    font-size: 13px;
    color: var(--text-tertiary);
}

.dialog-form-v2 {
    display: flex;
    flex-direction: column;
    gap: 18px;
}

.input-group label {
    display: block;
    font-size: 12px;
    font-weight: 800;
    text-transform: uppercase;
    color: var(--text-tertiary);
    margin-bottom: 8px;
    letter-spacing: 0.05em;
}

.dialog-btns {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
}

.btn-primary-gradient {
    background: var(--brand-gradient) !important;
    border: none !important;
    color: white !important;
    box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3) !important;
}

@media (max-width: 1024px) {
    .panel-header,
    .header-right,
    .panel-footer {
        flex-direction: column;
        align-items: stretch;
    }

    .search-box-v2 {
        width: 100%;
    }
}
</style>
