<template>
    <div>
        <app-head></app-head>
        <app-body>
            <div class="release-page-container">
                <el-card class="release-card" shadow="hover">
                    <template #header>
                        <div class="release-header">
                            <h2 class="release-title">
                                <i class="el-icon-upload2"></i>
                                发布手机 / 配件
                            </h2>
                            <p class="release-subtitle">填写真实机况、价格和位置，能明显提高成交效率。</p>
                        </div>
                    </template>

                    <el-form label-position="top" :model="idleItemInfo" class="release-form">
                        <el-card class="form-section" shadow="never">
                            <template #header>
                                <div class="section-header">
                                    <i class="el-icon-document"></i>
                                    基本信息
                                </div>
                            </template>

                            <el-form-item label="标题">
                                <el-input
                                    v-model="idleItemInfo.idleName"
                                    placeholder="例如：iPhone 13 128G / 小米 14 / AirPods Pro 2"
                                    maxlength="30"
                                    prefix-icon="el-icon-edit"
                                    show-word-limit />
                            </el-form-item>

                            <el-form-item label="详细描述">
                                <el-input
                                    v-model="idleItemInfo.idleDetails"
                                    class="release-idle-details"
                                    type="textarea"
                                    :rows="4"
                                    maxlength="1000"
                                    placeholder="请详细说明成色、内存版本、电池健康、维修记录、配件是否齐全等信息"
                                    show-word-limit />
                            </el-form-item>
                        </el-card>

                        <el-card class="form-section" shadow="never">
                            <template #header>
                                <div class="section-header">
                                    <i class="el-icon-s-grid"></i>
                                    分类与价格
                                </div>
                            </template>

                            <el-row :gutter="20">
                                <el-col :span="12">
                                    <el-form-item label="手机分类">
                                        <el-select
                                            v-model="idleItemInfo.idleLabel"
                                            placeholder="请选择分类"
                                            style="width: 100%"
                                            class="category-select">
                                            <el-option
                                                v-for="item in categoryOptions"
                                                :key="item.value"
                                                :label="item.label"
                                                :value="item.value">
                                                <span class="category-icon">
                                                    <i :class="getCategoryIcon(item.value)"></i>
                                                </span>
                                                <span>{{ item.label }}</span>
                                            </el-option>
                                        </el-select>
                                    </el-form-item>
                                </el-col>

                                <el-col :span="12">
                                    <el-form-item label="价格">
                                        <el-input-number
                                            v-model="idleItemInfo.idlePrice"
                                            :precision="2"
                                            :step="10"
                                            :min="0"
                                            :max="10000000"
                                            style="width: 100%"
                                            class="price-input" />
                                    </el-form-item>
                                </el-col>
                            </el-row>

                            <el-form-item label="所在地区">
                                <el-cascader
                                    v-model="selectedOptions"
                                    :options="options"
                                    :separator="' / '"
                                    placeholder="请选择省 / 市 / 区"
                                    style="width: 100%"
                                    class="location-select"
                                    @change="handleChange" />
                            </el-form-item>
                        </el-card>

                        <el-card class="form-section" shadow="never">
                            <template #header>
                                <div class="section-header">
                                    <i class="el-icon-picture-outline"></i>
                                    上传图片
                                    <span class="upload-tip">建议上传正面、背面、边框和电池信息页</span>
                                </div>
                            </template>

                            <el-upload
                                :action="uploadAction"
                                :on-preview="fileHandlePreview"
                                :on-remove="fileHandleRemove"
                                :on-success="fileHandleSuccess"
                                :show-file-list="showFileList"
                                :limit="10"
                                :on-exceed="handleExceed"
                                accept="image/*"
                                drag
                                multiple
                                class="upload-area">
                                <i class="el-icon-upload"></i>
                                <div class="el-upload__text">拖拽图片到此处，或 <em>点击上传</em></div>
                                <template #tip>
                                    <div class="el-upload__tip">支持 JPG/PNG，单张不超过 5MB，最多 10 张</div>
                                </template>
                            </el-upload>

                            <div v-if="imgList.length > 0" class="image-preview-section">
                                <div class="preview-title">已上传 {{ imgList.length }} 张图片</div>
                                <div class="image-preview-list">
                                    <el-image
                                        v-for="(img, index) in imgList"
                                        :key="index"
                                        :src="img"
                                        fit="cover"
                                        class="preview-image"
                                        :preview-src-list="imgList" />
                                </div>
                            </div>

                            <el-dialog v-model="imgDialogVisible">
                                <img width="100%" :src="dialogImageUrl" alt="">
                            </el-dialog>
                        </el-card>

                        <div class="submit-section">
                            <el-button
                                type="primary"
                                round
                                icon="el-icon-shopping-bag-1"
                                :loading="submitting"
                                class="submit-button"
                                @click="releaseButton">
                                发布商品
                            </el-button>
                            <el-button
                                round
                                icon="el-icon-refresh-left"
                                class="reset-button"
                                @click="resetForm">
                                重置表单
                            </el-button>
                        </div>
                    </el-form>
                </el-card>
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

const createDefaultItem = () => ({
    idleName: '',
    idleDetails: '',
    pictureList: '',
    idlePrice: 0,
    idlePlace: '',
    idleLabel: ''
});

export default {
    name: 'release',
    components: {
        AppHead,
        AppBody,
        AppFoot
    },
    data() {
        return {
            uploadAction,
            imgDialogVisible: false,
            dialogImageUrl: '',
            showFileList: true,
            options: pcaTextArr,
            selectedOptions: [],
            submitting: false,
            categoryOptions: [
                { value: 1, label: '安卓手机' },
                { value: 2, label: '苹果手机' },
                { value: 3, label: '游戏手机' },
                { value: 4, label: '折叠屏手机' },
                { value: 5, label: '手机配件' }
            ],
            imgList: [],
            idleItemInfo: createDefaultItem()
        };
    },
    methods: {
        getCategoryIcon(categoryId) {
            const icons = {
                1: 'el-icon-mobile-phone',
                2: 'el-icon-phone-outline',
                3: 'el-icon-headset',
                4: 'el-icon-notebook-2',
                5: 'el-icon-cpu'
            };
            return icons[categoryId] || 'el-icon-goods';
        },
        handleChange(value) {
            if (value?.length === 3) {
                this.idleItemInfo.idlePlace = value.join(' / ');
            }
        },
        fileHandleRemove(file) {
            this.imgList = this.imgList.filter(img => img !== file.response?.data);
        },
        fileHandlePreview(file) {
            this.dialogImageUrl = file.response?.data || file.url;
            this.imgDialogVisible = true;
        },
        fileHandleSuccess(response) {
            this.imgList.push(response.data);
        },
        releaseButton() {
            if (!this.idleItemInfo.idleName) {
                this.$message.error('请输入标题');
                return;
            }
            if (!this.idleItemInfo.idleDetails) {
                this.$message.error('请输入详细描述');
                return;
            }
            if (!this.idleItemInfo.idlePlace) {
                this.$message.error('请选择所在地区');
                return;
            }
            if (!this.idleItemInfo.idleLabel) {
                this.$message.error('请选择手机分类');
                return;
            }
            if (this.idleItemInfo.idlePrice <= 0) {
                this.$message.error('请设置合理的价格');
                return;
            }

            this.submitting = true;
            this.idleItemInfo.pictureList = JSON.stringify(this.imgList);

            this.$api.addIdleItem(this.idleItemInfo).then(res => {
                if (res.status_code === 1) {
                    this.$message({
                        message: '发布成功',
                        type: 'success'
                    });
                    this.$router.replace({ path: '/details', query: { id: res.data.id } });
                } else {
                    this.$message.error(`发布失败：${res.msg}`);
                }
            }).catch(() => {
                this.$message.error('网络错误，请稍后重试');
            }).finally(() => {
                this.submitting = false;
            });
        },
        handleExceed(files, fileList) {
            this.$message.warning(`最多上传 10 张图片，本次选择 ${files.length} 张，当前共 ${files.length + fileList.length} 张`);
        },
        resetForm() {
            this.$confirm('确定要重置表单吗？已填写的内容会丢失。', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.idleItemInfo = createDefaultItem();
                this.selectedOptions = [];
                this.imgList = [];
                this.$message({
                    type: 'success',
                    message: '表单已重置'
                });
            }).catch(() => {});
        }
    }
};
</script>

<style scoped>
.release-page-container {
    max-width: 1100px;
    margin: 0 auto;
}

.release-card {
    border-radius: 24px;
}

.release-header {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.release-title {
    margin: 0;
    font-size: 28px;
    font-weight: 800;
    color: var(--text-title);
}

.release-subtitle {
    margin: 0;
    color: var(--text-light);
    font-size: 14px;
}

.release-form {
    display: flex;
    flex-direction: column;
    gap: 20px;
}

.form-section {
    border-radius: 20px;
}

.section-header {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 700;
    color: var(--text-title);
}

.upload-tip {
    color: var(--text-light);
    font-size: 12px;
    font-weight: 500;
}

.category-icon {
    width: 20px;
    display: inline-flex;
}

.image-preview-section {
    margin-top: 20px;
}

.preview-title {
    margin-bottom: 12px;
    font-weight: 700;
    color: var(--text-title);
}

.image-preview-list {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
    gap: 12px;
}

.preview-image {
    width: 100%;
    height: 120px;
    border-radius: 16px;
    overflow: hidden;
}

.submit-section {
    display: flex;
    justify-content: center;
    gap: 16px;
    padding: 12px 0 4px;
}

.submit-button,
.reset-button {
    min-width: 160px;
}

@media (max-width: 768px) {
    .submit-section {
        flex-direction: column;
    }
}
</style>
