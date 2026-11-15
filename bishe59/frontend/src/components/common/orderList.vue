<template>
	<div class="premium-card management-panel">
		<div class="panel-header">
			<div class="header-left">
				<h2 class="panel-title">订单交易中心</h2>
				<p class="panel-subtitle">监控平台内所有手机订单、状态流转和支付信息。</p>
			</div>
			<div class="header-right">
				<div class="search-box-v2">
					<i class="el-icon-search search-icon"></i>
					<input
						type="text"
						v-model="searchValue"
						placeholder="按订单号快速搜索..."
						@keyup.enter="searchIdle"
					/>
					<el-button type="primary" size="small" @click="searchIdle">搜索</el-button>
				</div>
			</div>
		</div>

		<div class="table-wrapper" v-loading="tableLoading">
			<el-table
				:data="Order"
				class="premium-table"
				style="width: 100%"
				:header-cell-style="headerStyle">

				<el-table-column prop="orderNumber" label="订单编号" min-width="180">
					<template #default="scope">
						<span class="order-id">#{{ scope.row.orderNumber }}</span>
					</template>
				</el-table-column>

				<el-table-column prop="idleItem.idleName" label="交易手机" min-width="220" show-overflow-tooltip>
					<template #default="scope">
						<div class="item-info">
							<span class="i-name">{{ scope.row.idleItem?.idleName }}</span>
							<span class="i-time">{{ scope.row.createTime }}</span>
						</div>
					</template>
				</el-table-column>

				<el-table-column prop="orderPrice" label="成交金额" min-width="120">
					<template #default="scope">
						<div class="price-cell">
							<small>¥</small>
							<span>{{ scope.row.orderPrice }}</span>
						</div>
					</template>
				</el-table-column>

				<el-table-column label="订单状态" min-width="120">
					<template #default="scope">
						<div :class="['status-badge', getStatusClass(scope.row.orderStatus)]">
							{{ orderStatus[scope.row.orderStatus] }}
						</div>
					</template>
				</el-table-column>

				<el-table-column label="支付信息" min-width="180">
					<template #default="scope">
						<div class="pay-info">
							<div class="pay-way">
								<i :class="getPayIcon(scope.row.paymentWay)"></i>
								<span>{{ scope.row.paymentWay || '未选择' }}</span>
							</div>
							<div :class="['pay-status', scope.row.paymentStatus ? 'done' : 'pending']">
								{{ paymentStatus[scope.row.paymentStatus] }}
							</div>
						</div>
					</template>
				</el-table-column>

				<el-table-column label="管理操作" width="120" align="center">
					<template #default="scope">
						<el-button
							size="small"
							class="btn-action-delete"
							@click="confirmDeleteOrder(scope.$index)">
							<i class="el-icon-delete"></i> 移除
						</el-button>
					</template>
				</el-table-column>
			</el-table>
		</div>

		<div class="panel-footer">
			<div class="total-info">总订单数：{{ total }}</div>
			<el-pagination
				@current-change="handleCurrentChange"
				v-model:current-page="nowPage"
				:page-size="8"
				layout="prev, pager, next"
				:total="total"
				class="premium-pagination">
			</el-pagination>
		</div>
	</div>
</template>

<script>
export default {
	name: 'orderList',
	data() {
		return {
			nowPage: 1,
			total: 0,
			paymentStatus: ['未支付', '已支付'],
			orderStatus: ['待付款', '待发货', '待收货', '已完成', '已取消'],
			Order: [],
			searchValue: '',
			tableLoading: false,
			headerStyle: {
				background: '#f8fafc',
				color: '#64748b',
				fontWeight: '700',
				fontSize: '12px',
				borderBottom: '1px solid #e2e8f0'
			}
		};
	},
	created() {
		this.getOrder();
	},
	methods: {
		getStatusClass(status) {
			const map = { 0: 's-warning', 1: 's-primary', 2: 's-info', 3: 's-success', 4: 's-danger' };
			return map[status] || 's-info';
		},
		getPayIcon(way) {
			if (!way) return 'el-icon-warning-outline';
			if (way.includes('支付宝')) return 'el-icon-bank-card';
			if (way.includes('微信')) return 'el-icon-chat-dot-round';
			return 'el-icon-wallet';
		},
		getOrder() {
			this.tableLoading = true;
			this.$api.getOrderList({ page: this.nowPage, nums: 8 }).then(res => {
				if (res.status_code == 1) {
					this.Order = res.data.list;
					this.total = res.data.count;
				}
			}).finally(() => {
				this.tableLoading = false;
			});
		},
		searchIdle() {
			this.tableLoading = true;
			this.$api.queryOrder({ page: this.nowPage, nums: 8, searchValue: this.searchValue }).then(res => {
				if (res.status_code == 1) {
					this.Order = res.data.list;
					this.total = res.data.count;
				}
			}).finally(() => {
				this.tableLoading = false;
			});
		},
		handleCurrentChange(val) {
			this.nowPage = val;
			this.getOrder();
		},
		confirmDeleteOrder(index) {
			this.$confirm('确定要删除这条订单吗？此操作不可恢复。', '系统提示', {
				confirmButtonText: '确定',
				cancelButtonText: '取消',
				confirmButtonClass: 'el-button--danger',
				type: 'warning'
			}).then(() => {
				this.tableLoading = true;
				this.$api.deleteOrder({ id: this.Order[index].id }).then(res => {
					if (res.status_code == 1) {
						this.$message.success('订单记录已移除');
						this.getOrder();
					}
				}).finally(() => {
					this.tableLoading = false;
				});
			});
		}
	}
};
</script>

<style scoped>
.management-panel { display: flex; flex-direction: column; min-height: calc(100vh - 120px); }
.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; }
.panel-title { font-size: 24px; font-weight: 800; color: var(--text-primary); }
.panel-subtitle { font-size: 14px; color: var(--text-tertiary); margin-top: 4px; }
.search-box-v2 { display: flex; align-items: center; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: var(--radius-md); padding: 4px 4px 4px 16px; width: 320px; }
.search-box-v2 input { border: none; background: transparent; flex: 1; padding: 8px 12px; font-size: 14px; outline: none; }
.table-wrapper { flex: 1; }
.order-id { font-family: 'JetBrains Mono', monospace; font-weight: 600; color: var(--brand-primary); background: var(--brand-primary-light); padding: 4px 8px; border-radius: 6px; font-size: 12px; }
.item-info { display: flex; flex-direction: column; }
.i-name { font-weight: 700; color: var(--text-primary); }
.i-time { font-size: 12px; color: var(--text-tertiary); }
.price-cell { font-weight: 800; color: var(--text-primary); font-size: 15px; }
.status-badge { padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700; text-align: center; width: fit-content; }
.s-warning { background: #fffbeb; color: #d97706; }
.s-primary { background: #eef2ff; color: #4f46e5; }
.s-info { background: #f1f5f9; color: #64748b; }
.s-success { background: #ecfdf5; color: #059669; }
.s-danger { background: #fef2f2; color: #dc2626; }
.pay-info { display: flex; flex-direction: column; gap: 4px; }
.pay-way { font-size: 13px; display: flex; align-items: center; gap: 6px; color: var(--text-secondary); }
.pay-status { font-size: 11px; font-weight: 700; text-transform: uppercase; }
.pay-status.done { color: #10b981; }
.pay-status.pending { color: #f59e0b; }
.btn-action-delete { background: #f8fafc !important; border: 1px solid #e2e8f0 !important; color: #64748b !important; }
.btn-action-delete:hover { color: #ef4444 !important; border-color: #fca5a5 !important; background: #fef2f2 !important; }
.panel-footer { margin-top: 32px; display: flex; justify-content: space-between; align-items: center; padding-top: 24px; border-top: 1px solid #f1f5f9; }
.total-info { font-size: 13px; color: var(--text-tertiary); font-weight: 600; }
</style>
