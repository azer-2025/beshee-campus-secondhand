<template>
    <div class="me-page">
        <app-head :nickname-value="userInfo.nickname" :avatarValue="userInfo.avatar"></app-head>
        <app-body>
            <div class="dashboard-container" v-show="!eidtAddress">
                <!-- Profile Header Card -->
                <div class="profile-header premium-card">
                    <div class="profile-main">
                        <div class="avatar-section">
                            <el-upload
                                :action="uploadAction"
                                :on-success="fileHandleSuccess"
                                :show-file-list="false"
                                accept="image/*"
                                class="avatar-uploader"
                            >
                                <div class="avatar-wrapper">
                                    <el-avatar :size="100" :src="displayAvatar" class="user-avatar" @error="handleAvatarError"></el-avatar>
                                    <div class="avatar-overlay">
                                        <i class="el-icon-camera"></i>
                                    </div>
                                </div>
                            </el-upload>
                        </div>
                        <div class="profile-info">
                            <h1 class="user-nickname">{{userInfo.nickname}}</h1>
                            <div class="user-meta">
                                <span class="meta-item"><i class="el-icon-date"></i> {{userInfo.signInTime}} 加入</span>
                                <span class="meta-item"><i class="el-icon-medal"></i> 认证用户</span>
                            </div>
                            <div class="profile-actions">
                                <el-button type="primary" size="medium" round @click="userInfoDialogVisible = true">
                                    <i class="el-icon-edit"></i> 编辑资料
                                </el-button>
                                <el-button type="info" size="medium" plain round @click="eidtAddress=true">
                                    <i class="el-icon-location"></i> 地址管理
                                </el-button>
                            </div>
                        </div>
                    </div>
                    
                    <div class="profile-stats">
                        <div class="stat-box">
                            <span class="stat-value">{{dataList[0].length}}</span>
                            <span class="stat-label">发布中</span>
                        </div>
                        <div class="stat-divider"></div>
                        <div class="stat-box">
                            <span class="stat-value">{{dataList[2].length}}</span>
                            <span class="stat-label">购物车</span>
                        </div>
                        <div class="stat-divider"></div>
                        <div class="stat-box">
                            <span class="stat-value">{{dataList[3].length}}</span>
                            <span class="stat-label">已售出</span>
                        </div>
                    </div>
                </div>

                <!-- Content Tabs & List -->
                <div class="dashboard-content">
                    <div class="sidebar-menu premium-card">
                        <div 
                            v-for="menu in menuOptions" 
                            :key="menu.value"
                            class="menu-item"
                            :class="{ active: activeName === menu.value }"
                            @click="activeName = menu.value"
                        >
                            <i :class="menu.icon"></i>
                            <span>{{menu.label}}</span>
                            <el-badge v-if="dataList[menu.value-1].length > 0" :value="dataList[menu.value-1].length" class="menu-badge" />
                        </div>
                    </div>

                    <div class="main-list-section">
                        <div class="section-header">
                            <h2>{{getMenuLabel(activeName)}}</h2>
                        </div>
                        
                        <div class="item-list">
                            <div v-for="(item,index) in dataList[activeName-1]" :key="index" class="list-card premium-card">
                                <div class="list-card-content" @click="toDetails(activeName,item)">
                                    <el-image class="item-thumb" :src="item.imgUrl" fit="cover">
                                        <template #error>
                                            <div class="thumb-error"><i class="el-icon-picture-outline"></i></div>
                                        </template>
                                    </el-image>
                                    <div class="item-details">
                                        <div class="item-top">
                                            <h3 class="item-name">{{item.idleName}}</h3>
                                            <span class="item-price">¥{{item.idlePrice}}</span>
                                        </div>
                                        <p class="item-desc" v-html="item.idleDetails"></p>
                                        <div class="item-bottom">
                                            <span class="item-time"><i class="el-icon-time"></i> {{item.timeStr}}</span>
                                            <div class="item-actions">
                                                <span v-if="activeName==='4'||activeName==='5'" class="order-status">
                                                    {{orderStatus[item.orderStatus]}}
                                                </span>
                                                <el-button 
                                                    v-if="activeName!=='4'&&activeName!=='5'" 
                                                    type="danger" 
                                                    size="small"
                                                    plain 
                                                    round
                                                    @click.stop="handle(activeName,item,index)">
                                                    {{handleName[activeName-1]}}
                                                </el-button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div v-if="dataList[activeName-1].length === 0" class="empty-state premium-card">
                                <i :class="getEmptyIcon(activeName)"></i>
                                <p>{{getEmptyText(activeName)}}</p>
                                <el-button v-if="activeName === '1'" type="primary" round @click="$router.push('/release')">去发布</el-button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Edit Dialog -->
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
                            <el-input v-model="userInfo.nickname" :disabled="notUserNicknameEdit" placeholder="设置一个好听的昵称">
                                <template #append>
                                    <el-button @click="notUserNicknameEdit = !notUserNicknameEdit">
                                        {{notUserNicknameEdit ? '编辑' : '锁定'}}
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
                            <div class="edit-actions">
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

            <!-- Address Management Section -->
            <div class="address-management" v-show="eidtAddress">
                <div class="address-header-row">
                    <el-page-header @back="eidtAddress=false" title="返回控制台" content="收货地址管理"></el-page-header>
                </div>
                
                <el-row :gutter="24">
                    <el-col :md="10">
                        <div class="address-form-card premium-card">
                            <h3><i class="el-icon-plus"></i> {{addressInfo.id ? '编辑地址' : '新增地址'}}</h3>
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
                                        placeholder="选择宿舍楼/楼层">
                                    </el-cascader>
                                </el-form-item>
                                <el-form-item label="详细地址">
                                    <el-input type="textarea" :rows="3" v-model="addressInfo.detailAddress" placeholder="宿舍号及详细说明"></el-input>
                                </el-form-item>
                                <el-form-item>
                                    <el-checkbox v-model="addressInfo.defaultFlag">设为默认收货地址</el-checkbox>
                                </el-form-item>
                                <div class="form-btns">
                                    <el-button type="primary" @click="saveAddress">{{addressInfo.id ? '更新地址' : '立即保存'}}</el-button>
                                    <el-button @click="resetAddressForm">重置</el-button>
                                </div>
                            </el-form>
                        </div>
                    </el-col>
                    <el-col :md="14">
                        <div class="address-list-section">
                            <div v-if="addressData.length === 0" class="empty-address premium-card">
                                <i class="el-icon-map-location"></i>
                                <p>您还没有添加任何收货地址</p>
                            </div>
                            <div v-else class="address-grid">
                                <div v-for="(address, index) in addressData" :key="index" class="address-item premium-card" :class="{default: address.defaultFlag}">
                                    <div class="address-item-top">
                                        <span class="name">{{address.consigneeName}}</span>
                                        <span class="phone">{{address.consigneePhone}}</span>
                                        <el-tag v-if="address.defaultFlag" size="mini" type="success" effect="plain">默认</el-tag>
                                    </div>
                                    <div class="address-item-mid">
                                        <p>{{address.detailAddressText}}</p>
                                    </div>
                                    <div class="address-item-bottom">
                                        <el-button type="text" icon="el-icon-edit" @click="handleEdit(index, address)">编辑</el-button>
                                        <el-button v-if="!address.defaultFlag" type="text" icon="el-icon-star-off" @click="handleSetDefault(index, address)">设为默认</el-button>
                                        <el-button type="text" class="delete-btn" icon="el-icon-delete" @click="handleDelete(index, address)">删除</el-button>
                                    </div>
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
    import AppBody from '../common/AppPageBody.vue'
    import AppFoot from '../common/AppFoot.vue'
    import options from '../common/country-data.js'
    import { DEFAULT_AVATAR, resolveAssetUrl } from '../../utils/asset';

    const uploadAction = import.meta.env.DEV
        ? '/api/file'
        : `${(import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080').replace(/\/$/, '')}/file`;

    export default {
        name: "me",
        components: {
            AppHead,
            AppBody,
            AppFoot
        },
        data() {
            return {
                uploadAction,
                imgFileList: [],
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
                handleName: ['下架商品', '彻底删除', '移出购物车', '', ''],
                menuOptions: [
                    { label: '刚刚发布', value: '1', icon: 'el-icon-upload' },
                    { label: '已经下架', value: '2', icon: 'el-icon-download' },
                    { label: '我的购物车', value: '3', icon: 'el-icon-shopping-cart-full' },
                    { label: '出售记录', value: '4', icon: 'el-icon-sell' },
                    { label: '购买记录', value: '5', icon: 'el-icon-shopping-bag-1' }
                ],
                dataList: [[],[],[],[],[],[],[],[]],
                orderStatus: ['待付款', '待发货', '待收货', '已完成', '已取消'],
                userInfoDialogVisible: false,
                notUserNicknameEdit: true,
                userPasswordEdit: false,
                userPassword1: '',
                userPassword2: '',
                userPassword3: '',
                eidtAddress: false,
                selectedOptions: [],
                options: options,
                defaultAvatar: DEFAULT_AVATAR,
                avatarLoadFailed: false,
                userInfo: {
                    accountNumber: "",
                    avatar: "",
                    nickname: "",
                    signInTime: "",
                },
                addressData: []
            };
        },
        computed: {
            displayAvatar() {
                if (this.avatarLoadFailed) {
                    return this.defaultAvatar;
                }
                return resolveAssetUrl(this.userInfo.avatar, this.defaultAvatar);
            }
        },
        watch: {
            'userInfo.avatar'() {
                this.avatarLoadFailed = false;
            }
        },
        created() {
            if (!this.$globalData.userInfo.nickname) {
                this.$api.getUserInfo().then(res => {
                    if (res.status_code === 1) {
                        res.data.signInTime = res.data.signInTime.substring(0, 10);
                        this.$globalData.userInfo = res.data;
                        this.userInfo = this.$globalData.userInfo;
                    }
                })
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
            handleAvatarError() {
                this.avatarLoadFailed = true;
                return false;
            },
            getMenuLabel(val) {
                const menu = this.menuOptions.find(m => m.value === val);
                return menu ? menu.label : '';
            },
            getEmptyIcon(tabName) {
                const icons = {
                    '1': 'el-icon-upload',
                    '2': 'el-icon-download',
                    '3': 'el-icon-shopping-cart-full',
                    '4': 'el-icon-sell',
                    '5': 'el-icon-shopping-bag-1'
                };
                return icons[tabName] || 'el-icon-document';
            },
            getEmptyText(tabName) {
                const texts = {
                    '1': '还没有发布过商品哦',
                    '2': '暂无下架商品',
                    '3': '购物车空空如也',
                    '4': '还没有卖出过商品',
                    '5': '还没有买过东西呢'
                };
                return texts[tabName] || '暂无数据';
            },
            getMyFavorite(){
                this.$api.getMyFavorite().then(res=>{
                    if (res.status_code === 1){
                        for (let i = 0; i < res.data.length; i++) {
                            let pictureList = JSON.parse(res.data[i].idleItem.pictureList);
                            this.dataList[2].push({
                                favoriteId:res.data[i].id,
                                id:res.data[i].idleItem.id,
                                imgUrl:pictureList.length > 0 ? pictureList[0] : '',
                                idleName:res.data[i].idleItem.idleName,
                                idleDetails:res.data[i].idleItem.idleDetails,
                                timeStr:res.data[i].createTime.substring(0, 10) + " " + res.data[i].createTime.substring(11, 19),
                                idlePrice:res.data[i].idleItem.idlePrice
                            });
                        }
                    }
                })
            },
            getMySoldIdle(){
                this.$api.getMySoldIdle().then(res=>{
                    if (res.status_code === 1){
                        for (let i = 0; i < res.data.length; i++) {
                            let pictureList = JSON.parse(res.data[i].idleItem.pictureList);
                            this.dataList[3].push({
                                id:res.data[i].id,
                                imgUrl:pictureList.length > 0 ? pictureList[0] : '',
                                idleName:res.data[i].idleItem.idleName,
                                idleDetails:res.data[i].idleItem.idleDetails,
                                timeStr:res.data[i].createTime.substring(0, 10) + " " + res.data[i].createTime.substring(11, 19),
                                idlePrice:res.data[i].orderPrice,
                                orderStatus:res.data[i].orderStatus
                            });
                        }
                    }
                })
            },
            getMyOrder(){
                this.$api.getMyOrder().then(res=>{
                    if (res.status_code === 1){
                        for (let i = 0; i < res.data.length; i++) {
                            let pictureList = JSON.parse(res.data[i].idleItem.pictureList);
                            this.dataList[4].push({
                                id:res.data[i].id,
                                imgUrl:pictureList.length > 0 ? pictureList[0] : '',
                                idleName:res.data[i].idleItem.idleName,
                                idleDetails:res.data[i].idleItem.idleDetails,
                                timeStr:res.data[i].createTime.substring(0, 10) + " " + res.data[i].createTime.substring(11, 19),
                                idlePrice:res.data[i].orderPrice,
                                orderStatus:res.data[i].orderStatus
                            });
                        }
                    }
                })
            },
            getIdleItemData() {
                this.$api.getAllIdleItem().then(res => {
                    if (res.status_code === 1) {
                        for (let i = 0; i < res.data.length; i++) {
                            res.data[i].timeStr = res.data[i].releaseTime.substring(0, 10) + " " + res.data[i].releaseTime.substring(11, 19);
                            let pictureList = JSON.parse(res.data[i].pictureList);
                            res.data[i].imgUrl = pictureList.length > 0 ? pictureList[0] : '';
                            if (res.data[i].idleStatus === 1) {
                                this.dataList[0].push(res.data[i]);
                            } else if (res.data[i].idleStatus === 2) {
                                this.dataList[1].push(res.data[i]);
                            }
                        }
                    }
                })
            },
            getAddressData() {
                this.$api.getAddress().then(res => {
                    if (res.status_code === 1) {
                        let data = res.data;
                        for (let i = 0; i < data.length; i++) {
                            data[i].detailAddressText = data[i].provinceName + data[i].cityName + data[i].regionName + data[i].detailAddress;
                        }
                        this.addressData = data;
                    }
                })
            },
            saveUserNickname() {
                this.notUserNicknameEdit = true;
                this.$api.updateUserPublicInfo({
                    nickname: this.userInfo.nickname
                }).then(res => {
                    this.$globalData.userInfo.nickname = this.userInfo.nickname;
                    this.$message.success('昵称更新成功');
                    this.userInfoDialogVisible = false;
                })
            },
            savePassword() {
                if (!this.userPassword1 || !this.userPassword2) {
                    this.$message.error('请输入密码');
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
                    })
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
                    })
                }).catch(() => {});
            },
            handleSetDefault(index, row) {
                row.defaultFlag = true;
                this.update(row);
            },
            toDetails(activeName, item) {
                if (activeName === '4'||activeName === '5') {
                    this.$router.push({path: '/order', query: {id: item.id}});
                } else {
                    this.$router.push({path: '/details', query: {id: item.id}});
                }
            },
            handle(activeName,item,index) {
                this.$confirm('确认执行此操作？', '操作确认', {
                    confirmButtonText: '确认',
                    cancelButtonText: '取消',
                    type: 'warning',
                    roundButton: true
                }).then(() => {
                    if(activeName==='1'){
                        this.$api.updateIdleItem({ id:item.id, idleStatus:2 }).then(res=>{
                            if(res.status_code===1){
                                this.dataList[0].splice(index,1);
                                item.idleStatus=2;
                                this.dataList[1].unshift(item);
                                this.$message.success('已下架');
                            }
                        });
                    }else if(activeName==='2'){
                        this.$api.updateIdleItem({ id:item.id, idleStatus:0 }).then(res=>{
                            if(res.status_code===1){
                                this.dataList[1].splice(index,1);
                                this.$message.success('已删除');
                            }
                        });
                    }else if(activeName==='3'){
                        this.$api.deleteFavorite({ id: item.favoriteId }).then(res=>{
                            if(res.status_code===1){
                                this.dataList[2].splice(index,1);
                                this.$message.success('已移出购物车');
                            }
                        });
                    }
                }).catch(() => {});
            },
            fileHandleSuccess(response, file, fileList) {
                if (!response || response.status_code !== 1 || !response.data) {
                    this.$message.error('头像上传失败');
                    return;
                }

                const imgUrl = response.data;
                this.$api.updateUserPublicInfo({ avatar: imgUrl }).then(res => {
                    if (res.status_code === 1) {
                        this.userInfo.avatar = imgUrl;
                        this.$globalData.userInfo.avatar = imgUrl;
                        this.avatarLoadFailed = false;
                        this.$message.success('头像更新成功');
                        return;
                    }
                    this.$message.error('头像更新失败');
                })
            },
            update(data) {
                this.$api.updateAddress(data).then(res => {
                    if (res.status_code === 1) {
                        this.getAddressData();
                        this.$message.success('操作成功');
                    }
                })
            },
            saveAddress() {
                if (this.addressInfo.id) {
                    this.update(this.addressInfo);
                    this.resetAddressForm();
                } else {
                    if (this.addressData.length >= 5) {
                        this.$message.error('最多只能添加5个地址');
                    } else {
                        this.$api.addAddress(this.addressInfo).then(res => {
                            if (res.status_code === 1) {
                                this.getAddressData();
                                this.$message.success('新增成功');
                                this.resetAddressForm();
                            }
                        })
                    }
                }
            },
            resetAddressForm() {
                this.addressInfo = {
                    consigneeName: '', consigneePhone: '', provinceName: '',
                    cityName: '', regionName: '', detailAddress: '', defaultFlag: false
                };
                this.selectedOptions = [];
            }
        }
    }
</script>

<style scoped>
.me-page {
    background-color: var(--bg-gray);
}

.dashboard-container {
    padding: 24px 0;
}

.profile-header {
    padding: 40px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 32px;
    background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
    border: 1px solid var(--border-color);
}

.profile-main {
    display: flex;
    align-items: center;
    gap: 32px;
}

.avatar-wrapper {
    position: relative;
    border-radius: 50%;
    padding: 4px;
    background: white;
    box-shadow: 0 4px 12px rgba(0,0,0,0.08);
    cursor: pointer;
}

.avatar-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    border-radius: 50%;
    background: rgba(0,0,0,0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 24px;
    opacity: 0;
    transition: opacity 0.3s;
}

.avatar-wrapper:hover .avatar-overlay {
    opacity: 1;
}

.user-nickname {
    font-size: 32px;
    font-weight: 800;
    color: var(--text-main);
    margin-bottom: 8px;
}

.user-meta {
    display: flex;
    gap: 20px;
    margin-bottom: 24px;
    color: var(--text-muted);
    font-size: 14px;
}

.meta-item {
    display: flex;
    align-items: center;
    gap: 6px;
}

.profile-actions {
    display: flex;
    gap: 12px;
}

.profile-stats {
    display: flex;
    gap: 40px;
    align-items: center;
}

.stat-box {
    display: flex;
    flex-direction: column;
    align-items: center;
}

.stat-value {
    font-size: 28px;
    font-weight: 800;
    color: var(--primary-blue);
}

.stat-label {
    font-size: 13px;
    color: var(--text-muted);
    margin-top: 4px;
}

.stat-divider {
    width: 1px;
    height: 40px;
    background: var(--border-color);
}

.dashboard-content {
    display: flex;
    gap: 32px;
}

.sidebar-menu {
    width: 280px;
    padding: 16px;
    height: fit-content;
    position: sticky;
    top: 96px;
}

.menu-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px 20px;
    border-radius: 12px;
    cursor: pointer;
    color: var(--text-muted);
    font-weight: 600;
    transition: all 0.2s;
    margin-bottom: 4px;
    position: relative;
}

.menu-item:hover {
    background: #f1f5f9;
    color: var(--text-main);
}

.menu-item.active {
    background: rgba(37, 99, 235, 0.08);
    color: var(--primary-blue);
}

.menu-item.active::before {
    content: '';
    position: absolute;
    left: 0;
    top: 20%;
    height: 60%;
    width: 4px;
    background: var(--primary-blue);
    border-radius: 0 4px 4px 0;
}

.menu-badge {
    margin-left: auto;
}

.main-list-section {
    flex: 1;
}

.section-header {
    margin-bottom: 24px;
}

.section-header h2 {
    font-size: 22px;
    font-weight: 700;
}

.item-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.list-card {
    cursor: pointer;
    transition: all 0.3s;
    border: 1px solid var(--border-color);
}

.list-card:hover {
    transform: translateX(8px);
    border-color: var(--primary-blue);
}

.list-card-content {
    display: flex;
    padding: 20px;
    gap: 20px;
}

.item-thumb {
    width: 120px;
    height: 120px;
    border-radius: 12px;
    flex-shrink: 0;
}

.thumb-error {
    width: 100%;
    height: 100%;
    background: #f1f5f9;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #94a3b8;
    font-size: 24px;
}

.item-details {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.item-top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 8px;
}

.item-name {
    font-size: 18px;
    font-weight: 700;
    color: var(--text-main);
}

.item-price {
    font-size: 20px;
    font-weight: 800;
    color: var(--primary-blue);
}

.item-desc {
    font-size: 14px;
    color: var(--text-muted);
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
    margin-bottom: 16px;
    line-height: 1.6;
}

.item-bottom {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: auto;
}

.item-time {
    font-size: 12px;
    color: var(--text-muted);
}

.order-status {
    font-weight: 600;
    color: var(--success-green);
    font-size: 14px;
}

.empty-state {
    padding: 80px 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 16px;
    color: var(--text-muted);
}

.empty-state i {
    font-size: 64px;
    opacity: 0.3;
}

.address-management {
    padding: 24px 0;
}

.address-header-row {
    margin-bottom: 32px;
}

.address-form-card {
    padding: 32px;
    position: sticky;
    top: 96px;
}

.address-form-card h3 {
    margin-bottom: 24px;
    font-size: 18px;
}

.form-btns {
    display: flex;
    gap: 12px;
    margin-top: 24px;
}

.address-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 20px;
}

.address-item {
    padding: 24px;
    border: 1px solid var(--border-color);
    position: relative;
}

.address-item.default {
    border-color: var(--success-green);
    background: rgba(16, 185, 129, 0.02);
}

.address-item-top {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 12px;
}

.address-item-top .name {
    font-weight: 700;
    font-size: 17px;
}

.address-item-top .phone {
    color: var(--text-muted);
    font-size: 14px;
}

.address-item-mid p {
    font-size: 14px;
    line-height: 1.6;
    color: var(--text-main);
    margin-bottom: 16px;
    min-height: 44px;
}

.address-item-bottom {
    display: flex;
    gap: 16px;
    border-top: 1px solid var(--border-color);
    padding-top: 12px;
}

.delete-btn {
    color: var(--danger-red) !important;
    margin-left: auto;
}

.premium-dialog :deep(.el-dialog) {
    border-radius: var(--radius-xl);
    overflow: hidden;
}

.edit-dialog-content {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.input-group label {
    display: block;
    font-size: 13px;
    font-weight: 600;
    color: var(--text-muted);
    margin-bottom: 8px;
}

.full-width {
    width: 100%;
    height: 44px;
}

@media (max-width: 1024px) {
    .dashboard-content { flex-direction: column; }
    .sidebar-menu { width: 100%; position: static; }
    .profile-header { flex-direction: column; align-items: flex-start; gap: 32px; }
}

@media (max-width: 768px) {
    .profile-main { flex-direction: column; align-items: center; text-align: center; }
    .profile-stats { width: 100%; justify-content: space-around; }
}
</style>
