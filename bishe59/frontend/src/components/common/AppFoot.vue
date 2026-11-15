<template>
    <div class="footer">
        <div class="footer-content">
            <div class="footer-logo">
                <i class="el-icon-mobile-phone"></i>
                <span>二手手机交易平台</span>
            </div>
        </div>
    </div>
</template>

<script>
export default {
    name: 'app-foot'
};
</script>

<style scoped>
.footer {
    background-color: #f5f7fa;
    color: #606266;
    padding: 30px 0 20px;
    width: 100%;
    border-top: 1px solid #e6e6e6;
}

.footer-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
    text-align: center;
}

.footer-logo {
    display: flex;
    align-items: center;
    justify-content: center;
    color: #409eff;
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 20px;
}

.footer-logo i {
    font-size: 24px;
    margin-right: 10px;
}

@media (max-width: 768px) {
    .footer {
        padding: 25px 0 15px;
    }

    .footer-logo {
        font-size: 18px;
    }

    .footer-logo i {
        font-size: 22px;
    }
}
</style>
