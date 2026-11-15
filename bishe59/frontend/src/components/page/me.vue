<template>
    <div class="me-page">
        <app-head :nickname-value="userInfo.nickname" :avatarValue="userInfo.avatar"></app-head>
        <app-body>
            <div v-show="!eidtAddress" class="dashboard-container">
                <div class="profile-card premium-card">
                    <div class="profile-main">
                        <el-upload
                            :action="uploadAction"
                            :on-success="fileHandleSuccess"
                            :on-error="fileHandleError"
                            :show-file-list="false"
                            accept="image/*"
                            class="avatar-uploader">
                            <el-avatar :size="96" :src="userInfo.avatar"></el-avatar>
                        </el-upload>

                        <div class="profile-text">
                            <h1>{{ userInfo.nickname }}</h1>
                            <p>{{ userInfo.signInTime }} 加入平台</p>
                            <div class="profile-actions">
                                <el-button type="primary" round @click="userInfoDialogVisible = true">编辑资料</el-button>
                                <el-button plain round @click="eidtAddress = true">地址管理</el-button>
                            </div>
                        </div>
                    </div>

                    <div class="profile-stats">
                        <div class="stat-box">
                            <span class="stat-value">{{ dataList[0].length }}</span>
                            <span class="stat-label">在售手机</span>
                        </div>
                        <div class="stat-box">
                            <span class="stat-value">{{ dataList[2].length }}</span>
                            <span class="stat-label">我的收藏</span>
                        </div>
                        <div class="stat-box">
                            <span class="stat-value">{{ dataList[3].length }}</span>
                            <span class="stat-label">卖出订单</span>
                        </div>
                    </div>
                </div>

                <div class="dashboard-content">
                    <div class="sidebar-menu premium-card">
                        <div
                            v-for="menu in menuOptions"
                            :key="menu.value"
                            class="menu-item"
                            :class="{ active: activeName === menu.value }"
                            @click="activeName = menu.value">
                            <i :class="menu.icon"></i>
                            <span>{{ menu.label }}</span>
                            <el-badge v-if="dataList[menu.value - 1].length > 0" :value="dataList[menu.value - 1].length" class="menu-badge" />
                        </div>
                    </div>

                    <div class="main-list-section">
                        <div class="section-header">
                            <h2>{{ getMenuLabel(activeName) }}</h2>
                        </div>

                        <div class="item-list">
                            <div v-for="(item, index) in dataList[activeName - 1]" :key="index" class="list-card premium-card">
                                <div class="list-card-content" @click="toDetails(activeName, item)">
                                    <el-image class="item-thumb" :src="item.imgUrl" fit="cover">
                                        <template #error>
                                            <div class="thumb-error"><i class="el-icon-picture-outline"></i></div>
                                        </template>
                                    </el-image>
                                    <div class="item-details">
                                        <div class="item-top">
                                            <h3 class="item-name">{{ item.idleName }}</h3>
                                            <span class="item-price">¥{{ item.idlePrice }}</span>
                                        </div>
                                        <p class="item-desc" v-html="item.idleDetails"></p>
                                        <div class="item-bottom">
                                            <span class="item-time"><i class="el-icon-time"></i> {{ item.timeStr }}</span>
                                            <div class="item-actions">
                                                <span v-if="activeName === '4' || activeName === '5'" class="order-status">
                                                    {{ orderStatus[item.orderStatus] }}
                                                </span>
                                                <el-button
                                                    v-if="activeName !== '4' && activeName !== '5'"
                                                    type="danger"
                                                    size="small"
                                                    plain
                                                    round
                                                    @click.stop="handle(activeName, item, index)">
                                                    {{ handleName[activeName - 1] }}
                                                </el-button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div v-if="dataList[activeName - 1].length === 0" class="empty-state premium-card">
                                <i :class="getEmptyIcon(activeName)"></i>
                                <p>{{ getEmptyText(activeName) }}</p>
                                <el-button v-if="activeName === '1'" type="primary" round @click="$router.push('/release')">去发布</el-button>
                            </div>
                        </div>
                    </div>
                </div>

                <el-dialog
                    title="编辑个人资料"
                    v-model="userInfoDialogVisible"
                    width="440px"
                    class="premium-dialog"
                    @close="finishEdit"
                    center>
                    <div class="edit-dialog-content">
                        <div class="input-group">
                            <label>用户昵称</label>
                            <el-input v-model="userInfo.nickname" :disabled="notUserNicknameEdit" placeholder="设置一个好记的昵称">
                                <template #append>
                                    <el-button @click="notUserNicknameEdit = !notUserNicknameEdit">
                                        {{ notUserNicknameEdit ? '编辑' : '锁定' }}
                                    </el-button>
                                </template>
                            </el-input>
                        </div>

                        <div class="password-section" v-if="userPasswordEdit">
                            <div class="input-group">
                                <label>原密码</label>
                                <el-input v-model="userPassword1" type="password" show-password></el-input>
                            </div>
                            <div class="input-group">
                                <label>新密码</label>
                                <el-input v-model="userPassword2" type="password" show-password></el-input>
                            </div>
                            <div class="input-group">
                                <label>确认新密码</label>
                                <el-input v-model="userPassword3" type="password" show-password></el-input>
                            </div>
                            <div class="dialog-actions">
                                <el-button type="primary" @click="savePassword">保存新密码</el-button>
                                <el-button @click="userPasswordEdit = false">取消</el-button>
                            </div>
                        </div>

                        <div class="input-group" v-else>
                            <label>登录密码</label>
                            <el-input value="********" disabled>
                                <template #append>
                                    <el-button @click="userPasswordEdit = true">修改密码</el-button>
                                </template>
                            </el-input>
                        </div>
                    </div>
                    <template #footer>
                        <el-button type="primary" class="full-width" @click="saveUserNickname">保存更改</el-button>
                    </template>
                </el-dialog>
            </div>

            <div class="address-management" v-show="eidtAddress">
                <div class="address-header-row">
                    <el-page-header @back="eidtAddress = false" title="返回个人中心" content="收货地址管理"></el-page-header>
                </div>

                <el-row :gutter="24">
                    <el-col :md="10">
                        <div class="address-form-card premium-card">
                            <h3>{{ addressInfo.id ? '编辑地址' : '新增地址' }}</h3>
                            <el-form label-position="top" :model="addressInfo">
                                <el-form-item label="收件人">
                                    <el-input v-model="addressInfo.consigneeName" placeholder="姓名"></el-input>
                                </el-form-item>
                                <el-form-item label="联系电话">
                                    <el-input v-model="addressInfo.consigneePhone" placeholder="手机号"></el-input>
                                </el-form-item>
                                <el-form-item label="所在地区">
                                    <el-cascader
                                        style="width: 100%"
                                        :options="options"
                                        v-model="selectedOptions"
                                        @change="handleAddressChange"
                                        placeholder="选择区域">
                                    </el-cascader>
                                </el-form-item>
                                <el-form-item label="详细地址">
                                    <el-input type="textarea" :rows="3" v-model="addressInfo.detailAddress" placeholder="楼栋、门牌号等"></el-input>
                                </el-form-item>
                                <el-form-item>
                                    <el-checkbox v-model="addressInfo.defaultFlag">设为默认收货地址</el-checkbox>
                                </el-form-item>
                                <div class="dialog-actions">
                                    <el-button type="primary" @click="saveAddress">{{ addressInfo.id ? '更新地址' : '立即保存' }}</el-button>
                                    <el-button @click="resetAddressForm">重置</el-button>
                                </div>
                            </el-form>
                        </div>
                    </el-col>

                    <el-col :md="14">
                        <div v-if="addressData.length === 0" class="empty-state premium-card">
                            <i class="el-icon-map-location"></i>
                            <p>您还没有添加任何收货地址</p>
                        </div>
                        <div v-else class="address-grid">
                            <div v-for="(address, index) in addressData" :key="index" class="address-item premium-card" :class="{ default: address.defaultFlag }">
                                <div class="address-item-top">
                                    <span class="name">{{ address.consigneeName }}</span>
                                    <span class="phone">{{ address.consigneePhone }}</span>
                                    <el-tag v-if="address.defaultFlag" size="mini" type="success" effect="plain">默认</el-tag>
                                </div>
                                <div class="address-item-mid">
                                    <p>{{ address.detailAddressText }}</p>
                                </div>
                                <div class="address-item-bottom">
                                    <el-button type="text" icon="el-icon-edit" @click="handleEdit(index, address)">编辑</el-button>
                                    <el-button v-if="!address.defaultFlag" type="text" icon="el-icon-star-off" @click="handleSetDefault(index, address)">设为默认</el-button>
                                    <el-button type="text" class="delete-btn" icon="el-icon-delete" @click="handleDelete(index, address)">删除</el-button>
                                </div>
                            </div>
                        </div>
                    </el-col>
                </el-row>
            </div>

            <app-foot></app-foot>
        </app-body>
    </div>
</template>

<script>
import AppHead from '../common/AppHeader.vue';
import AppBody from '../common/AppPageBody.vue';
import AppFoot from '../common/AppFoot.vue';
import { pcaTextArr } from 'element-china-area-data';

const uploadAction = import.meta.env.DEV
    ? '/api/file'
    : `${(import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080').replace(/\/$/, '')}/file`;

export default {
    name: 'me',
    components: { AppHead, AppBody, AppFoot },
    data() {
        return {
            uploadAction,
            addressInfo: {
                consigneeName: '',
                consigneePhone: '',
                provinceName: '',
                cityName: '',
                regionName: '',
                detailAddress: '',
                defaultFlag: false
            },
            activeName: '1',
            handleName: ['下架手机', '彻底删除', '移出收藏', '', ''],
            menuOptions: [
                { label: '正在出售', value: '1', icon: 'el-icon-upload' },
                { label: '已下架', value: '2', icon: 'el-icon-download' },
                { label: '我的收藏', value: '3', icon: 'el-icon-star-on' },
                { label: '卖出订单', value: '4', icon: 'el-icon-sell' },
                { label: '买入订单', value: '5', icon: 'el-icon-shopping-bag-1' }
            ],
            dataList: [[], [], [], [], [], [], [], []],
            orderStatus: ['待付款', '待发货', '待收货', '已完成', '已取消'],
            userInfoDialogVisible: false,
            notUserNicknameEdit: true,
            userPasswordEdit: false,
            userPassword1: '',
            userPassword2: '',
            userPassword3: '',
            eidtAddress: false,
            selectedOptions: [],
            options: pcaTextArr,
            userInfo: {
                accountNumber: '',
                avatar: '',
                nickname: '',
                signInTime: ''
            },
            addressData: []
        };
    },
    created() {
        if (!this.$globalData.userInfo.nickname) {
            this.$api.getUserInfo().then(res => {
                if (res.status_code === 1) {
                    res.data.signInTime = res.data.signInTime.substring(0, 10);
                    this.$globalData.userInfo = res.data;
                    this.userInfo = this.$globalData.userInfo;
                }
            });
        } else {
            this.userInfo = this.$globalData.userInfo;
        }
        this.getAddressData();
        this.getIdleItemData();
        this.getMyOrder();
        this.getMySoldIdle();
        this.getMyFavorite();
    },
    methods: {
        getMenuLabel(val) {
            const menu = this.menuOptions.find(m => m.value === val);
            return menu ? menu.label : '';
        },
        getEmptyIcon(tabName) {
            const icons = {
                '1': 'el-icon-mobile-phone',
                '2': 'el-icon-remove-outline',
                '3': 'el-icon-star-on',
                '4': 'el-icon-sell',
                '5': 'el-icon-shopping-bag-1'
            };
            return icons[tabName] || 'el-icon-document';
        },
        getEmptyText(tabName) {
            const texts = {
                '1': '还没有发布过手机哦',
                '2': '暂无下架手机',
                '3': '还没有收藏任何手机',
                '4': '还没有卖出过手机',
                '5': '还没有买入过手机'
            };
            return texts[tabName] || '暂无数据';
        },
        getMyFavorite() {
            this.$api.getMyFavorite().then(res => {
                if (res.status_code === 1) {
                    for (let i = 0; i < res.data.length; i += 1) {
                        const pictureList = JSON.parse(res.data[i].idleItem.pictureList);
                        this.dataList[2].push({
                            favoriteId: res.data[i].id,
                            id: res.data[i].idleItem.id,
                            imgUrl: pictureList.length > 0 ? pictureList[0] : '',
                            idleName: res.data[i].idleItem.idleName,
                            idleDetails: res.data[i].idleItem.idleDetails,
                            timeStr: res.data[i].createTime.substring(0, 10) + ' ' + res.data[i].createTime.substring(11, 19),
                            idlePrice: res.data[i].idleItem.idlePrice
                        });
                    }
                }
            });
        },
        getMySoldIdle() {
            this.$api.getMySoldIdle().then(res => {
                if (res.status_code === 1) {
                    for (let i = 0; i < res.data.length; i += 1) {
                        const pictureList = JSON.parse(res.data[i].idleItem.pictureList);
                        this.dataList[3].push({
                            id: res.data[i].id,
                            imgUrl: pictureList.length > 0 ? pictureList[0] : '',
                            idleName: res.data[i].idleItem.idleName,
                            idleDetails: res.data[i].idleItem.idleDetails,
                            timeStr: res.data[i].createTime.substring(0, 10) + ' ' + res.data[i].createTime.substring(11, 19),
                            idlePrice: res.data[i].orderPrice,
                            orderStatus: res.data[i].orderStatus
                        });
                    }
                }
            });
        },
        getMyOrder() {
            this.$api.getMyOrder().then(res => {
                if (res.status_code === 1) {
                    for (let i = 0; i < res.data.length; i += 1) {
                        const pictureList = JSON.parse(res.data[i].idleItem.pictureList);
                        this.dataList[4].push({
                            id: res.data[i].id,
                            imgUrl: pictureList.length > 0 ? pictureList[0] : '',
                            idleName: res.data[i].idleItem.idleName,
                            idleDetails: res.data[i].idleItem.idleDetails,
                            timeStr: res.data[i].createTime.substring(0, 10) + ' ' + res.data[i].createTime.substring(11, 19),
                            idlePrice: res.data[i].orderPrice,
                            orderStatus: res.data[i].orderStatus
                        });
                    }
                }
            });
        },
        getIdleItemData() {
            this.$api.getAllIdleItem().then(res => {
                if (res.status_code === 1) {
                    for (let i = 0; i < res.data.length; i += 1) {
                        res.data[i].timeStr = res.data[i].releaseTime.substring(0, 10) + ' ' + res.data[i].releaseTime.substring(11, 19);
                        const pictureList = JSON.parse(res.data[i].pictureList);
                        res.data[i].imgUrl = pictureList.length > 0 ? pictureList[0] : '';
                        if (res.data[i].idleStatus === 1) {
                            this.dataList[0].push(res.data[i]);
                        } else if (res.data[i].idleStatus === 2) {
                            this.dataList[1].push(res.data[i]);
                        }
                    }
                }
            });
        },
        getAddressData() {
            this.$api.getAddress().then(res => {
                if (res.status_code === 1) {
                    const data = res.data;
                    for (let i = 0; i < data.length; i += 1) {
                        data[i].detailAddressText = [data[i].provinceName, data[i].cityName, data[i].regionName, data[i].detailAddress]
                            .filter(Boolean)
                            .join(' ');
                    }
                    this.addressData = data;
                }
            });
        },
        saveUserNickname() {
            this.notUserNicknameEdit = true;
            this.$api.updateUserPublicInfo({ nickname: this.userInfo.nickname }).then(() => {
                this.$globalData.userInfo.nickname = this.userInfo.nickname;
                this.$message.success('昵称更新成功');
                this.userInfoDialogVisible = false;
            });
        },
        savePassword() {
            if (!this.userPassword1 || !this.userPassword2) {
                this.$message.error('请输入完整密码');
            } else if (this.userPassword2 === this.userPassword3) {
                this.$api.updatePassword({
                    oldPassword: this.userPassword1,
                    newPassword: this.userPassword2
                }).then(res => {
                    if (res.status_code === 1) {
                        this.userPasswordEdit = false;
                        this.$message.success('密码修改成功');
                        this.userPassword1 = '';
                        this.userPassword2 = '';
                        this.userPassword3 = '';
                    } else {
                        this.$message.error('原密码不正确');
                    }
                });
            } else {
                this.$message.error('两次输入的新密码不一致');
            }
        },
        finishEdit() {
            this.notUserNicknameEdit = true;
            this.userPasswordEdit = false;
        },
        handleAddressChange(value) {
            this.addressInfo.provinceName = value[0];
            this.addressInfo.cityName = value[1];
            this.addressInfo.regionName = value[2];
        },
        handleEdit(index, row) {
            this.addressInfo = JSON.parse(JSON.stringify(row));
            this.selectedOptions = [row.provinceName, row.cityName, row.regionName];
        },
        handleDelete(index, row) {
            this.$confirm('确定要删除这个收货地址吗？', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning',
                roundButton: true
            }).then(() => {
                this.$api.deleteAddress(row).then(res => {
                    if (res.status_code === 1) {
                        this.$message.success('删除成功');
                        this.getAddressData();
                    } else {
                        this.$message.error('删除失败');
                    }
                });
            }).catch(() => {});
        },
        handleSetDefault(index, row) {
            row.defaultFlag = true;
            this.update(row);
        },
        toDetails(activeName, item) {
            if (activeName === '4' || activeName === '5') {
                this.$router.push({ path: '/order', query: { id: item.id } });
            } else {
                this.$router.push({ path: '/details', query: { id: item.id } });
            }
        },
        handle(activeName, item, index) {
            this.$confirm('确认执行此操作？', '操作确认', {
                confirmButtonText: '确认',
                cancelButtonText: '取消',
                type: 'warning',
                roundButton: true
            }).then(() => {
                if (activeName === '1') {
                    this.$api.updateIdleItem({ id: item.id, idleStatus: 2 }).then(res => {
                        if (res.status_code === 1) {
                            this.dataList[0].splice(index, 1);
                            item.idleStatus = 2;
                            this.dataList[1].unshift(item);
                            this.$message.success('已下架');
                        }
                    });
                } else if (activeName === '2') {
                    this.$api.updateIdleItem({ id: item.id, idleStatus: 0 }).then(res => {
                        if (res.status_code === 1) {
                            this.dataList[1].splice(index, 1);
                            this.$message.success('已删除');
                        }
                    });
                } else if (activeName === '3') {
                    this.$api.deleteFavorite({ id: item.favoriteId }).then(res => {
                        if (res.status_code === 1) {
                            this.dataList[2].splice(index, 1);
                            this.$message.success('已移出收藏');
                        }
                    });
                }
            }).catch(() => {});
        },
        fileHandleSuccess(response) {
            if (!response || response.status_code !== 1 || !response.data) {
                this.$message.error('头像上传失败');
                return;
            }
            const imgUrl = response.data;
            this.$api.updateUserPublicInfo({ avatar: imgUrl }).then(() => {
                this.userInfo.avatar = imgUrl;
                this.$globalData.userInfo.avatar = imgUrl;
                this.$message.success('头像更新成功');
            });
        },
        fileHandleError() {
            this.$message.error('头像上传失败，请稍后重试');
        },
        update(data) {
            this.$api.updateAddress(data).then(res => {
                if (res.status_code === 1) {
                    this.getAddressData();
                    this.$message.success('操作成功');
                }
            });
        },
        saveAddress() {
            if (this.addressInfo.id) {
                this.update(this.addressInfo);
                this.resetAddressForm();
            } else if (this.addressData.length >= 5) {
                this.$message.error('最多只能添加 5 个地址');
            } else {
                this.$api.addAddress(this.addressInfo).then(res => {
                    if (res.status_code === 1) {
                        this.getAddressData();
                        this.$message.success('新增成功');
                        this.resetAddressForm();
                    }
                });
            }
        },
        resetAddressForm() {
            this.addressInfo = {
                consigneeName: '',
                consigneePhone: '',
                provinceName: '',
                cityName: '',
                regionName: '',
                detailAddress: '',
                defaultFlag: false
            };
            this.selectedOptions = [];
        }
    }
};
</script>

<style scoped>
.me-page { background-color: var(--bg-gray); }
.dashboard-container, .address-management { padding: 24px 0; }
.profile-card { display: flex; justify-content: space-between; align-items: center; padding: 32px; margin-bottom: 24px; }
.profile-main { display: flex; align-items: center; gap: 24px; }
.profile-text h1 { margin: 0 0 8px; font-size: 30px; }
.profile-text p { margin: 0 0 16px; color: var(--text-muted); }
.profile-actions { display: flex; gap: 12px; }
.profile-stats { display: flex; gap: 24px; }
.stat-box { display: flex; flex-direction: column; align-items: center; }
.stat-value { font-size: 28px; font-weight: 800; color: var(--primary-blue); }
.stat-label { font-size: 13px; color: var(--text-muted); }
.dashboard-content { display: flex; gap: 24px; }
.sidebar-menu { width: 260px; padding: 16px; height: fit-content; position: sticky; top: 96px; }
.menu-item { display: flex; align-items: center; gap: 12px; padding: 14px 18px; border-radius: 12px; cursor: pointer; margin-bottom: 4px; }
.menu-item.active { background: rgba(37, 99, 235, 0.08); color: var(--primary-blue); }
.menu-badge { margin-left: auto; }
.main-list-section { flex: 1; }
.section-header { margin-bottom: 20px; }
.item-list { display: flex; flex-direction: column; gap: 16px; }
.list-card { border: 1px solid var(--border-color); }
.list-card-content { display: flex; gap: 20px; padding: 20px; cursor: pointer; }
.item-thumb { width: 120px; height: 120px; border-radius: 12px; flex-shrink: 0; }
.thumb-error { width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; background: #f1f5f9; color: #94a3b8; }
.item-details { flex: 1; display: flex; flex-direction: column; }
.item-top, .item-bottom { display: flex; justify-content: space-between; align-items: center; }
.item-name { font-size: 18px; font-weight: 700; }
.item-price { font-size: 20px; font-weight: 800; color: var(--primary-blue); }
.item-desc { color: var(--text-muted); margin: 8px 0 16px; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.item-time, .order-status { font-size: 13px; color: var(--text-muted); }
.empty-state { padding: 72px 0; display: flex; flex-direction: column; align-items: center; gap: 16px; color: var(--text-muted); }
.empty-state i { font-size: 56px; opacity: 0.35; }
.edit-dialog-content { display: flex; flex-direction: column; gap: 16px; }
.input-group label { display: block; margin-bottom: 8px; font-size: 13px; color: var(--text-muted); }
.dialog-actions { display: flex; gap: 12px; }
.full-width { width: 100%; }
.address-header-row { margin-bottom: 24px; }
.address-form-card { padding: 24px; }
.address-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 20px;
}

.address-item {
    position: relative;
    padding: 24px;
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 180px;
}

.address-item.default {
    border: 2px solid var(--success-green);
    background: linear-gradient(to bottom right, #ffffff, #f0fdf4);
}

.address-item-top {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
    flex-wrap: wrap;
}

.address-item-top .name {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-primary);
}

.address-item-top .phone {
    font-size: 15px;
    color: var(--text-secondary);
    font-weight: 500;
}

.address-item-mid {
    flex: 1;
    margin-bottom: 20px;
}

.address-item-mid p {
    margin: 0;
    font-size: 14px;
    line-height: 1.6;
    color: var(--text-secondary);
    word-break: break-all;
}

.address-item-bottom {
    display: flex;
    align-items: center;
    gap: 16px;
    margin-top: auto;
    padding-top: 16px;
    border-top: 1px solid rgba(226, 232, 240, 0.6);
}

.address-item-bottom .el-button {
    padding: 4px 0 !important;
    height: auto !important;
    font-size: 14px !important;
}

.delete-btn {
    color: var(--danger-red) !important;
    margin-left: auto;
}

.delete-btn:hover {
    opacity: 0.8;
}
@media (max-width: 1024px) { .profile-card, .dashboard-content { flex-direction: column; align-items: stretch; } .sidebar-menu { width: 100%; position: static; } }
</style>
