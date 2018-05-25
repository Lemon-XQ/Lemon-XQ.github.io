---
title: 图像边缘检测及提取方法总结（含Matlab代码）
date: 2018-03-24 20:40:21
categories:
- 图像处理
tags:
- Matlab
- 机器学习
---
## 写在前面
　　呼~最近开始入坑图像+机器学习了，学习的过程中遇到了不少不懂的东西，好在自学能力还可以（自恋中= =），所以断断续续也算学会了一些东西~因为这段时间一直在做边缘检测和提取的工作，所以本篇就总结一下一些常见的边缘检测方法，篇幅较长，可按点查看~
<!--more-->
## 名词解释
　　图像处理中经常用到一些名词，以下列举一些：
### 1. 滤波
　　所谓滤波就是对每个像素点及其邻域点的灰度值按照一定的参数规则进行加权平均，这样可以有效滤去理想图像中叠加的高频噪声。常用的滤波有线性滤波、中值滤波、均值滤波、双边滤波、高斯滤波等。滤波有抑制噪声的作用，但这会使得图像边缘模糊。
### 2. 直方图
　　在图像处理中，经常用到直方图，如颜色直方图、灰度直方图等。直方图可以直观展现数据分布情况，如灰度直方图中，横坐标为各个灰度范围，纵坐标为处在相应范围的像素数。图像直方图不关心像素所处的空间位置，因此不受图像旋转和平移变化的影响，可以作为图像的特征。
### 3. 上采样
 　　上采样即放大图像（或称图像插值（interpolating））,从而使图像可以显示在更高分辨率的显示设备上。注意对图像的缩放操作通常会影响图像的质量。上采样几乎都是采用**内插值**方法，即在原有图像像素的基础上在像素点之间采用合适的插值算法插入新的元素。    
### 4. 下采样
　　下采样即缩小图像（或称为降采样（downsampled）），其主要目的有两个：1、使得图像符合显示区域的大小；2、生成对应图像的缩略图。

　　**下采样原理**：对于一幅图像I尺寸为M\*N，对其进行s倍下采样，即得到(M/s)\*(N/s)尺寸的分辨率图像，当然s应该是M和N的公约数才行，如果考虑的是矩阵形式的图像，就是把原始图像s\*s窗口内的图像变成一个像素，这个像素点的值就是窗口内所有像素的均值
## Canny算子
### 1.原理
　　canny算子与LoG算子类似，属于先平滑后求导数的方法，原理可分成下面4个部分：
#### 1.1 高斯滤波
　　在所有滤波方法中，需要考虑的最重要的一点是如何平衡去噪与边缘检测精确之间的矛盾。实际工程经验表明，高斯函数确定的核可以提供较好的折衷方案。

　　高斯滤波实现方法有两种：**离散化窗口滑动卷积、傅里叶变换**。因前者比较常用，故下面只介绍前者。

　　离散化窗口滑动卷积主要利用高斯核实现，即一个奇数大小的高斯模板。常用的高斯核模板有3\*3 和 5\*5两种
　　
![](http://img.blog.csdn.net/20170104082145549)

其中的参数通过高斯函数计算，x^2+y^2表示像素点和中心像素点的距离，sigma表示标准差。

![](http://img.blog.csdn.net/20170104083209100)

- **注：**
	- sigma如果选的过大，会加深滤波程度，从而导致图像边缘模糊，不利于下一步的边缘检测，如果过小，则滤波效果不佳
	- 计算高斯模板参数时，需要归一化处理，对于归一化的原因，有一种解释是：归一化之后，通过卷积计算出来的模板中心像素被限制到了0-255的灰度区间中。假若某一邻域内所有像素的灰度值为255，利用该模板进行卷积之后，求得的模板中心像素灰度值仍然为255；假若计算出来的高斯模板参数之和小于1，那么通过该模板进行卷积之后，模板中心像素的灰度值将小于255，偏离了实际的灰度值，产生了误差。

#### 1.2 求梯度幅值和梯度方向
　　canny算子使用的卷积算子如下：

![](http://hi.csdn.net/attachment/201110/20/0_13191191580BUw.gif)

　　梯度幅值及梯度方向的计算如下，其中P表示x方向一阶偏导数矩阵，Q表示y方向一阶偏导数矩阵，M表示梯度幅值，θ表示梯度方向

![](http://hi.csdn.net/attachment/201110/20/0_131911920906FX.gif)
#### 1.3 非极大值抑制
　　在上面求出的梯度幅值矩阵中，值越大的元素代表其梯度越大，但它不一定是边缘像素，因此需要进行非极大值抑制，也就是寻找像素点局部最大值，将非极大值点所对应的灰度值置为0，这样可以剔除掉一大部分非边缘的点。
　　![](http://hi.csdn.net/attachment/201110/20/0_1319119291xBLz.gif)

　　如上图，判定C点是否为8邻域内最大梯度值点，只需要判断C是否比C的梯度方向上dTmp1和dTmp2点大，是则保留，不是则将C点灰度值置0。而dTmp1和dTmp2的梯度值可以通过插值得到。

#### 1.4 双阈值法闭合边缘
　　上面得到的边缘有些为假边缘，且有边缘断裂的问题，如果根据高阈值得到一个边缘图像，这样一个图像含有很少的假边缘，但是由于阈值较高，产生的图像边缘可能不闭合，因此还要采用一个低阈值，当到达轮廓的端点时，在断点的8邻域点中寻找满足低阈值的点，再根据此点收集新的边缘，直到整个图像边缘闭合。
### 2.实现
#### 2.1 原始图像灰度化
{% codeblock lang:matlab %}
img = imread('lena.jpg');
img = rgb2gray(img);
{% endcodeblock %}
#### 2.2 调用matlab内置函数
{% codeblock lang:matlab %}
img_edge = edge(img,'canny');
figure;imshow(img_edge);title('canny');
{% endcodeblock %}
## Roberts、Sobel、Prewitt算子
图像的灰度值梯度可以用一阶偏导的有限差分近似计算，常用梯度算子有：
### Roberts算子
![](http://hi.csdn.net/attachment/201110/20/0_1319118788tu9f.gif)

梯度幅值为：
![](http://hi.csdn.net/attachment/201110/20/0_1319118857NQ6k.gif)

**matlab中可直接调用**：`edge(img,'roberts')`
### Sobel算子
![](http://hi.csdn.net/attachment/201110/20/0_1319118933e59W.gif)

梯度幅值为：
![](http://hi.csdn.net/attachment/201110/20/0_1319119015UX8D.gif)

**matlab中可直接调用**：`edge(img,'sobel')`
### Prewitt算子
![](http://hi.csdn.net/attachment/201110/20/0_1319119083ivVZ.gif)

**matlab中可直接调用**：`edge(img,'prewitt')`

## 双边滤波（Bilateral Filters）
### 1. 原理
　　传统滤波方法多多少少会有模糊边缘的缺点，而双边滤波作为一种非线性滤波器，具有在降噪平滑的同时，保持边缘的效果。该特性主要是通过在卷积的过程中组合空域(space)函数和值域(range)核函数来实现的，空域指的是像素的欧氏距离，值域指的是像素范围域中的辐射差异（如卷积核中像素与中心像素之间相似程度、颜色强度，深度距离等）。典型的核函数为高斯分布函数，如下所示：
![](http://my.csdn.net/uploads/201205/30/1338365238_1668.jpg)

其中，权重系数w(i,j,k,l)取决于空域核和值域核的乘积：
![](http://my.csdn.net/uploads/201205/30/1338365512_2777.jpg)

在图像的平坦区域，像素值变化很小，对应的像素值域权重接近于1，此时空域权重起主要作用，相当于进行高斯模糊；在图像的边缘区域，像素值变化很大，像素值域权重变大，从而保持了边缘的信息。

### 2. 实现
　　上述方法的时间复杂度是O(σd^2)，非常耗时。论文《Fast O(1) bilateral ﬁltering using trigonometric range kernels》，提出了用Raised cosines函数来逼近高斯值域函数，并利用一些特性把值域函数分解为一些列函数的叠加，从而实现函数的加速，而论文" A fast approximation of the bilateral filter using a signal processing approach"则提出了一种使用信号处理的方法，主要是在原有域上添加了信号强度这一维，构成了高维空间，在高维空间中进行下采样，下面的代码是作者团队编写的：
{% codeblock lang:matlab %}
% 双边滤波函数
function output = fBilateralFilter_ReviseVer( data, edge, edgeMin, edgeMax, sigmaSpatial, sigmaRange,samplingSpatial, samplingRange )
if ~exist( 'edge', 'var' )
	edge = data;
elseif isempty( edge )
	edge = data;
end

inputHeight = size( data, 1 );
inputWidth = size( data, 2 );

if ~exist( 'edgeMin', 'var' )
	edgeMin = min( edge( : ) );
% 	warning( 'edgeMin not set!  Defaulting to: %f\n', edgeMin );
end

if ~exist( 'edgeMax', 'var' )
	edgeMax = max( edge( : ) );
% 	warning( 'edgeMax not set!  Defaulting to: %f\n', edgeMax );
end

edgeDelta = edgeMax - edgeMin;% hl- span of range

% hl- assign scale parameters in both spatial and range domain
if ~exist( 'sigmaSpatial', 'var' )
	sigmaSpatial = min( inputWidth, inputHeight ) / 16;
	fprintf( 'Using default sigmaSpatial of: %f\n', sigmaSpatial );
end
if ~exist( 'sigmaRange', 'var' )
	sigmaRange = 0.1 * edgeDelta;
	fprintf( 'Using default sigmaRange of: %f\n', sigmaRange );
end

if ~exist( 'samplingSpatial', 'var' )
	samplingSpatial = sigmaSpatial;
end

if ~exist( 'samplingRange', 'var' )
	samplingRange = sigmaRange;
end

if size( data ) ~= size( edge )
	error( 'data and edge must be of the same size' );
end

% parameters
derivedSigmaSpatial = sigmaSpatial / samplingSpatial; 
derivedSigmaRange = sigmaRange / samplingRange;
paddingXY = floor( 2 * derivedSigmaSpatial ) + 1;
paddingZ = floor( 2 * derivedSigmaRange ) + 1;

% allocate 3D grid
downsampledWidth = floor( ( inputWidth - 1 ) / samplingSpatial ) + 1 + 2 * paddingXY; % paddingXY - 控制延拓范围
downsampledHeight = floor( ( inputHeight - 1 ) / samplingSpatial ) + 1 + 2 * paddingXY;
downsampledDepth = floor( edgeDelta / samplingRange ) + 1 + 2 * paddingZ;

gridData = zeros( downsampledHeight, downsampledWidth, downsampledDepth );
gridWeights = zeros( downsampledHeight, downsampledWidth, downsampledDepth );

% compute downsampled indices
[ jj, ii ] = meshgrid( 0 : inputWidth - 1, 0 : inputHeight - 1 ); % hl- create the coordinats of xy-plane; jj - y coordinates of all pixels, ii - x coordinates of all pixels

%Compute the downsampled coordinates
di = round( ii / samplingSpatial ) + paddingXY + 1; % round: Round to nearest integer四舍五入
dj = round( jj / samplingSpatial ) + paddingXY + 1;
dz = round( ( edge - edgeMin ) / samplingRange ) + paddingZ + 1;

% hl - average sampling (box sampling)
for k = 1 : numel( dz ) % numel: Number of elements in an array
	dataZ = data( k ); % traverses the image column wise, same as di( k )
	if ~isnan(dataZ),
        dik = di( k ); %取出坐标
        djk = dj( k );
        dzk = dz( k );
        gridData( dik, djk, dzk ) = gridData( dik, djk, dzk ) + dataZ;
        gridWeights( dik, djk, dzk ) = gridWeights( dik, djk, dzk ) + 1;
	end
end

% make gaussian kernel
kernelWidth = 2 * derivedSigmaSpatial + 1;
kernelHeight = kernelWidth;
kernelDepth = 2 * derivedSigmaRange + 1;

halfKernelWidth = floor( kernelWidth / 2 );
halfKernelHeight = floor( kernelHeight / 2 );
halfKernelDepth = floor( kernelDepth / 2 );

[gridX, gridY, gridZ] = meshgrid( 0 : kernelWidth - 1, 0 : kernelHeight - 1, 0 : kernelDepth - 1 );
gridX = gridX - halfKernelWidth;
gridY = gridY - halfKernelHeight;
gridZ = gridZ - halfKernelDepth;
gridRSquared = ( gridX .* gridX + gridY .* gridY ) / ( derivedSigmaSpatial * derivedSigmaSpatial ) + ( gridZ .* gridZ ) / ( derivedSigmaRange * derivedSigmaRange );
kernel = exp( -0.5 * gridRSquared );

% convolve
blurredGridData = convn( gridData, kernel, 'same' );
blurredGridWeights = convn( gridWeights, kernel, 'same' );

% divide
blurredGridWeights( blurredGridWeights == 0 ) = -2; % avoid divide by 0, won't read there anyway  
normalizedBlurredGrid = blurredGridData ./ blurredGridWeights;
normalizedBlurredGrid( blurredGridWeights < -1 ) = 0; % put 0s where it's undefined

% upsample
[ jj, ii ] = meshgrid( 0 : inputWidth - 1, 0 : inputHeight - 1 ); % meshgrid does x, then y, so output arguments need to be reversed
% no rounding
di = ( ii / samplingSpatial ) + paddingXY + 1;
dj = ( jj / samplingSpatial ) + paddingXY + 1;
dz = ( edge - edgeMin ) / samplingRange + paddingZ + 1;

output = interpn( normalizedBlurredGrid, di, dj, dz ); % N-D data interpolation
end
{% endcodeblock %}

## Hessian特征
### 1. 原理
　　Hessian矩阵本质是是一个多元函数的二阶偏导数矩阵，描述了函数的局部曲率。关于Hessian矩阵的由来及详细推导证明见参考资料3，这里直接介绍如何得到Hessian矩阵：

- 高斯函数

![](https://images0.cnblogs.com/blog/340413/201304/11220012-dfd2500ffeab46deb94c565cbd543cd7.png)

- 求二阶偏导

![](https://images0.cnblogs.com/blog/340413/201304/11220100-aacb4d9efd5847aea09c0010d246aaa9.png)
- 对原图进行卷积

![](https://images0.cnblogs.com/blog/340413/201304/11215427-715349a8c1aa4a138daa0a8333ae86a8.png)
- 构成Hessian矩阵

![](https://images0.cnblogs.com/blog/340413/201304/11215631-d4862108572245a783a3225e84036ad0.png)
### 2. 实现
{% codeblock lang:matlab %}
% 提取Hessian特征值
function [hessianValue,Ixx,Ixy,Iyy] = edge_hessian(img)
    [m n]=size(img);
    w=4;
    sigma=1.2;
    [x y]=meshgrid(-w:w,-w:w);
    % 高斯函数对应的二阶偏导  
    Dxx = 1/(-2*pi*sigma^4)*(1-x.^2/sigma^2)*exp(-(x.^2+x.^2)/(2*sigma^2)); 
    Dyy = 1/(-2*pi*sigma^4)*(1-y.^2/sigma^2)*exp(-(x.^2+y.^2)/(2*sigma^2));
    Dxy = 1/(2*pi*sigma^6)*(x.*y)*exp(-(x.^2+y.^2)/(2*sigma^2));

    Ixx=imfilter(img,Dxx,'replicate');
    Iyy=imfilter(img,Dyy,'replicate');
    Ixy=imfilter(img,Dxy,'replicate');

    hessianValue=[];
    for i=1:m
       for j=1:n 
        hessianValue(i,j) = Ixx(i,j)*Iyy(i,j) - Ixy(i,j)*Ixy(i,j);
       end
    end
end
{% endcodeblock %}
## Haar特征
### 1. 原理
　　Haar特征是一种反映图像的灰度变化的，像素分模块求差值的一种特征。常用于人脸识别中五官划分，例如：脸部的一些特征能由矩形模块差值特征简单的描述，如：眼睛要比脸颊颜色要深，鼻梁两侧比鼻梁颜色要深，嘴巴比周围颜色要深等。但矩形特征只对一些简单的图形结构，如边缘、线段较敏感，所以只能描述在特定方向（水平、垂直、对角）上有明显像素模块梯度变化的图像结构。

　　它分为三类：**边缘特征、线性特征、中心特征和对角线特征**。
![](http://img.blog.csdn.net/20160816201200204)

　　**模板特征值计算**： 黑色矩形像素和 - 白色矩形像素和

- **注**：一般通过**积分图**计算Haar特征，这样只需求一次积分图，就可以求出多种Haar特征，节省计算时间
- **积分图**：主要思想是将图像从起点开始到各个点所形成的矩形区域像素之和作为一个数组的元素保存在内存中，当要计算某个区域的像素和时可以直接索引数组的元素，不用重新计算这个区域的像素和。示例如下：
![](http://my.csdn.net/uploads/201206/04/1338798979_5003.JPG)

上图中，D块的像素和=II(4)+II(1)-II(2)-II(3) II表示积分图

### 2. 实现
这里我只实现了Haar特征的一种，其他的同理
{% codeblock lang:matlab %}
% 提取Haar特征（中心为黑四周为白），思路如下：
% white+black = II(i+1,j+1)+II(i-2,j-1)-II(i-2,j+1)-II(i+1,j-2)
% black = img(i,j)
% harr = white-black = white+black-2*black
function [haar,hg,hgx,hgy] = edge_haar_center(img)
    close all;
    II = integralImage(img);% 求积分图
    II = II(2:end,2:end);
    height = size(II,1);
    width = size(II,2);

    total = II(4:height-1,4:width-1)+II(1:height-4,1:width-4)-II(1:height-4,4:width-1)-II(4:height-1,1:width-4);
    black = img(3:height-2,3:width-2);
    haar = (total - 2*black);
    [hgx,hgy] = gradient(haar);
    hg = sqrt(hgx.^2+hgy.^2);
end
{% endcodeblock %}
## 参考资料
1. [Canny边缘检测算法原理及其VC实现详解](https://blog.csdn.net/likezhaobin/article/details/6892176)
2. [Bilateral Filters（双边滤波算法）原理及实现](https://blog.csdn.net/piaoxuezhong/article/details/78302920)
3. [Hessian矩阵以及在图像中的应用](https://blog.csdn.net/lwzkiller/article/details/55050275)
4. [机器学习之Haar特征](https://blog.csdn.net/lanxuecc/article/details/52222369)