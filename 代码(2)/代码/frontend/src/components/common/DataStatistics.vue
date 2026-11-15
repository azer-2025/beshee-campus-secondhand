<template>
	<div class="stats-wrapper">
		<!-- Header Section -->
		<div class="stats-header">
			<div class="header-info">
				<h1 class="stats-title">数据可视化中心</h1>
				<p class="stats-subtitle">实时监控平台交易动态与用户增长趋势</p>
			</div>
			<div class="header-actions">
				<el-button 
					type="primary" 
					class="premium-refresh-btn"
					@click="fetchAllStatisticsData"
					:loading="isLoading">
					<i class="el-icon-refresh"></i>
					<span>更新实时数据</span>
				</el-button>
			</div>
		</div>

		<!-- Bento Grid Layout -->
		<div class="bento-grid">
			<!-- Main Stats (4 Cards) -->
			<div v-for="(item, index) in tradingDataList" :key="index" :class="['bento-item', 'stat-card', item.class]">
				<div class="card-content">
					<div class="icon-box">
						<i :class="item.icon"></i>
					</div>
					<div class="data-box">
						<span class="label">{{ item.title }}</span>
						<h2 class="value">
							<small v-if="item.prefix">{{ item.prefix }}</small>
							{{ formatNumber(item.value) }}
						</h2>
					</div>
				</div>
				<div class="card-bg-icon">
					<i :class="item.icon"></i>
				</div>
			</div>

			<!-- Large Chart: Monthly Trend -->
			<div class="bento-item chart-item monthly-trend">
				<div class="item-header">
					<div class="title-group">
						<i class="el-icon-data-line"></i>
						<span>平台交易趋势分析</span>
					</div>
					<div class="tag">按月度统计</div>
				</div>
				<div ref="monthlyChart" class="chart-canvas"></div>
			</div>

			<!-- User Stats Card -->
			<div class="bento-item user-summary">
				<div class="item-header">
					<div class="title-group">
						<i class="el-icon-user"></i>
						<span>用户活跃概览</span>
					</div>
				</div>
				<div class="user-stats-list">
					<div class="user-stat-row" v-for="(user, idx) in userDataList" :key="idx">
						<div class="u-info">
							<div :class="['u-dot', user.class]"></div>
							<span>{{ user.title }}</span>
						</div>
						<span class="u-value">{{ formatNumber(user.value) }}</span>
					</div>
				</div>
				<div class="user-progress">
					<div class="progress-bar">
						<div class="bar-fill" :style="{width: '65%'}"></div>
					</div>
					<div class="progress-label">活跃度目标达成 65%</div>
				</div>
			</div>

			<!-- Category Distribution -->
			<div class="bento-item chart-item category-dist">
				<div class="item-header">
					<div class="title-group">
						<i class="el-icon-pie-chart"></i>
						<span>闲置分类权重</span>
					</div>
				</div>
				<div ref="categoryChart" class="chart-canvas"></div>
			</div>
		</div>
	</div>
</template>

<script>
import * as echarts from 'echarts';

export default {
	name: "DataStatistics",
	data() {
		return {
			isLoading: false,
			tradingData: {
				totalOrders: 0,
				totalAmount: 0,
				currentMonthOrders: 0,
				currentMonthAmount: 0
			},
			userData: {
				totalUsers: 0,
				newUsers: 0,
				activeUsers: 0
			},
			monthlyData: [],
			categoryData: [],
			monthlyChart: null,
			categoryChart: null
		}
	},
	computed: {
		tradingDataList() {
			return [
				{
					title: '累计订单',
					value: this.tradingData.totalOrders,
					icon: 'el-icon-shopping-cart-full',
					prefix: '',
					class: 'indigo-card'
				},
				{
					title: 'GMV 成交总额',
					value: this.tradingData.totalAmount,
					icon: 'el-icon-wallet',
					prefix: '¥',
					class: 'emerald-card'
				},
				{
					title: '本月订单',
					value: this.tradingData.currentMonthOrders,
					icon: 'el-icon-document-checked',
					prefix: '',
					class: 'amber-card'
				},
				{
					title: '本月成交',
					value: this.tradingData.currentMonthAmount,
					icon: 'el-icon-money',
					prefix: '¥',
					class: 'rose-card'
				}
			];
		},
		userDataList() {
			return [
				{
					title: '平台总用户',
					value: this.userData.totalUsers,
					class: 'bg-indigo'
				},
				{
					title: '本月新注册',
					value: this.userData.newUsers,
					class: 'bg-emerald'
				},
				{
					title: '今日活跃',
					value: this.userData.activeUsers,
					class: 'bg-amber'
				}
			];
		}
	},
	mounted() {
		this.fetchAllStatisticsData();
		window.addEventListener('resize', this.resizeCharts);
	},
	beforeUnmount() {
		window.removeEventListener('resize', this.resizeCharts);
		if (this.monthlyChart) this.monthlyChart.dispose();
		if (this.categoryChart) this.categoryChart.dispose();
	},
	methods: {
		formatNumber(val) {
			if (!val && val !== 0) return '0';
			return val.toLocaleString();
		},
		fetchAllStatisticsData() {
			this.isLoading = true;
			Promise.all([
				this.$api.getTradingData({}),
				this.$api.getUserStatistics({}),
				this.$api.getMonthlyStatistics({}),
				this.$api.getCategoryStatistics({})
			]).then(([tradingRes, userRes, monthlyRes, categoryRes]) => {
				if (tradingRes.status_code === 1) this.tradingData = tradingRes.data;
				if (userRes.status_code === 1) this.userData = userRes.data;
				if (monthlyRes.status_code === 1) this.monthlyData = monthlyRes.data;
				if (categoryRes.status_code === 1) this.categoryData = categoryRes.data;
				
				this.$nextTick(() => {
					this.initMonthlyChart();
					this.initCategoryChart();
				});
			}).catch(error => {
				console.error('Data Fetch Error:', error);
			}).finally(() => {
				this.isLoading = false;
			});
		},
		resizeCharts() {
			this.monthlyChart?.resize();
			this.categoryChart?.resize();
		},
		initMonthlyChart() {
			if (!this.$refs.monthlyChart) return;
			this.monthlyChart = echarts.init(this.$refs.monthlyChart);
			
			const option = {
				grid: { top: 40, right: 20, bottom: 40, left: 50, containLabel: true },
				tooltip: { trigger: 'axis', backgroundColor: 'rgba(255,255,255,0.9)', borderRadius: 8, padding: 12 },
				xAxis: {
					type: 'category',
					data: this.monthlyData.map(i => i.month),
					axisLine: { lineStyle: { color: '#e2e8f0' } },
					axisLabel: { color: '#64748b' }
				},
				yAxis: [
					{ type: 'value', axisLabel: { color: '#64748b' }, splitLine: { lineStyle: { type: 'dashed', color: '#f1f5f9' } } },
					{ type: 'value', splitLine: { show: false }, axisLabel: { show: false } }
				],
				series: [
					{
						name: '成交额',
						type: 'line',
						smooth: true,
						data: this.monthlyData.map(i => i.orderAmount),
						itemStyle: { color: '#6366f1' },
						areaStyle: {
							color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
								{ offset: 0, color: 'rgba(99, 102, 241, 0.2)' },
								{ offset: 1, color: 'rgba(99, 102, 241, 0)' }
							])
						}
					},
					{
						name: '订单数',
						type: 'bar',
						yAxisIndex: 1,
						barWidth: 20,
						itemStyle: { color: '#10b981', borderRadius: [4, 4, 0, 0] },
						data: this.monthlyData.map(i => i.orderCount)
					}
				]
			};
			this.monthlyChart.setOption(option);
		},
		initCategoryChart() {
			if (!this.$refs.categoryChart) return;
			this.categoryChart = echarts.init(this.$refs.categoryChart);
			
			const option = {
				tooltip: { trigger: 'item' },
				legend: { bottom: '0', icon: 'circle', itemWidth: 8 },
				series: [{
					name: '分类比例',
					type: 'pie',
					radius: ['50%', '80%'],
					avoidLabelOverlap: false,
					itemStyle: { borderRadius: 10, borderColor: '#fff', borderWidth: 2 },
					label: { show: false },
					emphasis: { label: { show: true, fontSize: 16, fontWeight: 'bold' } },
					data: this.categoryData.map(i => ({ value: i.count, name: i.categoryName }))
				}],
				color: ['#6366f1', '#10b981', '#f59e0b', '#ec4899', '#3b82f6', '#8b5cf6']
			};
			this.categoryChart.setOption(option);
		}
	}
}
</script>

<style scoped>
.stats-wrapper {
	padding: 8px;
}

.stats-header {
	display: flex;
	justify-content: space-between;
	align-items: flex-end;
	margin-bottom: 32px;
	padding: 0 4px;
}

.stats-title {
	font-size: 28px;
	font-weight: 800;
	color: var(--text-primary);
	margin-bottom: 4px;
	letter-spacing: -0.02em;
}

.stats-subtitle {
	color: var(--text-tertiary);
	font-size: 14px;
}

.premium-refresh-btn {
	height: 44px;
	padding: 0 24px !important;
	font-size: 14px;
	border-radius: var(--radius-md) !important;
}

/* Bento Grid System */
.bento-grid {
	display: grid;
	grid-template-columns: repeat(4, 1fr);
	grid-template-rows: auto 400px;
	gap: 24px;
}

.bento-item {
	background: white;
	border-radius: var(--radius-xl);
	border: 1px solid rgba(226, 232, 240, 0.8);
	box-shadow: var(--shadow-soft);
	padding: 24px;
	position: relative;
	overflow: hidden;
	transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.bento-item:hover {
	transform: translateY(-6px);
	box-shadow: var(--shadow-lg);
	border-color: var(--brand-primary-light);
}

/* Stat Cards Styles */
.stat-card .card-content {
	position: relative;
	z-index: 2;
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.icon-box {
	width: 48px;
	height: 48px;
	border-radius: var(--radius-md);
	display: flex;
	align-items: center;
	justify-content: center;
	font-size: 24px;
}

.data-box .label {
	font-size: 13px;
	font-weight: 600;
	color: var(--text-tertiary);
	display: block;
	margin-bottom: 4px;
}

.data-box .value {
	font-size: 32px;
	font-weight: 800;
	color: var(--text-primary);
	display: flex;
	align-items: baseline;
	gap: 4px;
}

.data-box .value small {
	font-size: 16px;
	font-weight: 600;
}

.card-bg-icon {
	position: absolute;
	right: -10px;
	bottom: -10px;
	font-size: 80px;
	opacity: 0.03;
	transform: rotate(-15deg);
	z-index: 1;
}

/* Stat Card Colors */
.indigo-card .icon-box { background: #eef2ff; color: #6366f1; }
.emerald-card .icon-box { background: #ecfdf5; color: #10b981; }
.amber-card .icon-box { background: #fffbeb; color: #f59e0b; }
.rose-card .icon-box { background: #fff1f2; color: #f43f5e; }

/* Chart Items */
.chart-item {
	grid-column: span 2;
	display: flex;
	flex-direction: column;
}

.monthly-trend {
	grid-column: span 3;
}

.item-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 24px;
}

.title-group {
	display: flex;
	align-items: center;
	gap: 10px;
	font-weight: 700;
	color: var(--text-primary);
}

.title-group i {
	color: var(--brand-primary);
	font-size: 20px;
}

.tag {
	font-size: 11px;
	background: #f1f5f9;
	padding: 4px 10px;
	border-radius: 20px;
	color: #64748b;
	font-weight: 600;
}

.chart-canvas {
	flex: 1;
	min-height: 280px;
}

/* User Summary */
.user-summary {
	display: flex;
	flex-direction: column;
	justify-content: space-between;
}

.user-stats-list {
	display: flex;
	flex-direction: column;
	gap: 16px;
}

.user-stat-row {
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.u-info {
	display: flex;
	align-items: center;
	gap: 10px;
	font-size: 14px;
	font-weight: 500;
}

.u-dot {
	width: 8px;
	height: 8px;
	border-radius: 50%;
}

.u-value {
	font-weight: 700;
	color: var(--text-primary);
}

.bg-indigo { background: #6366f1; }
.bg-emerald { background: #10b981; }
.bg-amber { background: #f59e0b; }

.user-progress {
	margin-top: 24px;
}

.progress-bar {
	height: 6px;
	background: #f1f5f9;
	border-radius: 10px;
	overflow: hidden;
	margin-bottom: 8px;
}

.bar-fill {
	height: 100%;
	background: var(--brand-gradient);
}

.progress-label {
	font-size: 11px;
	color: var(--text-tertiary);
	text-align: right;
}

/* Category Distribution specific */
.category-dist {
	grid-column: span 1;
}

/* Responsive Grid */
@media (max-width: 1280px) {
	.bento-grid {
		grid-template-columns: repeat(2, 1fr);
		grid-template-rows: auto auto auto;
	}
	.monthly-trend, .bento-item { grid-column: span 1; }
}

@media (max-width: 768px) {
	.bento-grid { grid-template-columns: 1fr; }
	.stats-header { flex-direction: column; align-items: flex-start; gap: 20px; }
}
</style>
