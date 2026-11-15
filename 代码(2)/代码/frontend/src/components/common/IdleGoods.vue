<template>
  <div class="premium-card management-panel">
    <div class="panel-header">
      <div class="header-left">
        <h2 class="panel-title">闲置商品管理</h2>
        <p class="panel-subtitle">管理员可新增、编辑、下架、恢复或删除平台商品。</p>
      </div>
      <div class="header-right">
        <div class="search-box-v2">
          <i class="el-icon-search search-icon"></i>
          <input
            v-model="findValue"
            type="text"
            placeholder="按商品名称搜索"
            @keyup.enter="searchGoods"
          />
          <el-button type="primary" size="small" @click="searchGoods">搜索</el-button>
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
        <span>上架中</span>
      </div>
      <div :class="['tab-item', activeTab === '2' ? 'active' : '']" @click="switchTab('2')">
        <i class="el-icon-warning-outline"></i>
        <span>违规/下架</span>
      </div>
    </div>

    <div class="table-wrapper" v-loading="tableLoading">
      <el-table
        :data="tableData"
        class="premium-table"
        style="width: 100%"
        :header-cell-style="headerStyle"
      >
        <el-table-column label="商品预览" width="108">
          <template #default="scope">
            <div class="goods-preview">
              <el-image
                v-if="getPreviewImage(scope.row)"
                :src="getPreviewImage(scope.row)"
                fit="cover"
                class="goods-thumb"
              >
                <template #error>
                  <i class="el-icon-picture-outline"></i>
                </template>
              </el-image>
              <i v-else class="el-icon-picture-outline"></i>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="idleName" label="商品信息" min-width="320" show-overflow-tooltip>
          <template #default="scope">
            <div class="goods-info">
              <span class="g-name">{{ scope.row.idleName }}</span>
              <span class="g-desc">{{ scope.row.idleDetails || '暂无描述' }}</span>
              <span class="g-date">{{ scope.row.releaseTime || '-' }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="发布人" width="180">
          <template #default="scope">
            <div class="user-chip">
              <div class="avatar-sm">{{ (scope.row.user?.nickname || 'U').slice(0, 1) }}</div>
              <span>{{ scope.row.user?.nickname || `用户 #${scope.row.userId}` }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column prop="idlePrice" label="价格" width="120">
          <template #default="scope">
            <div class="price-cell">
              <small>¥</small>
              <span>{{ scope.row.idlePrice }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="操作" min-width="240" align="center">
          <template #default="scope">
            <div class="action-btns">
              <el-button size="small" class="btn-edit" @click="openEditDialog(scope.row)">编辑</el-button>
              <el-button
                v-if="activeTab === '1'"
                size="small"
                class="btn-danger-soft"
                @click="changeGoodsStatus(scope.row, 2, '确认下架该商品吗？')"
              >
                下架
              </el-button>
              <el-button
                v-else
                size="small"
                class="btn-success-soft"
                @click="changeGoodsStatus(scope.row, 1, '确认重新上架该商品吗？')"
              >
                恢复
              </el-button>
              <el-button
                size="small"
                class="btn-danger-bold"
                @click="changeGoodsStatus(scope.row, 0, '确认永久删除该商品吗？')"
              >
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
      v-model="dialogVisible"
      :title="editing ? '编辑商品' : '新增商品'"
      width="580px"
      class="premium-dialog"
      append-to-body
    >
      <div class="dialog-form">
        <div class="input-group">
          <label>商品名称</label>
          <el-input v-model="form.idleName" placeholder="例如：iPhone 15 Pro Max" />
        </div>

        <div class="double-grid">
          <div class="input-group">
            <label>价格</label>
            <el-input v-model="form.idlePrice" type="number" placeholder="0.00" />
          </div>
          <div class="input-group">
            <label>发布用户 ID</label>
            <el-input v-model="form.userId" type="number" placeholder="例如：6" />
          </div>
        </div>

        <div class="double-grid">
          <div class="input-group">
            <label>商品分类</label>
            <el-select v-model="form.idleLabel" placeholder="请选择分类" style="width: 100%">
              <el-option
                v-for="item in labelOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
          </div>
          <div class="input-group">
            <label>商品状态</label>
            <el-select v-model="form.idleStatus" placeholder="请选择状态" style="width: 100%">
              <el-option label="上架中" :value="1" />
              <el-option label="违规/下架" :value="2" />
              <el-option label="已删除" :value="0" />
            </el-select>
          </div>
        </div>

        <div class="input-group">
          <label>发货地点</label>
          <el-input v-model="form.idlePlace" placeholder="例如：湖北省 / 武汉市 / 洪山区" />
        </div>

        <div class="input-group">
          <label>商品详情</label>
          <el-input
            v-model="form.idleDetails"
            type="textarea"
            :rows="4"
            placeholder="填写商品详细描述"
          />
        </div>

        <div class="input-group">
          <label>商品图片</label>
          <div class="upload-container">
            <el-upload
              :action="uploadAction"
              list-type="picture-card"
              :file-list="fileList"
              accept="image/*"
              :on-success="handleUploadSuccess"
              :on-remove="handleRemove"
              :on-preview="handlePictureCardPreview"
            >
              <i class="el-icon-plus"></i>
            </el-upload>
            <el-dialog v-model="previewVisible" append-to-body>
              <img width="100%" :src="previewImage" alt="Preview" class="preview-img" />
            </el-dialog>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="dialog-btns">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitForm">
            {{ editing ? '保存修改' : '立即新增' }}
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import { resolveAssetUrl } from '../../utils/asset';

const uploadAction = import.meta.env.DEV
  ? '/api/file'
  : `${(import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080').replace(/\/$/, '')}/file`;

const labelOptions = [
  { label: '电子产品', value: 1 },
  { label: '衣物饰品', value: 2 },
  { label: '运动器材', value: 3 },
  { label: '图书音像', value: 4 },
  { label: '其他', value: 5 },
];

function createForm() {
  return {
    id: null,
    idleName: '',
    idleDetails: '',
    idlePrice: '',
    idlePlace: '',
    idleLabel: 1,
    userId: '',
    idleStatus: 1,
    pictureList: [],
    releaseTime: '',
  };
}

export default {
  name: 'IdleGoods',
  data() {
    return {
      uploadAction,
      labelOptions,
      activeTab: '1',
      nowPage: 1,
      total: 0,
      onlineGoods: [],
      offlineGoods: [],
      findValue: '',
      tableLoading: false,
      dialogVisible: false,
      editing: false,
      form: createForm(),
      fileList: [],
      previewImage: '',
      previewVisible: false,
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
    tableData() {
      return this.activeTab === '1' ? this.onlineGoods : this.offlineGoods;
    },
  },
  created() {
    this.refreshList();
  },
  methods: {
    normalizePictureList(value) {
      if (Array.isArray(value)) {
        return value.filter(Boolean);
      }
      if (!value) {
        return [];
      }
      try {
        const parsed = JSON.parse(value);
        return Array.isArray(parsed) ? parsed.filter(Boolean) : [];
      } catch (error) {
        return String(value)
          .split(/\r?\n|,/)
          .map((item) => item.trim())
          .filter(Boolean);
      }
    },
    getPreviewImage(item) {
      const pictureList = this.normalizePictureList(item.pictureList);
      return resolveAssetUrl(pictureList[0] || '', '');
    },
    refreshList() {
      if (this.findValue) {
        this.searchGoods();
        return;
      }
      this.fetchGoods(Number(this.activeTab));
    },
    fetchGoods(status) {
      this.tableLoading = true;
      this.$api
        .getGoods({ status, page: this.nowPage, nums: 8 })
        .then((res) => {
          if (res.status_code !== 1) {
            return;
          }
          const list = res.data?.list || [];
          const count = Number(res.data?.count || 0);
          if (status === 1) {
            this.onlineGoods = list;
          } else {
            this.offlineGoods = list;
          }
          this.total = Math.max(count, list.length);
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
      this.nowPage = 1;
      this.refreshList();
    },
    searchGoods() {
      if (!this.findValue) {
        this.fetchGoods(Number(this.activeTab));
        return;
      }
      this.tableLoading = true;
      this.$api
        .queryIdle({
          findValue: this.findValue,
          page: this.nowPage,
          nums: 8,
          status: Number(this.activeTab),
        })
        .then((res) => {
          if (res.status_code !== 1) {
            return;
          }
          const list = res.data?.list || [];
          const count = Number(res.data?.count || 0);
          if (this.activeTab === '1') {
            this.onlineGoods = list;
          } else {
            this.offlineGoods = list;
          }
          this.total = Math.max(count, list.length);
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    handleCurrentChange(val) {
      this.nowPage = val;
      this.refreshList();
    },
    openCreateDialog() {
      this.editing = false;
      this.form = createForm();
      this.fileList = [];
      this.dialogVisible = true;
    },
    openEditDialog(row) {
      this.editing = true;
      const pictureList = this.normalizePictureList(row.pictureList);
      this.form = {
        id: row.id,
        idleName: row.idleName || '',
        idleDetails: row.idleDetails || '',
        idlePrice: row.idlePrice ?? '',
        idlePlace: row.idlePlace || '',
        idleLabel: Number(row.idleLabel ?? 1),
        userId: row.userId ?? '',
        idleStatus: Number(row.idleStatus ?? 1),
        pictureList: pictureList,
        releaseTime: row.releaseTime || '',
      };
      this.fileList = pictureList.map(url => ({
        name: url.split('=').pop(),
        url: resolveAssetUrl(url)
      }));
      this.dialogVisible = true;
    },
    handleUploadSuccess(response) {
      if (response.status_code !== 1) {
        this.$message.error(response.msg || '图片上传失败');
        return;
      }
      const url = response.data;
      this.form.pictureList.push(url);
      this.fileList.push({
        name: url.split('=').pop(),
        url: resolveAssetUrl(url)
      });
      this.$message.success('图片上传成功');
    },
    handleRemove(file) {
      const index = this.fileList.findIndex(f => f.url === file.url);
      if (index !== -1) {
        this.fileList.splice(index, 1);
        this.form.pictureList.splice(index, 1);
      }
    },
    handlePictureCardPreview(file) {
      this.previewImage = file.url;
      this.previewVisible = true;
    },
    submitForm() {
      if (!this.form.idleName || !this.form.idlePrice || !this.form.userId) {
        this.$message.warning('请填写商品名称、价格和发布用户 ID');
        return;
      }
      const payload = {
        id: this.form.id,
        idleName: this.form.idleName,
        idleDetails: this.form.idleDetails,
        idlePrice: Number(this.form.idlePrice),
        idlePlace: this.form.idlePlace,
        idleLabel: Number(this.form.idleLabel),
        userId: Number(this.form.userId),
        idleStatus: Number(this.form.idleStatus),
        pictureList: JSON.stringify(this.form.pictureList),
      };
      if (this.form.releaseTime) {
        payload.releaseTime = this.form.releaseTime;
      }

      const request = this.editing
        ? this.$api.updateAdminGoods(payload)
        : this.$api.addAdminGoods(payload);

      this.tableLoading = true;
      request
        .then((res) => {
          if (res.status_code !== 1) {
            this.$message.error(res.msg || '保存失败');
            return;
          }
          this.$message.success(this.editing ? '商品更新成功' : '商品新增成功');
          this.dialogVisible = false;
          this.refreshList();
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    changeGoodsStatus(row, status, message) {
      this.$confirm(message, '系统提示', {
        confirmButtonClass: 'el-button--danger',
        type: status === 1 ? 'success' : 'warning',
      }).then(() => {
        this.tableLoading = true;
        this.$api
          .updateGoods({ id: row.id, status })
          .then((res) => {
            if (res.status_code !== 1) {
              this.$message.error(res.msg || '操作失败');
              return;
            }
            this.$message.success('操作成功');
            this.refreshList();
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

.goods-preview {
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border-radius: var(--radius-sm);
  background: #f1f5f9;
  color: #cbd5e1;
  font-size: 24px;
}

.goods-thumb {
  width: 100%;
  height: 100%;
}

.goods-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.g-name {
  font-size: 16px;
  font-weight: 700;
  color: var(--text-primary);
}

.g-desc,
.g-date {
  font-size: 12px;
  color: var(--text-tertiary);
}

.user-chip {
  display: flex;
  align-items: center;
  gap: 8px;
}

.avatar-sm {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: var(--brand-primary-light);
  color: var(--brand-primary);
  font-size: 12px;
  font-weight: 700;
}

.price-cell {
  font-size: 18px;
  font-weight: 800;
  color: var(--brand-primary);
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

.btn-danger-bold {
  background: #ef4444 !important;
  border: none !important;
  color: white !important;
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
  font-weight: 600;
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
