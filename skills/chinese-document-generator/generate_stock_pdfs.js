const fs = require('fs');
const path = require('path');
const pdf = require('html-pdf');

// 000823 盛通股份 盘面分析报告内容
const analysisReport = `
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>000823 盛通股份 盘面分析报告</title>
    <style>
        body { font-family: "Microsoft YaHei", "SimSun", sans-serif; font-size: 13px; line-height: 1.6; margin: 30px; }
        h1 { font-size: 22px; text-align: center; color: #1a1a1a; border-bottom: 2px solid #2563eb; padding-bottom: 15px; }
        h2 { font-size: 16px; color: #2563eb; margin-top: 25px; border-left: 4px solid #2563eb; padding-left: 10px; }
        h3 { font-size: 14px; color: #374151; margin-top: 15px; }
        .info-box { background: #f3f4f6; padding: 15px; border-radius: 8px; margin: 15px 0; }
        .metric { display: inline-block; margin: 10px 20px 10px 0; }
        .metric-label { color: #6b7280; font-size: 12px; }
        .metric-value { color: #1a1a1a; font-size: 18px; font-weight: bold; }
        .positive { color: #dc2626; }
        .negative { color: #16a34a; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { border: 1px solid #e5e7eb; padding: 10px; text-align: left; }
        th { background: #f9fafb; font-weight: 600; }
        .score { display: inline-block; width: 40px; text-align: center; padding: 5px; border-radius: 4px; color: white; font-weight: bold; }
        .score-high { background: #16a34a; }
        .score-medium { background: #f59e0b; }
        .score-low { background: #dc2626; }
        .footer { text-align: center; color: #9ca3af; font-size: 11px; margin-top: 40px; border-top: 1px solid #e5e7eb; padding-top: 15px; }
    </style>
</head>
<body>
    <h1>📊 000823 盛通股份 盘面分析报告</h1>
    <p style="text-align: center; color: #6b7280;">报告日期：2026 年 3 月 13 日 | 分析模型：8 维度量化评分</p>

    <div class="info-box">
        <h3 style="margin-top: 0;">📌 股票基本信息</h3>
        <div class="metric"><div class="metric-label">股票代码</div><div class="metric-value">000823.SZ</div></div>
        <div class="metric"><div class="metric-label">股票简称</div><div class="metric-value">盛通股份</div></div>
        <div class="metric"><div class="metric-label">所属行业</div><div class="metric-value">包装印刷</div></div>
        <div class="metric"><div class="metric-label">上市交易所</div><div class="metric-value">深圳证券交易所</div></div>
    </div>

    <h2>一、8 维度量化分析</h2>
    
    <h3>1. 盈利惊喜 (Earnings Surprise) - 权重 30%</h3>
    <div class="info-box">
        <p><strong>分析要点：</strong>最近财报 EPS 是否超预期、营收增速、利润率变化</p>
        <p><strong>评估方法：</strong>对比分析师一致预期与实际披露数据</p>
        <p><strong>数据来源：</strong>公司财报、Wind 一致预期</p>
        <table>
            <tr><th>指标</th><th>最新值</th><th>预期值</th><th>惊喜度</th></tr>
            <tr><td>EPS (TTM)</td><td>待更新</td><td>待更新</td><td>待计算</td></tr>
            <tr><td>营收增速 (YoY)</td><td>待更新</td><td>-</td><td>-</td></tr>
            <tr><td>净利润增速 (YoY)</td><td>待更新</td><td>-</td><td>-</td></tr>
        </table>
        <p><strong>维度评分：</strong><span class="score score-medium">待评</span> / 100</p>
    </div>

    <h3>2. 基本面 (Fundamentals) - 权重 20%</h3>
    <div class="info-box">
        <p><strong>分析要点：</strong>PE 估值、毛利率、ROE、资产负债率</p>
        <table>
            <tr><th>指标</th><th>数值</th><th>行业平均</th><th>评估</th></tr>
            <tr><td>市盈率 (PE-TTM)</td><td>待更新</td><td>行业对比</td><td>待评估</td></tr>
            <tr><td>市净率 (PB)</td><td>待更新</td><td>-</td><td>-</td></tr>
            <tr><td>毛利率</td><td>待更新</td><td>-</td><td>-</td></tr>
            <tr><td>ROE (加权)</td><td>待更新</td><td>-</td><td>-</td></tr>
            <tr><td>资产负债率</td><td>待更新</td><td>-</td><td>-</td></tr>
        </table>
        <p><strong>维度评分：</strong><span class="score score-medium">待评</span> / 100</p>
    </div>

    <h3>3. 分析师情绪 (Analyst Sentiment) - 权重 20%</h3>
    <div class="info-box">
        <p><strong>分析要点：</strong>研报评级、目标价、覆盖券商数量</p>
        <table>
            <tr><th>指标</th><th>数值</th></tr>
            <tr><td>覆盖券商数量</td><td>待更新</td></tr>
            <tr><td>买入评级占比</td><td>待更新</td></tr>
            <tr><td>平均目标价</td><td>待更新</td></tr>
            <tr><td>目标价空间</td><td>待计算</td></tr>
        </table>
        <p><strong>维度评分：</strong><span class="score score-medium">待评</span> / 100</p>
    </div>

    <h3>4. 历史表现 (Historical) - 权重 10%</h3>
    <div class="info-box">
        <p><strong>分析要点：</strong>历史财报后股价反应、季节性规律</p>
        <p><strong>维度评分：</strong><span class="score score-medium">待评</span> / 100</p>
    </div>

    <h3>5. 市场环境 (Market Context) - 权重 10%</h3>
    <div class="info-box">
        <p><strong>分析要点：</strong>大盘趋势、VIX 指数、市场情绪</p>
        <table>
            <tr><th>指标</th><th>数值</th><th>信号</th></tr>
            <tr><td>上证指数趋势</td><td>待更新</td><td>待判断</td></tr>
            <tr><td>深证成指趋势</td><td>待更新</td><td>待判断</td></tr>
            <tr><td>市场成交量</td><td>待更新</td><td>待判断</td></tr>
        </table>
        <p><strong>维度评分：</strong><span class="score score-medium">待评</span> / 100</p>
    </div>

    <h3>6. 板块表现 (Sector) - 权重 15%</h3>
    <div class="info-box">
        <p><strong>分析要点：</strong>包装印刷板块相对强弱、板块资金流向</p>
        <p><strong>维度评分：</strong><span class="score score-medium">待评</span> / 100</p>
    </div>

    <h3>7. 动量指标 (Momentum) - 权重 15%</h3>
    <div class="info-box">
        <p><strong>分析要点：</strong>RSI、52 周位置、均线系统</p>
        <table>
            <tr><th>指标</th><th>数值</th><th>信号</th></tr>
            <tr><td>RSI(14)</td><td>待更新</td><td>&gt;70 超买 / &lt;30 超卖</td></tr>
            <tr><td>52 周位置</td><td>待计算</td><td>高位/中位/低位</td></tr>
            <tr><td>MA5/MA10/MA20</td><td>待更新</td><td>多头/空头排列</td></tr>
        </table>
        <p><strong>维度评分：</strong><span class="score score-medium">待评</span> / 100</p>
    </div>

    <h3>8. 情绪指标 (Sentiment) - 权重 10%</h3>
    <div class="info-box">
        <p><strong>分析要点：</strong>融资融券、龙虎榜、 insider 交易</p>
        <p><strong>维度评分：</strong><span class="score score-medium">待评</span> / 100</p>
    </div>

    <h2>二、综合评分</h2>
    <div class="info-box" style="background: #eff6ff;">
        <table style="width: 100%;">
            <tr><th>维度</th><th>权重</th><th>评分</th><th>加权得分</th></tr>
            <tr><td>盈利惊喜</td><td>30%</td><td>待评</td><td>待计算</td></tr>
            <tr><td>基本面</td><td>20%</td><td>待评</td><td>待计算</td></tr>
            <tr><td>分析师情绪</td><td>20%</td><td>待评</td><td>待计算</td></tr>
            <tr><td>历史表现</td><td>10%</td><td>待评</td><td>待计算</td></tr>
            <tr><td>市场环境</td><td>10%</td><td>待评</td><td>待计算</td></tr>
            <tr><td>板块表现</td><td>15%</td><td>待评</td><td>待计算</td></tr>
            <tr><td>动量指标</td><td>15%</td><td>待评</td><td>待计算</td></tr>
            <tr><td>情绪指标</td><td>10%</td><td>待评</td><td>待计算</td></tr>
            <tr style="background: #dbeafe; font-weight: bold;"><td colspan="3">综合得分</td><td>待计算 / 100</td></tr>
        </table>
    </div>

    <h2>三、风险提示</h2>
    <div class="info-box" style="background: #fef2f2;">
        <ul>
            <li>⚠️ 本报告数据需实时更新，以上为分析框架模板</li>
            <li>⚠️ 股市有风险，投资需谨慎</li>
            <li>⚠️ 本分析不构成投资建议，仅供参考</li>
        </ul>
    </div>

    <div class="footer">
        <p>生成时间：2026-03-13 | 分析模型：8 维度量化评分系统 | 数据来源：待接入实时数据</p>
    </div>
</body>
</html>
`;

// 000823 盛通股份 操作建议方案内容
const tradingPlan = `
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>000823 盛通股份 操作建议方案</title>
    <style>
        body { font-family: "Microsoft YaHei", "SimSun", sans-serif; font-size: 13px; line-height: 1.6; margin: 30px; }
        h1 { font-size: 22px; text-align: center; color: #1a1a1a; border-bottom: 2px solid #2563eb; padding-bottom: 15px; }
        h2 { font-size: 16px; color: #2563eb; margin-top: 25px; border-left: 4px solid #2563eb; padding-left: 10px; }
        h3 { font-size: 14px; color: #374151; margin-top: 15px; }
        .info-box { background: #f3f4f6; padding: 15px; border-radius: 8px; margin: 15px 0; }
        .bullish { background: #fef2f2; border-left: 4px solid #dc2626; }
        .bearish { background: #f0fdf4; border-left: 4px solid #16a34a; }
        .neutral { background: #fffbeb; border-left: 4px solid #f59e0b; }
        .action-box { background: #eff6ff; padding: 20px; border-radius: 8px; margin: 20px 0; border: 2px solid #2563eb; }
        .action-title { font-size: 16px; font-weight: bold; color: #2563eb; margin-bottom: 10px; }
        .price-level { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #e5e7eb; }
        .price-label { color: #6b7280; }
        .price-value { font-weight: bold; color: #1a1a1a; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { border: 1px solid #e5e7eb; padding: 10px; text-align: left; }
        th { background: #f9fafb; font-weight: 600; }
        .recommendation { font-size: 18px; font-weight: bold; text-align: center; padding: 15px; border-radius: 8px; margin: 20px 0; }
        .rec-buy { background: #dc2626; color: white; }
        .rec-hold { background: #f59e0b; color: white; }
        .rec-sell { background: #16a34a; color: white; }
        .footer { text-align: center; color: #9ca3af; font-size: 11px; margin-top: 40px; border-top: 1px solid #e5e7eb; padding-top: 15px; }
        .scenario { padding: 15px; margin: 10px 0; border-radius: 6px; }
        .scenario-bull { background: #fef2f2; }
        .scenario-base { background: #f3f4f6; }
        .scenario-bear { background: #f0fdf4; }
    </style>
</head>
<body>
    <h1>📋 000823 盛通股份 操作建议方案</h1>
    <p style="text-align: center; color: #6b7280;">制定日期：2026 年 3 月 13 日 | 基于 8 维度分析模型</p>

    <div class="action-box">
        <div class="action-title">🎯 核心建议</div>
        <div class="recommendation rec-hold">
            ⏸️ 持有观望 (待综合评分确认后调整)
        </div>
        <p style="text-align: center; color: #6b7280; font-size: 12px;">
            当前建议基于分析框架模板，实际评分需接入实时数据后确定
        </p>
    </div>

    <h2>一、关键价格位</h2>
    <div class="info-box">
        <div class="price-level">
            <span class="price-label">📈 阻力位 3 (强阻力)</span>
            <span class="price-value">待确定 (前高/整数关口)</span>
        </div>
        <div class="price-level">
            <span class="price-label">📈 阻力位 2</span>
            <span class="price-value">待确定 (MA60/前期平台)</span>
        </div>
        <div class="price-level">
            <span class="price-label">📈 阻力位 1</span>
            <span class="price-value">待确定 (MA20/短期压力)</span>
        </div>
        <div class="price-level" style="background: #f9fafb; font-weight: bold;">
            <span class="price-label">💹 当前价</span>
            <span class="price-value">待更新</span>
        </div>
        <div class="price-level">
            <span class="price-label">📉 支撑位 1</span>
            <span class="price-value">待确定 (MA5/MA10)</span>
        </div>
        <div class="price-level">
            <span class="price-label">📉 支撑位 2</span>
            <span class="price-value">待确定 (前期低点)</span>
        </div>
        <div class="price-level">
            <span class="price-label">📉 支撑位 3 (强支撑)</span>
            <span class="price-value">待确定 (年线/重要平台)</span>
        </div>
    </div>

    <h2>二、情景分析与应对策略</h2>

    <h3>🐂 情景 A： bullish 突破上行</h3>
    <div class="scenario scenario-bull">
        <p><strong>触发条件：</strong>放量突破阻力位 1，RSI 进入 50-70 区间，成交量放大 50% 以上</p>
        <p><strong>操作建议：</strong></p>
        <ul>
            <li>仓位：加仓至 70-80%</li>
            <li>入场点：突破确认后回踩不破</li>
            <li>目标价：阻力位 2 → 阻力位 3</li>
            <li>止损：跌破突破 K 线低点</li>
        </ul>
    </div>

    <h3>😐 情景 B：中性 震荡整理</h3>
    <div class="scenario scenario-base">
        <p><strong>触发条件：</strong>在支撑位 1 与阻力位 1 之间震荡，成交量萎缩</p>
        <p><strong>操作建议：</strong></p>
        <ul>
            <li>仓位：维持 50% 中性仓位</li>
            <li>策略：高抛低吸，区间操作</li>
            <li>入场点：靠近支撑位分批买入</li>
            <li>出场点：靠近阻力位分批卖出</li>
            <li>止损：跌破支撑位 2 减仓</li>
        </ul>
    </div>

    <h3>🐻 情景 C：bearish 破位下行</h3>
    <div class="scenario scenario-bear">
        <p><strong>触发条件：</strong>跌破支撑位 2，RSI 进入 30 以下超卖区，放量下跌</p>
        <p><strong>操作建议：</strong></p>
        <ul>
            <li>仓位：减仓至 20-30% 或清仓</li>
            <li>止损：跌破支撑位 2 立即执行</li>
            <li>观察：等待支撑位 3 企稳信号</li>
            <li>回补：出现底部反转形态后考虑</li>
        </ul>
    </div>

    <h2>三、仓位管理建议</h2>
    <div class="info-box">
        <table>
            <tr><th>风险偏好</th><th>建议仓位</th><th>止损幅度</th><th>适用情景</th></tr>
            <tr><td>保守型</td><td>20-30%</td><td>5-8%</td><td>震荡/不确定</td></tr>
            <tr><td>稳健型</td><td>40-60%</td><td>8-12%</td><td>中性偏多</td></tr>
            <tr><td>激进型</td><td>70-90%</td><td>12-15%</td><td>明确突破信号</td></tr>
        </table>
    </div>

    <h2>四、风险控制</h2>
    <div class="info-box bearish">
        <h3>⛔ 止损策略</h3>
        <ul>
            <li><strong>硬止损：</strong>亏损达到止损位无条件卖出</li>
            <li><strong>时间止损：</strong>持仓 5 个交易日无进展考虑退出</li>
            <li><strong>事件止损：</strong>突发利空消息立即评估</li>
        </ul>
        
        <h3>⚠️ 风险警示</h3>
        <ul>
            <li>大盘系统性风险（关注上证指数走势）</li>
            <li>行业政策风险（包装印刷行业政策变化）</li>
            <li>公司基本面风险（财报不及预期）</li>
            <li>流动性风险（成交量过低）</li>
        </ul>
    </div>

    <h2>五、监控指标清单</h2>
    <div class="info-box">
        <table>
            <tr><th>指标类型</th><th>具体指标</th><th>预警阈值</th><th>检查频率</th></tr>
            <tr><td>价格</td><td>收盘价 vs 支撑/阻力</td><td>突破/跌破</td><td>每日</td></tr>
            <tr><td>成交量</td><td>日成交量</td><td>放大/萎缩 50%</td><td>每日</td></tr>
            <tr><td>动量</td><td>RSI(14)</td><td>&gt;70 / &lt;30</td><td>每日</td></tr>
            <tr><td>资金</td><td>主力净流入</td><td>连续 3 日流入/流出</td><td>每日</td></tr>
            <tr><td>消息</td><td>公司公告/行业新闻</td><td>重大利好/利空</td><td>实时</td></tr>
        </table>
    </div>

    <h2>六、执行计划</h2>
    <div class="action-box">
        <h3>📅 短期 (1-5 个交易日)</h3>
        <ul>
            <li>监控当前价位在支撑/阻力间的表现</li>
            <li>等待 8 维度分析综合评分确认</li>
            <li>根据情景 A/B/C 准备相应操作</li>
        </ul>
        
        <h3>📅 中期 (1-4 周)</h3>
        <ul>
            <li>跟踪财报披露时间（如有）</li>
            <li>关注行业板块整体表现</li>
            <li>根据趋势调整仓位</li>
        </ul>
        
        <h3>📅 长期 (1-3 个月)</h3>
        <ul>
            <li>评估公司基本面变化</li>
            <li>重新进行 8 维度分析</li>
            <li>决定是否继续持有</li>
        </ul>
    </div>

    <div class="info-box" style="background: #fef2f2; border: 2px solid #dc2626;">
        <h3>⚠️ 重要免责声明</h3>
        <ul>
            <li>本方案基于分析框架模板生成，实际数据需实时更新</li>
            <li>股市有风险，投资需谨慎</li>
            <li>本方案不构成投资建议，仅供参考学习</li>
            <li>请结合个人风险承受能力和实际情况决策</li>
            <li>建议咨询持牌投资顾问获取专业意见</li>
        </ul>
    </div>

    <div class="footer">
        <p>生成时间：2026-03-13 | 分析模型：8 维度量化评分系统 | 操作建议仅供参考</p>
    </div>
</body>
</html>
`;

async function generatePDF(htmlContent, outputPath, title) {
    const options = {
        format: 'A4',
        orientation: 'portrait',
        border: {
            top: '1cm',
            right: '1cm',
            bottom: '1cm',
            left: '1cm'
        }
    };
    
    return new Promise((resolve, reject) => {
        pdf.create(htmlContent, options).toFile(outputPath, (err, res) => {
            if (err) {
                reject(err);
            } else {
                console.log(`✅ PDF 生成成功：${outputPath}`);
                resolve({ success: true, outputPath });
            }
        });
    });
}

async function main() {
    try {
        console.log('🚀 开始生成 000823 盛通股份分析 PDF...');
        
        await generatePDF(
            analysisReport,
            '/home/admin/.openclaw/workspace/000823_盛通股份_盘面分析报告.pdf',
            '盘面分析报告'
        );
        
        await generatePDF(
            tradingPlan,
            '/home/admin/.openclaw/workspace/000823_盛通股份_操作建议方案.pdf',
            '操作建议方案'
        );
        
        console.log('\n✨ 所有 PDF 文件生成完成！');
        console.log('📁 文件位置：');
        console.log('   - /home/admin/.openclaw/workspace/000823_盛通股份_盘面分析报告.pdf');
        console.log('   - /home/admin/.openclaw/workspace/000823_盛通股份_操作建议方案.pdf');
        
    } catch (error) {
        console.error('❌ PDF 生成失败:', error);
        process.exit(1);
    }
}

main();
