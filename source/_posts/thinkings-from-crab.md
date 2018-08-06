---
title: 由一只大闸蟹想到的基于tesseract-ocr的验证码识别
date: 2016-10-01 15:49:42
tags:
- java
- tesseract
- 机器学习
category:
- java
---

> 本来今年没打算吃大闸蟹，也就没买，说实话也不是特别好这口，剥起来还麻烦。碰巧朋友公司发了券，可以兑换八只，她有两张，也吃不完，遂要来一张。万万没想到，我几年最后还是吃上了大闸蟹。进入正题，朋友公司发的是礼品卡，兑换券，有一个卡号，和一个密码，到指定的网站上用这卡号和密码登录之后即可兑换，用快递发货。流程就是如此。拍照发我之后，卡号只有5位，密码是6位，我顿感兴奋，这可能性不多啊，密码只有6位，0-9的数字组合，总共10的6次方，也就是100万种可能性，直接写程序去请求的话，理论上完全可以破解，那就免费吃螃蟹啦！当然，我只是出于技术的兴奋点，利用漏洞去吃螃蟹，不合法，也不道德。（让我想起阿里月饼）由此，因为一只螃蟹，开始两天的技术之旅。

<!-- more -->

# 思路

目标兑换网站是使用ASP的站点，在查看源码的过程中，发现应该是那种外包公司，或者是淘宝建站，源码里面还有广告，`xx建站`，说明这个公司完全没有自己的技术运维人员。

从代码层面，就是简单的ASP页面。核心就是一个登入窗口，可以输入卡号，密码登录。然后有一个验证码，验证码为0-9的4个数字组成，关键就是这个验证码了。登录请求可以代码直接模拟，对某一个卡号重试100万次，应该不用100万次那么多，密码的构成应该不是完全随机，不过也都是一个重试的过程。只要目标站不挂掉 - -。后来测试虽然没挂，不过也是拒绝服务了，这是后话了。

再看验证码，chrome `f12` 直接抓请求，发现这个验证码的生成居然是一个`asp`页面，因为没写过asp，所以还是第一次见这种做法。查看了下，服务端是根据一个生成算法，生成一个`bmp`位图数据，放在asp页面中返回。请求头直接就是`image/webp,image/*,*/*;q=0.8`，显示最后就是一张bmp图片。

![验证码](/images/由一只大闸蟹想到的基于tesseract-ocr的验证码识别/1.bmp)

验证码中加入了一些噪点，而且每个数字的形状还有区别，像上面图中，两个8就不太一样，这让后面的识别也是难度大了很多。

# 验证码识别

一开始我想的比较简单，觉得肯定会有开源的库开源简单搞定这个问题，后面开始去写代码的时候，发现确实不是那么容易。

## 获取验证码样本库

做识别，肯定要先拿一些验证码样本库，不管是分析规律，还是测试识别成功率，肯定都是需要的。

这个站点的验证码虽然是一个asp页面，但分析下不难得出，其实也就是把`bmp`的二进制数据写在了`asp`页面中，最后以bmp格式显示。这和你在电脑上把一个asp的文件改成bmp格式，然后查看，其实是一回事。

这样就比较简单了，直接get请求拿到这个验证码，写到本地的bmp格式文件中，齐活！

```
    public void spiderAllCodeImage() {
        for (int i=0; i<10000; i++) {
            CloseableHttpClient client = HttpClients.createDefault();

            //构造HTTP请求，使用java的httpclients
            HttpGet request = new HttpGet(DZX_URL_CODE);
//            request.setHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8");
            CloseableHttpResponse response = null;
            try {
                response = client.execute(request);
            } catch (IOException e) {
                e.printStackTrace();
                return;
            }

        try {
            byte[] imageByte = new byte[1024];
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            //从response中获取二进制数据
            response.getEntity().writeTo(baos);
            imageByte = baos.toByteArray();
            //这段可以无视，本想做个缓存比较，后来发现不是很好用，动态代码生成的验证码都是不同的，只有在大量样本下，会出现重复
            String md5 = DigestUtils.md5DigestAsHex(imageByte);
            if (codeMd5Map.containsKey(md5)) {
                System.out.println(new String(imageByte, "utf-8"));
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                continue;
            } else {
                codeMd5Map.put(md5, new String(imageByte, "utf-8"));
            }
            //写到本地
            File file = new File("D:/codeimage/code" + i + ".bmp");
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(imageByte);
        } catch (IOException e) {
            e.printStackTrace();
        }
        }
    }

```
我上面获取了10000张，不过中间目标服务器会出现`unable service`拒绝服务现象，获取不到那么多样本，不过也已经够用了

## 识别引擎

对于验证码的识别，我可以说是完全从0开始。一切都从`google`开始。这也是技术人员最重要的东西了，就是能学，能快速上手。东西是永远学不完的，技术也是在不断更替的，不可能学完所有的技术，但是等到用的时候，只要知道学习的方法，自己花点时间研究上手就行了。

重在内功心法，招式啥的，会点一招鲜走遍天的就好。

说多了。

先搜，如何识别验证码，看了几篇文章，都提到了一个开源项目，`Tesseract-OCR`，有了方向，就容易一些了。直接开始去搜这个开源项目，看看怎么使用。我也就选择这个主流的识别引擎了。毕竟讨论的人多，生态就会比较丰富，问题也比较容易得到解决。

Tesseract-OCR，简单介绍下， `Tesseract是一个开源的OCR（Optical Character Recognition，光学字符识别）引擎，可以识别多种格式的图像文件并将其转换成文本，目前已支持60多种语言（包括中文）。 Tesseract最初由HP公司开发，后来由Google维护。`。

github地址：
> https://github.com/tesseract-ocr/tesseract

## 引擎安装

### windows安装版

我使用的是windows，我在这只讲windows的，其他方式自己搜索下，不再赘述

tesseract这个识别引擎，在windows下如果想直接使用的话，可以选择安装版，也就是`installer`的方式，像我们平常使用的软件一样

寻找下载链接的过程比较曲折，因为有墙，好多地址都下不下来，我自己又有官网洁癖，喜欢一定要在官网下的东西，反正最终曲折的下载好

tesseract更新速度较慢，如果你追求速度，直接使用我下面给的下载链接，最快。

> http://download.csdn.net/detail/yzw19932010/9644501

安装好以后，找到安装目录下的`tesseract.exe`，在**当前目录下**cmd命令模式下执行，

`tesseract.exe doc\eurotext.tif doc\result`

这条命令，使用识别引擎，识别`doc\eurotext.tif`这个文件，结果写到`doc\result`

或者

`tesseract.exe doc\eurotext.tif doc\result digits`

加上`digits`参数，表示只识别数字

还可以指定识别模式，`-psm`是识别模式，`-l`指定识别语言
```
pagesegmode values are:
0 = Orientation and script detection (OSD) only.
1 = Automatic page segmentation with OSD.
2 = Automatic page segmentation, but no OSD, or OCR
3 = Fully automatic page segmentation, but no OSD. (Default)
4 = Assume a single column of text of variable sizes.
5 = Assume a single uniform block of vertically aligned text.
6 = Assume a single uniform block of text.
7 = Treat the image as a single text line.
8 = Treat the image as a single word.
9 = Treat the image as a single word in a circle.
10 = Treat the image as a single character.
-l lang and/or -psm pagesegmode must occur before anyconfigfile.

```
`D:\Tesseract\Tesseract-OCR>tesseract.exe doc\newimage.bmp doc\result -l eng -psm 7`

### 代码支持

上面这种模式当然还不够好，只有命令行，虽然说代码中也能调用，但是不够优雅。

tesseract 原生好像只提供3个DLL给C或者C++调用，其他语言没有提供API支持

不过，tesseract有很多`wrapper`，就是前人给我们包装好的，给各种语言使用的一个适配包

原文地址：
> https://github.com/tesseract-ocr/tesseract/wiki/AddOns#tesseract-wrappers

可以到这里找你想使用的语言的`wrapper`

我使用的是java，我这里就说java的了

最方便的是直接使用`maven`获取
```
        <dependency>
            <groupId>net.sourceforge.tess4j</groupId>
            <artifactId>tess4j</artifactId>
            <version>3.2.1</version>
        </dependency>
```
不过这种方式，不包含需要使用到的`testdata`（引擎自带的一些识别需要的训练数据），运行会报错

所以前面那个windows版本还是要下的，里面包含了所有的`testdata`

推荐方式：直接到 tesseract 把其源码拉下来，在test包下面有很多例子，都是可以直接运行的，这样方式最快，最方便，testdata也有，直接引用这个源码也都可以


# 图片处理

引擎有了，API调用很简单，核心代码就两句

```
    @Test
    public void testDoOCR_File() throws Exception {
        logger.info("doOCR on a PNG image");
        //获取待识别图片的File对象
        File imageFile = new File(this.testResourcesDataPath, "eurotext.png");
        String expResult = "The (quick) [brown] {fox} jumps!\nOver the $43,456.78 <lazy> #90 dog";
        //获取Tesseract实例
        ITesseract instance = instance = new Tesseract();
        //设置testdata数据路径
        instance.setDatapath(new File(datapath).getPath());
        //识别，返回String的结果
        String result = instance.doOCR(imageFile);
        logger.info(result);
        assertEquals(expResult, result.substring(0, expResult.length()));
    }
```

但是对于我们上面的验证码，发现识别根本不正确，没法得到正确的结果

> 特别是，代码识别，和cmd命令识别，结果还不一样，暂时没找到问题所在

这时候，就需要图片处理了

原图里面加入了太多的噪点，而且数字进行了扭曲，导致识别率极低，几乎是不可用

网上很多方案采取的大都是，先切割，把每一个数字单独切割出来，然后去噪，进行二值化，灰度处理（因为处理引擎对于灰度图片识别较好）

但是我要处理的这个验证码，每一个数字都不是完全的相同，有扭曲程度，如果进行切割，最后拿二进制数据进行比较，这个相似度的阈值很难确定，所以我还是倾向于识别引擎可以去帮我处理这些问题（不过，最后发现，我还是想太多，识别引擎没有这么智能，做不到这点）

## 去除噪点+二值化处理+灰度处理

对于这个图片的二值化处理比较简单

我用`FastStone Capture`的取色工具看了下图片里的色值，发现去除噪点之后的图片都是一种颜色

那就只要简单遍历图片的像素点，把主干的颜色全部设置成黑色就行了

```
package sample.simple.service;

import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;

/**
 * Created by ji on 2016/10/1.
 */
@Service
public class BmpService {

    public void optimisedBmp(String bmpAbsolutePath) throws Exception {
        File file = new File(bmpAbsolutePath);
        BufferedImage bufferedImage = ImageIO.read(file);
        BufferedImage newImage = removeInterference(bufferedImage);
        File newImageFile = new File("D:\\codeimage\\newImage\\newimage.bmp");
        ImageIO.write(newImage, "bmp", newImageFile);
    }

    // 去除图像噪点
    public static BufferedImage removeInterference(BufferedImage image)
            throws Exception {
        int width = image.getWidth();
        int height = image.getHeight();
        for (int x = 0; x < width; ++x) {
            for (int y = 0; y < height; ++y) {
                if (!isFontColor(image.getRGB(x, y))) {
                    image.setRGB(x, y, Color.WHITE.getRGB());
                }else {
                    image.setRGB(x, y, Color.BLACK.getRGB());
                }
            }
        }
        return image;
    }

    // 使用工具找到主色的色值，得到R + G +B =340
    private static boolean isFontColor(int colorInt) {
        Color color = new Color(colorInt);

        return color.getRed() + color.getGreen() + color.getBlue() == 340;
    }
}

```
代码写的比较乱，不过大概意思能看出来，就是去除噪点，加二值化

这样处理完的图片像这样：

![验证码](/images/由一只大闸蟹想到的基于tesseract-ocr的验证码识别/2.bmp)

再使用识别引擎试下，正确率提高了一些，但是，还没法做到完全正确。

# 总结

对于图像识别，真的是一门大学问，我一开始想的过于简单了。后面发现坑确实还是多，而且对于`计算机图像`技术要求较高，虽然有开源引擎，但是调教还是要求程序员有深厚的内功，对于我这种刚入门的菜鸟，最后的结局就是失败了，大闸蟹最后也没吃上了。哈哈~

接下来还可以做的工作，包括 腐蚀， 滤波，主要还是对图片的处理

不过，我感觉也可以有其他思路，不过实现起来比较复杂，涉及到很多机器学习的东西

比如，可以切割拿到0-9个数字的一个二进制值，用来做原始数据，后面的待验证的都和原始数据进行比较，相似度最大的就认为是那个数字

但是这个相似度的计算，有待考虑

因为时间有限，只能暂时搁置

也希望有大神可以不吝赐教，这种验证码的识别应该怎么做，最佳实践是什么


ps. 国庆第一天总算没浪费，干了一些事，学了点东西 ╰(￣▽￣)╭

----

# 参考文档

参考过的一些文章，真心感谢前人的付出，技术人真的无私：

提供了一种Tesseract-ocr样本训练方法，提供一种比较好的思路，后面我也会做尝试
> http://blog.csdn.net/firehood_/article/details/8433077

写了一个基于Tesseract-ocr做电表度数的识别项目的思考过程，很有参考价值
> https://taozj.org/2016/07/%E4%B8%80%E4%B8%AA%E7%AE%80%E5%8D%95%E7%9A%84%E5%9F%BA%E4%BA%8ETesseract%E7%9A%84%E6%95%B0%E5%AD%97%E8%AF%86%E5%88%AB%E7%A8%8B%E5%BA%8F/?utm_source=tuicool&utm_medium=referral

Java 使用 Tess4J 进行 图片文字识别 笔记（API使用指导，如果使用JAVA的话，要看下）
> https://my.oschina.net/zhouxiang/blog/161619

> http://www.zhangrenhua.com/2016/05/26/Tesseract-OCR%E5%9B%BE%E7%89%87%E8%AF%86%E5%88%AB/

没有使用tesseract的一种思路，其实就是基于相似度的,还包括切割
> http://www.cnblogs.com/nayitian/p/3282862.html

tesseract-ocr 文档页面
> https://github.com/tesseract-ocr 文档页面/tesseract/wiki/AddOns#tesseract-wrappers

tesseract4java
> https://github.com/tesseract4java/tesseract4java

EasyPR
> https://github.com/liuruoze/EasyPR