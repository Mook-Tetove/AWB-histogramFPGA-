# AWB-histogramFPGA-
 This is a white balance processing program based on histogram matching and translation (maximization of histogram area);Based on Vivado;
 这是一个基于直方图匹配与平移的白平衡处理程序（直方图面积最大化）基于FPGA（Vivado）

# AWB (Auto White Balance) 图像处理系统
## 文件地址
工程文件地址：Awb_I\Haze_tb_I\Haze_tb.xpr
测试程序地址：Awb_I\Haze_tb_I\Haze_tb.srcs\sim_1\new\Haze_tb.v
其余程序地址文件夹：Awb_I\Haze_tb_I\Haze_tb.srcs\sources_1\new\others.v
## 功能简介
这是一个基于Verilog实现的自动白平衡(AWB)图像处理系统。系统主要包含以下功能模块：
1. 直方图统计模块 ( `Hist_static.v` )
   - 统计输入图像RGB各通道的灰度直方图
   - 使用RAM存储直方图数据
   - 提供直方图数据读取接口
2. 直方图移动模块 ( `Hist_move.v` , `Hist_move_r.v` )
   - 实现直方图左移和右移操作
   - 通过参数STEP控制移动步长
   - 设置最大最小阈值(MAX_TH, MIN_TH)限制移动范围
3. 直方图匹配模块 ( `Hist_match.v` )
   - 实现RGB通道间的直方图匹配
   - 以G通道为参考，调整R和B通道
4. AWB控制模块 ( `Hist_turn.v` )
   - 根据RGB通道的直方图特征选择处理模式
   - 自动切换直方图移动和匹配操作
5. 顶层控制模块 ( `Hist_move_top.v` )
   - 整合所有功能模块
   - 控制数据流和时序
## 使用说明
### 1. 系统参数配置
主要可配置参数包括：
- 图像分辨率：默认支持1920x1080
- 直方图移动步长(STEP)：默认为4
- 移动阈值：MIN_TH(4)和MAX_TH(200)
- RGB阈值：RB_TH(240)和G_TH(200)
### 2. 接口说明
输入信号：
- i_clk : 系统时钟
- i_rst : 复位信号，低电平有效
- img_r/g/b[7:0] : RGB三通道8位图像数据
- img_hs : 行同步信号
- img_vs : 场同步信号
输出信号：
- o_img_r/g/b[7:0] : 处理后的RGB图像数据
- o_img_hs : 输出行同步信号
- o_img_vs : 输出场同步信号
### 3. 仿真验证
系统提供了完整的测试平台( `Haze_tb.v` )：
- 支持从文件读取测试图像数据
- 可输出处理结果到文件
- 提供时序和功能验证
使用步骤：
1. 准备测试图像数据文件(rgb_data_hex.txt)
2. 配置输出文件路径(fpga_rgb.txt)
3. 运行仿真，观察结果
### 4. 实现细节
- 采用双端口RAM存储直方图数据
- 使用流水线处理提高效率
- 支持实时处理，无需缓存整帧图像
- 自适应调整处理策略，平衡效果和效率
### 5. 注意事项
1. 输入图像数据必须是8位RGB格式
2. 时序信号(hs/vs)需要严格按照协议要求
3. 处理结果会有1-2帧的延迟
4. 建议在使用前通过仿真验证配置参数的合理性
5. 第一帧进行图像数据统计 ， 第二帧将统计数据应用于第二帧数据上，因此，波形从第二帧开始才为有效数据波形。
6. 读取和输出的文件地址，注意修改
