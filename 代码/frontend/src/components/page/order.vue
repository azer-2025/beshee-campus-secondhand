<template>
    <div class="order-page">
        <app-head></app-head>
        <app-body>
            <div class="order-dashboard">
                <div class="dashboard-row">
                    <div class="hero-status-card trendy-card" :class="getStatusClass(orderInfo.orderStatus)">
                        <div class="hero-main">
                            <div class="status-badge-icon">
                                <i :class="getStatusIcon(orderInfo.orderStatus)"></i>
                            </div>
                            <div class="status-info-text">
                                <h1 class="main-status">{{ orderStatus[orderInfo.orderStatus] }}</h1>
                                <div class="sub-meta">
                                    <span class="order-no">ID: {{ orderInfo.orderNumber }}</span>
                                    <span class="dot">·</span>
                                    <span class="order-time">{{ orderInfo.createTime?.replace('T', ' ') }}</span>
                                </div>
                            </div>
                        </div>

                        <div class="flow-steps">
                            <div class="flow-item" :class="{ done: orderInfo.orderStatus >= 0 }">
                                <div class="node">1</div>
                                <span>创建</span>
                            </div>
                            <div class="flow-line" :class="{ active: orderInfo.orderStatus >= 1 }"></div>
                            <div class="flow-item" :class="{ done: orderInfo.orderStatus >= 1 }">
                                <div class="node">2</div>
                                <span>支付</span>
                            </div>
                            <div class="flow-line" :class="{ active: orderInfo.orderStatus >= 2 }"></div>
                            <div class="flow-item" :class="{ done: orderInfo.orderStatus >= 2 }">
                                <div class="node">3</div>
                                <span>发货</span>
                            </div>
                            <div class="flow-line" :class="{ active: orderInfo.orderStatus >= 3 }"></div>
                            <div class="flow-item" :class="{ done: orderInfo.orderStatus >= 3 }">
                                <div class="node">4</div>
                                <span>完成</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="dashboard-grid">
                    <div class="grid-col">
                        <div class="item-preview-card trendy-card" @click="toDetails(orderInfo.idleItem.id)">
                            <div class="box-header">📦 交易手机</div>
                            <div class="item-main">
                                <el-image class="item-img" :src="orderInfo.idleItem.imgUrl" fit="cover"></el-image>
                                <div class="item-details">
                                    <div class="item-tag" :class="orderInfo.userId == userId ? 'buyer' : 'seller'">
                                        {{ orderInfo.userId == userId ? '我买入的' : '我卖出的' }}
                                    </div>
                                    <h2 class="item-name">{{ orderInfo.idleItem.idleName }}</h2>
                                    <p class="item-price">¥{{ orderInfo.orderPrice }}</p>
                                </div>
                            </div>
                            <div class="click-hint">点击查看手机详情 <i class="el-icon-right"></i></div>
                        </div>
                    </div>

                    <div class="grid-col">
                        <div class="shipping-card trendy-card">
                            <div class="box-header">
                                <span>📍 收货信息</span>
                                <el-button
                                    v-if="orderInfo.userId == userId && orderInfo.orderStatus === 0"
                                    type="text"
                                    size="mini"
                                    @click="selectAddressDialog">更换地址</el-button>
                            </div>
                            <div class="addr-box" v-if="addressInfo.detailAddress">
                                <div class="addr-user">{{ addressInfo.consigneeName }} <span class="phone">{{ addressInfo.consigneePhone }}</span></div>
                                <div class="addr-text">{{ addressInfo.detailAddress }}</div>
                                <div class="map-decoration">
                                    <i class="el-icon-location-information"></i>
                                </div>
                            </div>
                            <div v-else class="addr-empty" @click="selectAddressDialog">
                                <div class="add-icon">+</div>
                                <p>请先关联收货地址</p>
                            </div>
                        </div>
                    </div>

                    <div class="grid-col">
                        <div class="finance-card trendy-card">
                            <div class="box-header">💰 结算中心</div>
                            <div class="finance-list">
                                <div class="fin-row"><span>手机总额</span><span>¥{{ orderInfo.orderPrice }}</span></div>
                                <div class="fin-row"><span>配送费用</span><span>¥0.00</span></div>
                                <div class="fin-divider"></div>
                                <div class="fin-row total"><span>实付合计</span><span class="total-val">¥{{ orderInfo.orderPrice }}</span></div>
                            </div>

                            <div class="divider-dashed"></div>

                            <div class="action-area">
                                <template v-if="orderInfo.orderStatus === 0 && userId == orderInfo.userId">
                                    <el-button type="primary" class="btn-block pay" @click="changeOrderStatus(1, orderInfo)">立即支付 ¥{{ orderInfo.orderPrice }}</el-button>
                                    <el-button type="info" plain class="btn-block" @click="changeOrderStatus(4, orderInfo)">取消订单</el-button>
                                </template>

                                <el-button
                                    v-if="orderInfo.orderStatus === 1 && userId == orderInfo.idleItem.userId"
                                    type="primary"
                                    class="btn-block"
                                    @click="changeOrderStatus(2, orderInfo)">立即发货</el-button>

                                <el-button
                                    v-if="orderInfo.orderStatus === 2 && userId == orderInfo.userId"
                                    type="success"
                                    class="btn-block"
                                    @click="changeOrderStatus(3, orderInfo)">确认收货</el-button>

                                <div v-if="orderInfo.orderStatus === 3" class="status-finish success">
                                    <i class="el-icon-success"></i> 交易已完成
                                </div>
                                <div v-if="orderInfo.orderStatus === 4" class="status-finish fail">
                                    <i class="el-icon-error"></i> 订单已取消
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <el-dialog title="我的收货地址" v-model="addressDialogVisible" width="600px" class="trendy-dialog">
                <div class="addr-picker">
                    <div v-for="(addr, idx) in addressData" :key="idx" class="addr-option" @click="selectAddress(idx, addr)">
                        <div class="opt-main">
                            <div class="opt-name">{{ addr.consigneeName }} <span>{{ addr.consigneePhone }}</span></div>
                            <div class="opt-detail">{{ addr.detailAddressText }}</div>
                        </div>
                        <div class="opt-check" v-if="addressInfo.id === addr.id"><i class="el-icon-check"></i></div>
                    </div>
                    <div v-if="addressData.length === 0" class="opt-empty">暂无地址，请先去个人中心添加</div>
                </div>
            </el-dialog>

            <app-foot></app-foot>
        </app-body>
    </div>
</template>

<script>
import AppHead from '../common/AppHeader.vue';
import AppBody from '../common/AppPageBody.vue';
import AppFoot from '../common/AppFoot.vue';

export default {
    name: 'order',
    components: { AppHead, AppBody, AppFoot },
    data() {
        return {
            addressDialogVisible: false,
            addressData: [],
            orderStatus: ['待付款', '待发货', '待收货', '已完成', '已取消'],
            orderInfo: {
                createTime: '',
                id: 0,
                idleId: 0,
                idleItem: { id: '', idleName: '', pictureList: [], idlePrice: 0, imgUrl: '' },
                orderNumber: '',
                orderPrice: 0,
                orderStatus: 0,
                paymentStatus: 0,
                paymentTime: '',
                paymentWay: '',
                userId: 0
            },
            addressInfo: { id: '', update: false, detailAddress: '' },
            userId: ''
        };
    },
    mounted() {
        this.userId = this.getCookie('shUserId');
        const orderId = this.$route.query.id;
        this.$api.getOrder({ id: orderId }).then(res => {
            if (res.status_code === 1) {
                if (res.data.idleItem) {
                    const imgList = JSON.parse(res.data.idleItem.pictureList);
                    res.data.idleItem.imgUrl = imgList.length > 0 ? imgList[0] : '';
                }
                this.orderInfo = res.data;
                this.$api.getOrderAddress({ orderId: this.orderInfo.id }).then(addressRes => {
                    if (addressRes.data) {
                        this.addressInfo = addressRes.data;
                        this.addressInfo.update = true;
                    } else {
                        this.getAddressData();
                    }
                });
            }
        });
    },
    methods: {
        getStatusClass(s) {
            return ['s-pay', 's-ship', 's-rec', 's-done', 's-cancel'][s] || '';
        },
        getStatusIcon(s) {
            return ['el-icon-wallet', 'el-icon-box', 'el-icon-truck', 'el-icon-circle-check', 'el-icon-circle-close'][s];
        },
        getCookie(cname) {
            const name = `${cname}=`;
            const ca = document.cookie.split(';');
            for (let i = 0; i < ca.length; i += 1) {
                const c = ca[i].trim();
                if (c.indexOf(name) === 0) {
                    return c.substring(name.length, c.length);
                }
            }
            return '0';
        },
        toDetails(id) {
            this.$router.push({ path: 'details', query: { id } });
        },
        selectAddressDialog() {
            if (this.orderInfo.userId == this.userId && this.orderInfo.orderStatus === 0) {
                this.addressDialogVisible = true;
                if (this.addressData.length === 0) {
                    this.getAddressData();
                }
            }
        },
        getAddressData() {
            this.$api.getAddress().then(res => {
                if (res.status_code === 1) {
                    const data = res.data;
                    data.forEach(d => {
                        d.detailAddressText = d.provinceName + d.cityName + d.regionName + d.detailAddress;
                    });
                    this.addressData = data;
                    if (!this.addressInfo.update) {
                        const def = data.find(d => d.defaultFlag);
                        if (def) {
                            this.selectAddress(0, def);
                        }
                    }
                }
            });
        },
        selectAddress(i, item) {
            this.addressDialogVisible = false;
            this.addressInfo.consigneeName = item.consigneeName;
            this.addressInfo.consigneePhone = item.consigneePhone;
            this.addressInfo.detailAddress = item.detailAddressText;
            if (this.addressInfo.update) {
                this.$api.updateOrderAddress({
                    id: this.addressInfo.id,
                    consigneeName: item.consigneeName,
                    consigneePhone: item.consigneePhone,
                    detailAddress: item.detailAddressText
                });
            } else {
                this.$api.addOrderAddress({
                    orderId: this.orderInfo.id,
                    consigneeName: item.consigneeName,
                    consigneePhone: item.consigneePhone,
                    detailAddress: item.detailAddressText
                }).then(res => {
                    if (res.status_code === 1) {
                        this.addressInfo.update = true;
                        this.addressInfo.id = res.data.id;
                    }
                });
            }
        },
        changeOrderStatus(orderStatus, orderInfo) {
            if (orderStatus === 1) {
                if (!this.addressInfo.detailAddress) {
                    return this.$message.error('请先选择收货地址');
                }
                this.$confirm('确认支付该订单？', '支付流程', {
                    roundButton: true,
                    confirmButtonText: '确定',
                    cancelButtonText: '取消'
                }).then(() => {
                    this.$api.updateOrder({
                        id: orderInfo.id,
                        orderStatus,
                        paymentStatus: 1,
                        paymentWay: '在线支付'
                    }).then(res => {
                        if (res.status_code === 1) {
                            this.orderInfo.orderStatus = 1;
                            this.orderInfo.paymentStatus = 1;
                            this.orderInfo.paymentTime = res.data.paymentTime;
                            this.$message.success('支付成功');
                        }
                    });
                });
            } else {
                this.$api.updateOrder({ id: orderInfo.id, orderStatus }).then(res => {
                    if (res.status_code === 1) {
                        this.$message.success('操作成功');
                        this.orderInfo.orderStatus = orderStatus;
                    }
                });
            }
        }
    }
};
</script>

<style scoped>
.order-page { background: #f4f7ff; min-height: 100vh; }
.order-dashboard { width: 100%; padding: 20px 0; }
.dashboard-row { margin-bottom: 24px; }
.hero-status-card { padding: 40px 60px; display: flex; justify-content: space-between; align-items: center; background: linear-gradient(135deg, #ffffff 0%, #fcfaff 100%); border-left: 8px solid #6366f1; }
.hero-main { display: flex; align-items: center; gap: 32px; }
.status-badge-icon { width: 90px; height: 90px; background: #eff6ff; border-radius: 28px; display: flex; align-items: center; justify-content: center; font-size: 44px; color: #6366f1; transform: rotate(-5deg); }
.main-status { font-size: 40px; font-weight: 900; color: #1e1b4b; letter-spacing: -1px; }
.sub-meta { display: flex; align-items: center; gap: 12px; margin-top: 8px; color: #94a3b8; font-size: 14px; }
.dot { font-weight: 900; color: #e2e8f0; }
.flow-steps { display: flex; align-items: center; gap: 16px; }
.flow-item { display: flex; flex-direction: column; align-items: center; gap: 8px; opacity: 0.3; transition: 0.3s; }
.flow-item.done { opacity: 1; color: #6366f1; }
.node { width: 28px; height: 28px; border-radius: 50%; background: #e2e8f0; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 900; }
.flow-item.done .node { background: #6366f1; color: white; box-shadow: 0 0 15px rgba(99, 102, 241, 0.4); }
.flow-item span { font-size: 12px; font-weight: 800; }
.flow-line { width: 60px; height: 4px; background: #e2e8f0; border-radius: 2px; }
.flow-line.active { background: #6366f1; }
.dashboard-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; }
.box-header { font-size: 16px; font-weight: 900; color: #1e1b4b; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; }
.item-preview-card { padding: 32px; height: 100%; cursor: pointer; }
.item-main { display: flex; gap: 20px; margin-bottom: 24px; }
.item-img { width: 120px; height: 120px; border-radius: 20px; flex-shrink: 0; box-shadow: 0 10px 20px rgba(0,0,0,0.05); }
.item-tag { font-size: 11px; font-weight: 800; padding: 4px 10px; border-radius: 8px; width: fit-content; margin-bottom: 12px; }
.item-tag.buyer { background: #e0e7ff; color: #4338ca; }
.item-tag.seller { background: #fef3c7; color: #b45309; }
.item-name { font-size: 22px; font-weight: 900; color: #1e1b4b; margin-bottom: 8px; }
.item-price { font-size: 28px; font-weight: 900; color: #ec4899; }
.click-hint { font-size: 12px; color: #cbd5e1; text-align: right; }
.shipping-card { padding: 32px; height: 100%; position: relative; overflow: hidden; }
.addr-box { position: relative; z-index: 2; }
.addr-user { font-size: 20px; font-weight: 900; color: #1e1b4b; margin-bottom: 12px; }
.addr-user span { font-weight: 400; color: #94a3b8; font-size: 15px; margin-left: 10px; }
.addr-text { font-size: 16px; color: #475569; line-height: 1.6; max-width: 80%; }
.map-decoration { position: absolute; right: -20px; bottom: -20px; font-size: 120px; color: #6366f1; opacity: 0.05; }
.addr-empty { border: 3px dashed #f1f5f9; border-radius: 24px; height: 160px; display: flex; flex-direction: column; align-items: center; justify-content: center; cursor: pointer; color: #94a3b8; }
.add-icon { font-size: 32px; margin-bottom: 8px; }
.finance-card { padding: 32px; height: 100%; }
.finance-list { margin-bottom: 24px; }
.fin-row { display: flex; justify-content: space-between; margin-bottom: 16px; color: #64748b; font-size: 15px; }
.fin-divider { height: 1px; background: #f1f5f9; margin: 16px 0; }
.total { color: #1e1b4b; font-weight: 900; }
.total-val { font-size: 32px; color: #6366f1; }
.divider-dashed { border-top: 2px dashed #f1f5f9; margin: 24px 0; }
.action-area { display: flex; flex-direction: column; gap: 12px; }
.btn-block { height: 56px; border-radius: 28px !important; font-size: 16px; font-weight: 800; width: 100%; margin: 0 !important; }
.btn-block.pay { background: var(--brand-gradient) !important; border: none; }
.status-finish { text-align: center; padding: 20px; border-radius: 20px; font-weight: 800; display: flex; align-items: center; justify-content: center; gap: 10px; }
.status-finish.success { background: #ecfdf5; color: #10b981; }
.status-finish.fail { background: #fef2f2; color: #ef4444; }
.addr-picker { display: flex; flex-direction: column; gap: 12px; }
.addr-option { padding: 20px; border-radius: 16px; border: 2px solid #f1f5f9; display: flex; justify-content: space-between; align-items: center; cursor: pointer; transition: 0.3s; }
.addr-option:hover { border-color: #6366f1; background: #f5f3ff; }
.opt-name { font-weight: 900; color: #1e1b4b; margin-bottom: 4px; }
.opt-name span { font-weight: 400; color: #94a3b8; font-size: 13px; margin-left: 8px; }
.opt-detail { font-size: 13px; color: #64748b; }
.opt-check { color: #6366f1; font-size: 20px; }
.opt-empty { color: #94a3b8; text-align: center; padding: 12px 0; }
@media (max-width: 1200px) { .dashboard-grid { grid-template-columns: 1fr; } .hero-status-card { flex-direction: column; gap: 30px; text-align: center; } }
</style>
