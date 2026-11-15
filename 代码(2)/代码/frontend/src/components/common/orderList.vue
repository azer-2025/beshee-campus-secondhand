<template>
  <div class="premium-card management-panel">
    <div class="panel-header">
      <div class="header-left">
        <h2 class="panel-title">订单交易管理</h2>
        <p class="panel-subtitle">管理员可新增、编辑、查询和删除平台订单。</p>
      </div>
      <div class="header-right">
        <div class="search-box-v2">
          <i class="el-icon-search search-icon"></i>
          <input
            v-model="searchValue"
            type="text"
            placeholder="按订单号搜索"
            @keyup.enter="searchOrders"
          />
          <el-button type="primary" size="small" @click="searchOrders">搜索</el-button>
        </div>
        <el-button type="primary" class="premium-add-btn" @click="openCreateDialog">
          <i class="el-icon-plus"></i>
          <span>新增订单</span>
        </el-button>
      </div>
    </div>

    <div class="table-wrapper" v-loading="tableLoading">
      <el-table
        :data="orders"
        class="premium-table"
        style="width: 100%"
        :header-cell-style="headerStyle"
      >
        <el-table-column prop="orderNumber" label="订单编号" width="200">
          <template #default="scope">
            <span class="order-id">#{{ scope.row.orderNumber }}</span>
          </template>
        </el-table-column>

        <el-table-column label="商品信息" min-width="220" show-overflow-tooltip>
          <template #default="scope">
            <div class="item-info">
              <span class="i-name">{{ scope.row.idleItem?.idleName || `商品 #${scope.row.idleId}` }}</span>
              <span class="i-time">{{ scope.row.createTime || '-' }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="买家" width="120">
          <template #default="scope">
            <span class="simple-tag">用户 #{{ scope.row.userId }}</span>
          </template>
        </el-table-column>

        <el-table-column prop="orderPrice" label="金额" width="120">
          <template #default="scope">
            <div class="price-cell">
              <small>¥</small>
              <span>{{ scope.row.orderPrice }}</span>
            </div>
          </template>
        </el-table-column>

        <el-table-column label="支付状态" width="120">
          <template #default="scope">
            <div :class="['status-badge', Number(scope.row.paymentStatus) === 1 ? 's-success' : 's-warning']">
              {{ paymentStatusMap[Number(scope.row.paymentStatus)] }}
            </div>
          </template>
        </el-table-column>

        <el-table-column label="订单状态" width="120">
          <template #default="scope">
            <div :class="['status-badge', getOrderStatusClass(scope.row.orderStatus)]">
              {{ orderStatusMap[Number(scope.row.orderStatus)] }}
            </div>
          </template>
        </el-table-column>

        <el-table-column label="支付方式" width="140">
          <template #default="scope">
            <span>{{ scope.row.paymentWay || '未设置' }}</span>
          </template>
        </el-table-column>

        <el-table-column label="操作" width="170" align="center">
          <template #default="scope">
            <div class="action-btns">
              <el-button size="small" class="btn-edit" @click="openEditDialog(scope.row)">编辑</el-button>
              <el-button size="small" class="btn-delete" @click="confirmDeleteOrder(scope.row)">删除</el-button>
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
      :title="editing ? '编辑订单' : '新增订单'"
      width="560px"
      class="premium-dialog"
      append-to-body
    >
      <div class="dialog-form">
        <div v-if="editing" class="input-group">
          <label>订单编号</label>
          <el-input :model-value="form.orderNumber || '自动生成'" disabled />
        </div>

        <div class="double-grid">
          <div class="input-group">
            <label>买家用户 ID</label>
            <el-input v-model="form.userId" type="number" placeholder="例如：6" />
          </div>
          <div class="input-group">
            <label>商品 ID</label>
            <el-input v-model="form.idleId" type="number" placeholder="例如：18" />
          </div>
        </div>

        <div class="double-grid">
          <div class="input-group">
            <label>订单金额</label>
            <el-input v-model="form.orderPrice" type="number" placeholder="0.00" />
          </div>
          <div class="input-group">
            <label>支付方式</label>
            <el-select v-model="form.paymentWay" placeholder="请选择支付方式" style="width: 100%">
              <el-option
                v-for="item in paymentWayOptions"
                :key="item"
                :label="item"
                :value="item"
              />
            </el-select>
          </div>
        </div>

        <div class="double-grid">
          <div class="input-group">
            <label>支付状态</label>
            <el-select v-model="form.paymentStatus" placeholder="请选择支付状态" style="width: 100%">
              <el-option label="未支付" :value="0" />
              <el-option label="已支付" :value="1" />
            </el-select>
          </div>
          <div class="input-group">
            <label>订单状态</label>
            <el-select v-model="form.orderStatus" placeholder="请选择订单状态" style="width: 100%">
              <el-option
                v-for="item in orderStatusOptions"
                :key="item.value"
                :label="item.label"
                :value="item.value"
              />
            </el-select>
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
const paymentStatusMap = {
  0: '未支付',
  1: '已支付',
};

const orderStatusMap = {
  0: '待付款',
  1: '待发货',
  2: '待收货',
  3: '已完成',
  4: '已取消',
};

const orderStatusOptions = [
  { label: '待付款', value: 0 },
  { label: '待发货', value: 1 },
  { label: '待收货', value: 2 },
  { label: '已完成', value: 3 },
  { label: '已取消', value: 4 },
];

function createForm() {
  return {
    id: null,
    orderNumber: '',
    userId: '',
    idleId: '',
    orderPrice: '',
    paymentStatus: 0,
    paymentWay: '支付宝',
    orderStatus: 0,
  };
}

export default {
  name: 'OrderList',
  data() {
    return {
      paymentStatusMap,
      orderStatusMap,
      orderStatusOptions,
      paymentWayOptions: ['支付宝', '微信', '银行卡'],
      nowPage: 1,
      total: 0,
      orders: [],
      searchValue: '',
      tableLoading: false,
      dialogVisible: false,
      editing: false,
      form: createForm(),
      headerStyle: {
        background: '#f8fafc',
        color: '#64748b',
        fontWeight: '700',
        fontSize: '12px',
        borderBottom: '1px solid #e2e8f0',
      },
    };
  },
  created() {
    this.loadOrders();
  },
  methods: {
    getOrderStatusClass(status) {
      const statusValue = Number(status);
      if (statusValue === 0) return 's-warning';
      if (statusValue === 1) return 's-primary';
      if (statusValue === 2) return 's-info';
      if (statusValue === 3) return 's-success';
      return 's-danger';
    },
    applyResponse(res) {
      if (res.status_code !== 1) {
        return;
      }
      const list = res.data?.list || [];
      const count = Number(res.data?.count || 0);
      this.orders = list;
      this.total = Math.max(count, list.length);
    },
    loadOrders() {
      this.tableLoading = true;
      this.$api
        .getOrderList({ page: this.nowPage, nums: 8 })
        .then((res) => {
          this.applyResponse(res);
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    searchOrders() {
      if (!this.searchValue) {
        this.loadOrders();
        return;
      }
      this.tableLoading = true;
      this.$api
        .queryOrder({ page: this.nowPage, nums: 8, searchValue: this.searchValue })
        .then((res) => {
          this.applyResponse(res);
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    handleCurrentChange(val) {
      this.nowPage = val;
      if (this.searchValue) {
        this.searchOrders();
      } else {
        this.loadOrders();
      }
    },
    openCreateDialog() {
      this.editing = false;
      this.form = createForm();
      this.dialogVisible = true;
    },
    openEditDialog(row) {
      this.editing = true;
      this.form = {
        id: row.id,
        orderNumber: row.orderNumber || '',
        userId: row.userId ?? '',
        idleId: row.idleId ?? '',
        orderPrice: row.orderPrice ?? '',
        paymentStatus: Number(row.paymentStatus ?? 0),
        paymentWay: row.paymentWay || '支付宝',
        orderStatus: Number(row.orderStatus ?? 0),
      };
      this.dialogVisible = true;
    },
    submitForm() {
      if (!this.form.userId || !this.form.idleId || !this.form.orderPrice) {
        this.$message.warning('请填写买家用户 ID、商品 ID 和订单金额');
        return;
      }
      const payload = {
        id: this.form.id,
        userId: Number(this.form.userId),
        idleId: Number(this.form.idleId),
        orderPrice: Number(this.form.orderPrice),
        paymentStatus: Number(this.form.paymentStatus),
        paymentWay: this.form.paymentWay,
        orderStatus: Number(this.form.orderStatus),
      };

      const request = this.editing
        ? this.$api.updateAdminOrder(payload)
        : this.$api.addAdminOrder(payload);

      this.tableLoading = true;
      request
        .then((res) => {
          if (res.status_code !== 1) {
            this.$message.error(res.msg || '保存失败');
            return;
          }
          this.$message.success(this.editing ? '订单更新成功' : '订单新增成功');
          this.dialogVisible = false;
          this.searchValue ? this.searchOrders() : this.loadOrders();
        })
        .finally(() => {
          this.tableLoading = false;
        });
    },
    confirmDeleteOrder(row) {
      this.$confirm('确认删除该订单吗？删除后无法恢复。', '系统提示', {
        confirmButtonClass: 'el-button--danger',
        type: 'warning',
      }).then(() => {
        this.tableLoading = true;
        this.$api
          .deleteOrder({ id: row.id })
          .then((res) => {
            if (res.status_code !== 1) {
              this.$message.error(res.msg || '删除失败');
              return;
            }
            this.$message.success('订单已删除');
            this.searchValue ? this.searchOrders() : this.loadOrders();
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

.table-wrapper {
  flex: 1;
}

.order-id {
  display: inline-block;
  padding: 4px 8px;
  border-radius: 6px;
  background: var(--brand-primary-light);
  color: var(--brand-primary);
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
  font-weight: 600;
}

.item-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.i-name {
  font-size: 15px;
  font-weight: 700;
  color: var(--text-primary);
}

.i-time {
  font-size: 12px;
  color: var(--text-tertiary);
}

.simple-tag {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  background: #f8fafc;
  color: var(--text-secondary);
  font-size: 12px;
  font-weight: 600;
}

.price-cell {
  font-size: 16px;
  font-weight: 800;
  color: var(--text-primary);
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

.s-warning {
  background: #fffbeb;
  color: #d97706;
}

.s-primary {
  background: #eef2ff;
  color: #4f46e5;
}

.s-info {
  background: #f1f5f9;
  color: #64748b;
}

.s-success {
  background: #ecfdf5;
  color: #059669;
}

.s-danger {
  background: #fef2f2;
  color: #dc2626;
}

.action-btns {
  display: flex;
  justify-content: center;
  gap: 8px;
}

.btn-edit {
  background: #eff6ff !important;
  border: none !important;
  color: #2563eb !important;
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
