---
title: 破解jar包直接修改class文件的方式
date: 2016-12-06 22:09:06
tags:
- java
category:
- java
---


# 用到的工具

jd-gui
> http://jd.benow.ca/

jclasslib 
> https://github.com/ingokegel/jclasslib

# 怎么修改

jd-gui是用来反编译jar包的，通过jd-gui可以很清晰的看到整个jar包里的所有java文件，还可以进行类搜索等功能

jclasslib可以查看到class文件的二进制结构，可以直观看到常量区，方法区信息，jclasslib没法直接修改class文件，只能查看，但是在jclasslib的安装位置，有个lib文件夹，里面有可以用于修改class文件的工具类，换句话说，**我们修改class文件是需要自己写代码的，没法直接可视化的修改class文件代码**

1. 可以通过jd-gui找到需要修改的代码位置，通过完整的代码结构，在jd-gui里面可以很轻松找到对应的类和方法
2. 在jclasslib中找到对应的方法，跳转进相应需要修改的常量存储地址，找到对应地址
3. 新建一个java项目，**把jclasslib的lib目录下的jar包拷贝进**来，然后参考下面的代码进行修改


```java
package com.soap.api;

import java.io.*;
import org.gjt.jclasslib.io.ClassFileWriter;
import org.gjt.jclasslib.structures.ClassFile;
import org.gjt.jclasslib.structures.Constant;
import org.gjt.jclasslib.structures.constants.ConstantUtf8Info;
public class Test {
	public static void main(String[] args) throws Exception {

		String filePath = "F:\\test\\ServerConfig.class";
		FileInputStream fis = new FileInputStream(filePath);

		DataInput di = new DataInputStream(fis);
		ClassFile cf = new ClassFile();
		cf.read(di);
		Constant[] infos = cf.getConstantPool();

		int count = infos.length;
		for (int i = 0; i < count; i++) {
			if (infos[i] != null) {
				System.out.print(i);
				System.out.print(" = ");
				System.out.print(infos[i].getVerbose());
				System.out.print(" = ");
				System.out.println(infos[i].getVerbose());
				if(i == 204){
					ConstantUtf8Info uInfo = (ConstantUtf8Info)infos[i];
					uInfo.setString("你好哇！李银河！");
					infos[i]=uInfo;
				}
			}
		}
		cf.setConstantPool(infos);
		fis.close();
		File f = new File(filePath);
		ClassFileWriter.writeToFile(f, cf);
	}
}


```


