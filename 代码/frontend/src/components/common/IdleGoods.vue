<template>
    <div class="premium-card management-panel">
        <div class="panel-header">
            <div class="header-left">
                <h2 class="panel-title">二手手机管理</h2>
                <p class="panel-subtitle">支持后台商品新增、编辑、上下架、删除和搜索</p>
            </div>
            <div class="header-right">
                <div class="search-box-v2">
                    <i class="el-icon-search search-icon"></i>
                    <input
                        v-model.trim="findValue"
                        type="text"
                        placeholder="按手机名称或描述搜索"
                        @keyup.enter="searchIdle"
                    />
                    <el-button type="primary" size="small" @click="searchIdle">搜索</el-button>
                </div>
                <el-button type="primary" class="premium-add-btn" @click="openCreateDialog">
                    <i class="el-icon-plus"></i>
                    <span>新增商品</span>
                </el-button>
            </div>
        </div>

        <div class="modern-tabs">
            <div :class="['tab-item', activeTab === '1' ? 'active' : '']" @click="switchTab('1')">
                <i class="el-icon-circle-check"></i>
                <span>上架中（{{ activeTab === '1' ? total : '-' }}）</span>
            </div>
            <div :class="['tab-item', activeTab === '2' ? 'active' : '']" @click="switchTab('2')">
                <i class="el-icon-warning-outline"></i>
                <span>已下架（{{ activeTab === '2' ? total : '-' }}）</span>
            </div>
        </div>

        <div class="table-wrapper" v-loading="tableLoading">
            <el-table
                :data="currentTableData"
                class="premium-table"
                style="width: 100%"
                :header-cell-style="headerStyle"
                empty-text="暂无商品数据"
            >
                <el-table-column label="预览" width="110">
                    <template #default="{ row }">
                        <el-image
                            v-if="row.previewImage"
                            :src="row.previewImage"
                            fit="cover"
                            class="goods-preview-image"
                        >
                            <template #error>
                                <div class="goods-preview"><i class="el-icon-picture-outline"></i></div>
                            </template>
                        </el-image>
                        <div v-else class="goods-preview"><i class="el-icon-picture-outline"></i></div>
                    </template>
                </el-table-column>

                <el-table-column prop="idleName" label="商品名称" min-width="260" show-overflow-tooltip>
                    <template #default="{ row }">
                        <div class="goods-info">
                            <span class="g-name">{{ row.idleName }}</span>
                            <span class="g-date">{{ formatDateTime(row.releaseTime) }} 发布</span>
                        </div>
                    </template>
                </el-table-column>

                <el-table-column label="发布者" min-width="200">
                    <template #default="{ row }">
                        <div class="user-chip">
                            <div class="avatar-sm">{{ row.user?.nickname?.charAt(0) || '用' }}</div>
                            <div class="publisher-meta">
                                <span>{{ row.user?.nickname || '未知用户' }}</span>
                                <small>{{ row.user?.accountNumber || '-' }}</small>
                            </div>
                        </div>
                    </template>
                </el-table-column>

                <el-table-column prop="idlePlace" label="发货地区" min-width="200" show-overflow-tooltip />

                <el-table-column prop="idlePrice" label="当前标价" width="140">
                    <template #default="{ row }">
                        <div class="price-cell"><small>¥</small><span>{{ row.idlePrice }}</span></div>
                    </template>
                </el-table-column>

                <el-table-column label="操作" min-width="260" align="center">
                    <template #default="{ row }">
                        <div class="action-btns">
                            <el-button size="small" class="btn-edit-soft" @click="openEditDialog(row)">编辑</el-button>
                            <el-button
                                v-if="activeTab === '1'"
                                size="small"
                                class="btn-warning-soft"
                                @click="confirmOfflineGoods(row)"
                            >
                                下架
                            </el-button>
                            <el-button
                                v-else
                                size="small"
                                class="btn-success-soft"
                                @click="confirmOnlineGoods(row)"
                            >
                                上架
                            </el-button>
                            <el-button size="small" class="btn-danger-soft" @click="confirmDeleteGoods(row)">
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
            v-model="goodsDialogVisible"
            :title="isEditing ? '编辑商品' : '新增商品'"
            width="760px"
            class="premium-dialog"
            append-to-body
            @close="resetDialogForm"
        >
            <el-form label-position="top" class="goods-form">
                <el-row :gutter="16">
                    <el-col :span="12">
                        <el-form-item label="发布者账号">
                            <el-input v-model.trim="goodsForm.userAccountNumber" placeholder="请输入用户账号" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="商品分类">
                            <el-select v-model="goodsForm.idleLabel" placeholder="请选择分类" style="width: 100%">
                                <el-option v-for="item in categoryOptions" :key="item.value" :label="item.label" :value="item.value" />
                            </el-select>
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-form-item label="商品名称">
                    <el-input v-model.trim="goodsForm.idleName" maxlength="30" show-word-limit placeholder="请输入商品标题" />
                </el-form-item>

                <el-form-item label="商品描述">
                    <el-input
                        v-model="goodsForm.idleDetails"
                        type="textarea"
                        :rows="4"
                        maxlength="1000"
                        show-word-limit
                        placeholder="请输入商品详情"
                    />
                </el-form-item>

                <el-row :gutter="16">
                    <el-col :span="12">
                        <el-form-item label="商品价格">
                            <el-input-number v-model="goodsForm.idlePrice" :min="0" :precision="2" :step="10" style="width: 100%" />
                        </el-form-item>
                    </el-col>
                    <el-col :span="12">
                        <el-form-item label="发货地区">
                            <el-cascader
                                v-model="selectedOptions"
                                :options="areaOptions"
                                :separator="' / '"
                                placeholder="请选择省 / 市 / 区"
                                style="width: 100%"
                                @change="handlePlaceChange"
                            />
                        </el-form-item>
                    </el-col>
                </el-row>

                <el-form-item label="商品图片">
                    <el-upload
                        :action="uploadAction"
                        :show-file-list="false"
                        accept="image/*"
                        multiple
                        drag
                        class="upload-area"
                        :on-success="handleUploadSuccess"
                        :on-error="handleUploadError"
                    >
                        <i class="el-icon-upload"></i>
                        <div class="el-upload__text">拖拽图片到此处，或 <em>点击上传</em></div>
                    </el-upload>

                    <div v-if="imageList.length > 0" class="image-preview-list">
                        <div v-for="(img, index) in imageList" :key="`${img}-${index}`" class="preview-card">
                            <el-image :src="img" fit="cover" class="preview-image" :preview-src-list="imageList" />
                            <el-button
                                type="danger"
                                circle
                                size="small"
                                class="delete-image-btn"
                                @click="removeImage(index)"
                            >
                                <i class="el-icon-close"></i>
                            </el-button>
                        </div>
                    </div>
                </el-form-item>
            </el-form>

            <template #footer>
                <div class="dialog-btns">
                    <el-button @click="goodsDialogVisible = false">取消</el-button>
                    <el-button type="primary" class="btn-primary-gradient" :loading="dialogSubmitting" @click="submitGoodsForm">
                        {{ isEditing ? '保存修改' : '确认新增' }}
                    </el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<script>
import { pcaTextArr } from 'element-china-area-data';

const uploadAction = import.meta.env.DEV
    ? '/api/file'
    : `${(import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080').replace(/\/$/, '')}/file`;

const createDefaultGoodsForm = () => ({
    id: null,
    userAccountNumber: '',
    idleName: '',
    idleDetails: '',
    idlePrice: 0,
    idlePlace: '',
    idleLabel: '',
    idleStatus: 1
});

export default {
    name: 'IdleGoods',
    data() {
        return {
            uploadAction,
            activeTab: '1',
            nowPage: 1,
            total: 0,
            onlineGoods: [],
            offlineGoods: [],
            findValue: '',
            tableLoading: false,
            goodsDialogVisible: false,
            dialogSubmitting: false,
            isEditing: false,
            goodsForm: createDefaultGoodsForm(),
            imageList: [],
            selectedOptions: [],
            areaOptions: pcaTextArr,
            categoryOptions: [
                { value: 1, label: '安卓手机' },
                { value: 2, label: '苹果手机' },
                { value: 3, label: '游戏手机' },
                { value: 4, label: '折叠屏手机' },
                { value: 5, label: '手机配件' },
                { value: 6, label: '其他手机' }
            ],
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
            return this.activeTab === '1' ? this.onlineGoods : this.offlineGoods;
        }
    },
    created() {
        this.fetchCurrentTabData();
    },
    methods: {
        formatDateTime(value) {
            if (!value) {
                return '-';
            }
            return String(value).replace('T', ' ').substring(0, 19);
        },
        normalizeGoodsList(list) {
            return (list || []).map(item => {
                let previewImage = '';
                let pictureArray = [];
                try {
                    pictureArray = JSON.parse(item.pictureList || '[]');
                    previewImage = Array.isArray(pictureArray) && pictureArray.length > 0 ? pictureArray[0] : '';
                } catch (error) {
                    console.log('Failed to parse pictureList:', error);
                }

                return {
                    ...item,
                    pictureArray,
                    previewImage
                };
            });
        },
        switchTab(name) {
            if (this.activeTab === name) {
                return;
            }
            this.activeTab = name;
            this.nowPage = 1;
            this.findValue = '';
            this.fetchCurrentTabData();
        },
        fetchCurrentTabData() {
            if (this.activeTab === '1') {
                this.getOnlineGoods();
                return;
            }
            this.getOfflineGoods();
        },
        getOnlineGoods() {
            this.tableLoading = true;
            this.$api.getGoods({ status: 1, page: this.nowPage, nums: 8 }).then(res => {
                if (res.status_code === 1) {
                    this.onlineGoods = this.normalizeGoodsList(res.data.list);
                    this.total = res.data.count || 0;
                }
            }).finally(() => {
                this.tableLoading = false;
            });
        },
        getOfflineGoods() {
            this.tableLoading = true;
            this.$api.getGoods({ status: 2, page: this.nowPage, nums: 8 }).then(res => {
                if (res.status_code === 1) {
                    this.offlineGoods = this.normalizeGoodsList(res.data.list);
                    this.total = res.data.count || 0;
                }
            }).finally(() => {
                this.tableLoading = false;
            });
        },
        searchIdle() {
            if (!this.findValue) {
                this.nowPage = 1;
                this.fetchCurrentTabData();
                return;
            }
            this.tableLoading = true;
            this.$api.queryIdle({
                findValue: this.findValue,
                page: this.nowPage,
                nums: 8,
                status: Number.parseInt(this.activeTab, 10)
            }).then(res => {
                if (res.status_code === 1 && res.data) {
                    const normalizedList = this.normalizeGoodsList(res.data.list || []);
                    if (this.activeTab === '1') {
                        this.onlineGoods = normalizedList;
                    } else {
                        this.offlineGoods = normalizedList;
                    }
                    this.total = res.data.count || 0;
                }
            }).finally(() => {
                this.tableLoading = false;
            });
        },
        handleCurrentChange(val) {
            this.nowPage = val;
            if (this.findValue) {
                this.searchIdle();
                return;
            }
            this.fetchCurrentTabData();
        },
        openCreateDialog() {
            this.isEditing = false;
            this.goodsDialogVisible = true;
        },
        openEditDialog(row) {
            this.isEditing = true;
            this.goodsForm = {
                id: row.id,
                userAccountNumber: row.user?.accountNumber || '',
                idleName: row.idleName || '',
                idleDetails: row.idleDetails || '',
                idlePrice: Number(row.idlePrice || 0),
                idlePlace: row.idlePlace || '',
                idleLabel: row.idleLabel || '',
                idleStatus: Number(row.idleStatus || 1)
            };
            this.imageList = Array.isArray(row.pictureArray) ? [...row.pictureArray] : [];
            this.selectedOptions = row.idlePlace ? row.idlePlace.split(' / ') : [];
            this.goodsDialogVisible = true;
        },
        resetDialogForm() {
            this.goodsDialogVisible = false;
            this.dialogSubmitting = false;
            this.isEditing = false;
            this.goodsForm = createDefaultGoodsForm();
            this.imageList = [];
            this.selectedOptions = [];
        },
        handlePlaceChange(value) {
            this.goodsForm.idlePlace = Array.isArray(value) ? value.join(' / ') : '';
        },
        handleUploadSuccess(response) {
            if (!response || response.status_code !== 1 || !response.data) {
                this.$message.error('图片上传失败');
                return;
            }
            this.imageList.push(response.data);
        },
        handleUploadError() {
            this.$message.error('图片上传失败，请稍后重试');
        },
        removeImage(index) {
            this.imageList.splice(index, 1);
        },
        validateGoodsForm() {
            if (!this.goodsForm.userAccountNumber) {
                this.$message.warning('请输入发布者账号');
                return false;
            }
            if (!this.goodsForm.idleName) {
                this.$message.warning('请输入商品名称');
                return false;
            }
            if (!this.goodsForm.idleDetails) {
                this.$message.warning('请输入商品描述');
                return false;
            }
            if (!this.goodsForm.idleLabel) {
                this.$message.warning('请选择商品分类');
                return false;
            }
            if (!this.goodsForm.idlePlace) {
                this.$message.warning('请选择发货地区');
                return false;
            }
            if (Number(this.goodsForm.idlePrice) <= 0) {
                this.$message.warning('请输入合理的商品价格');
                return false;
            }
            if (this.imageList.length === 0) {
                this.$message.warning('请至少上传一张商品图片');
                return false;
            }
            return true;
        },
        submitGoodsForm() {
            if (!this.validateGoodsForm()) {
                return;
            }

            const payload = {
                ...this.goodsForm,
                pictureList: JSON.stringify(this.imageList)
            };
            const request = this.isEditing
                ? this.$api.updateGoodsInfo(payload)
                : this.$api.createGoods(payload);

            this.dialogSubmitting = true;
            request.then(res => {
                if (res.status_code !== 1) {
                    this.$message.error(res.msg || (this.isEditing ? '商品更新失败' : '商品新增失败'));
                    return;
                }

                this.$message.success(this.isEditing ? '商品已更新' : '商品已新增');
                this.resetDialogForm();
                this.nowPage = 1;
                if (this.findValue) {
                    this.searchIdle();
                } else {
                    this.fetchCurrentTabData();
                }
            }).finally(() => {
                this.dialogSubmitting = false;
            });
        },
        confirmOfflineGoods(row) {
            this.$confirm('确定要下架这件商品吗？', '操作确认', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.tableLoading = true;
                this.$api.updateGoods({ id: row.id, status: 2 }).then(res => {
                    if (res.status_code === 1) {
                        this.$message.success('商品已下架');
                        this.fetchCurrentTabData();
                    }
                }).finally(() => {
                    this.tableLoading = false;
                });
            }).catch(() => {});
        },
        confirmOnlineGoods(row) {
            this.$confirm('确定重新上架这件商品吗？', '操作确认', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'success'
            }).then(() => {
                this.tableLoading = true;
                this.$api.updateGoods({ id: row.id, status: 1 }).then(res => {
                    if (res.status_code === 1) {
                        this.$message.success('商品已重新上架');
                        this.fetchCurrentTabData();
                    }
                }).finally(() => {
                    this.tableLoading = false;
                });
            }).catch(() => {});
        },
        confirmDeleteGoods(row) {
            this.$confirm('删除后不可恢复，确定继续吗？', '风险提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.tableLoading = true;
                this.$api.updateGoods({ id: row.id, status: 0 }).then(res => {
                    if (res.status_code === 1) {
                        this.$message.success('商品已删除');
                        if (this.currentTableData.length === 1 && this.nowPage > 1) {
                            this.nowPage -= 1;
                        }
                        this.fetchCurrentTabData();
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
    font-size: 14px;
    color: var(--text-tertiary);
    margin-top: 4px;
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
    color: var(--text-primary);
}

.search-box-v2:focus-within {
    border-color: var(--brand-primary);
    box-shadow: 0 0 0 3px var(--brand-primary-light);
    background: white;
}

.search-icon {
    color: var(--text-tertiary);
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

.goods-preview,
.goods-preview-image {
    width: 64px;
    height: 64px;
    border-radius: 14px;
    overflow: hidden;
    background: #f1f5f9;
}

.goods-preview {
    display: flex;
    align-items: center;
    justify-content: center;
    color: #cbd5e1;
    font-size: 24px;
}

.goods-info {
    display: flex;
    flex-direction: column;
    gap: 4px;
}

.g-name {
    font-weight: 700;
    color: var(--text-primary);
}

.g-date {
    font-size: 12px;
    color: var(--text-tertiary);
}

.user-chip {
    display: flex;
    align-items: center;
    gap: 10px;
}

.avatar-sm {
    width: 28px;
    height: 28px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: var(--brand-primary-light);
    color: var(--brand-primary);
    font-weight: 700;
}

.publisher-meta {
    display: flex;
    flex-direction: column;
    gap: 2px;
}

.publisher-meta small {
    color: var(--text-tertiary);
}

.price-cell {
    font-weight: 800;
    color: var(--brand-primary);
}

.action-btns {
    display: flex;
    justify-content: center;
    gap: 8px;
    flex-wrap: wrap;
}

.btn-edit-soft {
    background: #eff6ff !important;
    border: none !important;
    color: #2563eb !important;
}

.btn-warning-soft {
    background: #fffbeb !important;
    border: none !important;
    color: #d97706 !important;
}

.btn-success-soft {
    background: #ecfdf5 !important;
    border: none !important;
    color: #10b981 !important;
}

.btn-danger-soft {
    background: #fff1f2 !important;
    border: none !important;
    color: #f43f5e !important;
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
    font-size: 14px;
    color: var(--text-tertiary);
}

.goods-form {
    display: flex;
    flex-direction: column;
}

.upload-area {
    width: 100%;
}

.image-preview-list {
    margin-top: 16px;
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(110px, 1fr));
    gap: 12px;
    width: 100%;
}

.preview-card {
    position: relative;
}

.preview-image {
    width: 100%;
    height: 110px;
    border-radius: 14px;
    overflow: hidden;
}

.delete-image-btn {
    position: absolute;
    top: 6px;
    right: 6px;
}

.dialog-btns {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
}

.btn-primary-gradient {
    background: var(--brand-gradient) !important;
    border: none !important;
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
