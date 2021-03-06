---
title: 十分钟理解字符编码：ASCII,Unicode,UTF-8,GBK,GB2312
date: 2016-09-26 23:24:11
tags:
- java
- 编码
category:
- java
---

> 从我们第一天写程序开始，就注定会碰到一个坑，编码问题。我相信不管是天生的大神，还是蹒跚前行的菜鸟，都有过在半夜上百度，上google，搜索“xxxx为什么显示乱码？”的经历，当时真的不理解什么是编码，为什么计算机需要编码，为什么会产生乱码，那时候只知道按照网上某个大神的知道，在哪里加一个endoding的声明，然后就好了，具体为什么，当时没有深究，也没有能力去深究，说实话。现在多年多去，回过头来看编码，就更容易理解的多了。把自己的理解记录下来，希望能作为一个十分钟的介绍教程，让人可以很快理解编码的门道。


<!-- more -->

# 什么是编码

计算机底层只有0,1这两种数据，也就是二进制，说白了就是逻辑电路，接通和断开，两种状态，表现0,1两种状态。那我们现实中这么多丰富的表现，要如何构建在这个简单的01之上呢，像英文26个字母，a-z，计算机如何去定义a-z这些字母呢？假设我们来设计计算机，我们怎么来表示呢？可能我最先想到的就是，`0表示a,1表示b,10表示c,11表示d,注意这里是二进制`，其实换成十进制也是一样，0表示a，1表示b，2表示c，3表示d，以此类推，就搞定了。

# 为什么需要编码

但是世界上这么多国家，这么多种类的语言，使用这么简单的0,1,2来表示，肯定是行不通的，需要一套科学的表现方式，也是就是我们说的字符编码了。由一个标准组织来制定，然后大家都准守，那么就可以解决字符在计算机上的表现问题啦。

# 为什么会出现乱码

乱码为什么会出现，这么来说，中国一开始搞了一套编码，0代表中，1代表国，但是美国也搞了一套编码，0代表a，1代表b，这样，我们传输了这两个中国字符给美国朋友的时候，他们的计算机看到0,1，那对应的就是a,b啊。相同的数字，在不同的编码中代表的含义不同，用错误的方式打开了原有的编码，就产生了乱码。当然，有时候乱码不是中国显示成a,b这么简单，可能会变成一个没法理解的字符。

# 实际使用中用什么编码

这样一个国家搞一套，大家各自占山为王，都没法正常沟通了，不能愉快的玩耍了。这时候肯定就有组织站出来说了，我们搞一套世界都通用的编码吧，那大家就方便了，不会老乱码了。这时候，unicode字符集出现了。unicode字符集，就相当于包括了世界上现有的所有语言，所以只要我们输入的时候，根据这里面的字符进行编码，那别人使用unicode解码的时候看到的也就是你想要表达的字符的意思了。

好了，有了unicode，Unicode是一套规则，也是标准。但是就像计算机行业的很多标准一样，标准就像接口，他不管你的实现方式，他也没有规定实现方式。对于Unicode字符，在标准里面，使用2个字节，或者4个字节来编码字符，但是这样就会造成有些字符明明可以一个字节搞定，但是在前面补了一个字节的0，这样非常浪费存储空间，因为白白占用了8个0的空间。这时候出现了`UTF-8`编码，简单理解，`UTF-8`实现了Unicode标准，并且实现方式非常节省空间，使用变长的方式。也就是说如果字符只需要一个字节，那就使用一个字节，不在前面强制补0。但是变长之后，一片文章里面，1个字节的也有，2个也有，3个也有，解析的时候怎么知道到底现在是1字节的字符，还是2字节的字符呢？`UTF-8`给出了一个聪明的实现，定了一个规则：

```

UTF-8（8-bit Unicode Transformation Format）是一种针对Unicode的可变长度字符编码，也是一种前缀码。

最小编码单位（code unit）为一个字节。一个字节的前1-3个bit为描述性部分，后面为实际序号部分。

1. 如果一个字节的第一位为0，那么代表当前字符为单字节字符，占用一个字节的空间。0之后的所有部分（7个bit）代表在Unicode中的序号。
2. 如果一个字节以110开头，那么代表当前字符为双字节字符，占用2个字节的空间。110之后的所有部分（5个bit）加上后一个字节的除10外的部分（6个bit）代表在Unicode中的序号。且第二个字节以10开头
3. 如果一个字节以1110开头，那么代表当前字符为三字节字符，占用2个字节的空间。110之后的所有部分（5个bit）加上后两个字节的除10外的部分（12个bit）代表在Unicode中的序号。且第二、第三个字节以10开头
4. 如果一个字节以10开头，那么代表当前字节为多字节字符的第二个字节。10之后的所有部分（6个bit）和之前的部分一同组成在Unicode中的序号。

```
就像`TCP包协议`一样，`UTF-8`也搞了类似包头含义的东西，来标明是几字节的字符。

有了这样的规则，这样的编码，基本就解决了统一编码的问题。

# Mysql中的编码问题

在早几年的时候，mysql就指定`utf8`就行了，啥问题都没有。但是后来出现了`emoji`表情，越来越多的移动设备开始支持`emoji`表情，我们开始发现存储`emoji`表情的时候mysql开始报错

`ERROR 1366: Incorrect string value: '\xF0\x9D\x8C\x86' for column`

其实根本原因就是，`emoji`的utf-8编码是4个字节，而mysql的`utf8`最大只支持3个字节

而为什么只支持3个字节，这种估计就是历史原因了，没有去深究

所以在`mysql 5.3.3`版本开始，`mysql`加入了`utf8mb4`，其实就是`maximum 4 bytes`，最大支持4个字节的`utf8`编码，这样就算可以支持所有`utf-8`编码的字符集了

**mysql官网说明**：https://dev.mysql.com/doc/refman/5.5/en/charset-unicode-utf8mb4.html

---


补充说明：（只是用于了解，可以略过）

虽然utf-8最大可以使用6个字节来表示`unicode`字符集，但是：

> UTF-8使用一至六个字节为每个字符编码（尽管如此，2003年11月UTF-8被RFC 3629重新规范，只能使用原来Unicode定义的区域，U+0000到U+10FFFF，也就是说最多四个字节）

> 说明：需要5个字节和6个字节UTF-8编码的unicode编码范围，属于UCS-4 编码
早期的规范UTF-8可以到达6字节序列，可以覆盖到31位元（通用字符集原来的极限）。尽管如此，2003年11月UTF-8 被 RFC 3629 重新规范，只能使用原来Unicode定义的区域， U+0000到U+10FFFF。根据规范，这些字节值将无法出现在合法 UTF-8序列中

上面引用自`wiki`和`百度百科`，总结就是，03年出的规范，utf-8最多使用4个字节来编码，大于4个字节编码的那些字符，使用utf-4(utf-32)去编

# trick

通过mysql识别和还原乱码

```
mysql [localhost] {msandbox} > select hex(convert('寰堝睂' using gbk));
+-------------------------------------+
| hex(convert('寰堝睂' using gbk))    |
+-------------------------------------+
| E5BE88E5B18C                        |
+-------------------------------------+
1 row in set (0.01 sec)


mysql [localhost] {msandbox} ((none)) > select convert(0xE5BE88E5B18C using utf8);
+------------------------------------+
| convert(0xE5BE88E5B18C using utf8) |
+------------------------------------+
| 很屌                               |
+------------------------------------+
1 row in set (0.00 sec)
```

---- 

参考文章：

> http://cenalulu.github.io/linux/character-encoding/
> http://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html
> https://www.zhihu.com/question/23374078
