<p align="center">
  <h1 align="center">Harbor 容器镜像仓库管理工具</h1>
  <p align="center">
    <a href="README.md"><strong>English</strong></a> | <strong>简体中文</strong>
  </p>
</p>

## 目录

- [仓库简介](#项目介绍)
- [前置条件](#前置条件)
- [镜像说明](#镜像说明)
- [获取帮助](#获取帮助)
- [如何贡献](#如何贡献)

## 项目介绍
‌[Harbor‌](https://github.com/goharbor/harbor) Harbor 是一个开源的企业级容器镜像仓库（Registry）管理工具，由 VMware 公司（现为 Broadcom 旗下）开发并捐赠给 CNCF（云原生计算基金会）。它提供了镜像存储、安全扫描、访问控制、多租户管理等高级功能，适用于 Kubernetes 和 Docker 等容器化环境。

**核心特性：**
1. 企业级镜像仓库：Harbor提供安全可靠的Docker镜像存储与分发服务，支持多租户管理、镜像复制和垃圾回收。例如，可通过策略自动同步镜像到异地仓库，确保业务连续性。
2. 基于角色的访问控制（RBAC）：支持细粒度的用户权限管理，提供项目级权限控制（如管理员、开发者、访客角色），集成LDAP/AD、OIDC等认证方式，满足企业安全合规需求。
3. 漏洞扫描与安全合规：内置Trivy、Clair等漏洞扫描器，自动检测镜像中的CVE漏洞，生成详细报告并阻断高风险镜像部署。支持设置扫描策略（如定时扫描或推送时触发）。
4. 镜像签名与内容信任：集成Notary组件，支持Docker Content Trust（DCT），确保镜像来源可信且未被篡改。用户可验证签名后拉取镜像，防止供应链攻击。
5. 跨仓库复制策略：支持多实例间镜像的同步复制（单向/双向），提供基于事件或定时触发的策略，适用于混合云、边缘计算等分布式场景，例如将生产镜像同步到边缘节点。
6. 高性能与可扩展性：采用分布式架构设计，支持后端存储对接S3、Azure Blob等云存储，轻松扩展容量。通过Redis缓存加速镜像拉取，适应高并发场景。
7. Webhook与审计日志：提供完善的事件通知机制（如镜像推送/删除操作），可触发Webhook对接CI/CD流水线。所有操作记录审计日志，便于安全追溯与合规审查。
8. Helm Chart仓库：除Docker镜像外，支持Helm Chart的存储与管理，统一纳管Kubernetes应用编排文件，提供版本控制与依赖关系可视化。
9. 原生Kubernetes集成：与K8s无缝协作，通过Controller实现自动化的镜像拉取密钥管理（Pull Secret），简化集群对私有仓库的访问配置。
10. 用户友好界面与API：提供直观的Web控制台管理镜像、项目和成员，同时开放RESTful API，支持与DevOps工具链（如Jenkins、GitLab）深度集成。
11. 多租户隔离：通过项目（Project）实现资源隔离，每个租户可独立管理镜像和成员，适用于大型团队或SaaS服务场景。
12. 存储配额管理：可设置项目级存储配额，限制镜像总容量，防止资源滥用，并通过垃圾回收机制自动清理无引用层，优化存储空间。

本项目提供的开源镜像商品 [**`Harbor-容器镜像仓库管理工具`**]()，已预先安装 Harbor 软件及其相关运行环境，并提供部署模板。快来参照使用指南，轻松开启“开箱即用”的高效体验吧。

**架构设计：**

![](./images/img.png)

> **系统要求如下：**
> - CPU: 4vCPUs 或更高
> - RAM: 16GB 或更大
> - Disk: 至少 50GB

## 前置条件
[注册华为账号并开通华为云](https://support.huaweicloud.com/usermanual-account/account_id_001.html)

## 镜像说明

| 镜像规格                                                                                                                                | 特性说明 | 备注 |
|-------------------------------------------------------------------------------------------------------------------------------------| --- | --- |
| [Harbor2.13.0-kunpeng-v1.0](https://github.com/HuaweiCloudDeveloper/harbor-image/tree/Harbor2.13.0-kunpeng-v1.0?tab=readme-ov-file) | 基于鲲鹏服务器 + Huawei Cloud EulerOS 2.0 64bit 安装部署 |  |

## 获取帮助
- 更多问题可通过 [issue](https://github.com/HuaweiCloudDeveloper/harbor-image/issues) 或 华为云云商店指定商品的服务支持 与我们取得联系
- 其他开源镜像可看 [open-source-image-repos](https://github.com/HuaweiCloudDeveloper/open-source-image-repos)

## 如何贡献
- Fork 此存储库并提交合并请求
- 基于您的开源镜像信息同步更新 README.md