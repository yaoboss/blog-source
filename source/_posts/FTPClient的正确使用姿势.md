---
title: FTPClient的正确使用姿势
date: 2017-06-09 22:30:38
tags:
- java
category:
- java
---

> 虽然整体听着FTP这个词，已经不能再熟了。但是真正使用代码去操作他，还真是第一次。这次接到一个异常操蛋的任务，或者叫政治任务。对的，真正的政治任务。网信办要求各个互联网大公司，特别是直播公司，上报所有的用户以及用户相关的直播数据，用于对于直播犯罪的快速信息索引。听起来是一个无比美好的事情，然而我除了微笑也是没有其他什么可说的了。


# 业务介绍

简单来说就是需要上报数据，而上报数据的方式，就是将用户数据按指定格式写到**XML**中，然后通过**FTP**推到公安网信办的服务器上去。

就这么简单。

其他也就不说了，主要确实也是第一次使用JAVA去操作**FTP**，将**FTP**功能嵌套到代码里面。


<!-- more -->


# FTPClient

隐约记得JAVA是使用一个叫**FTPClient**的工具去操作的，所以也是二货不说直接引入相关包先


> commons-net:commons-net

FTPClient就包含在上面这个包里

引入进来之后

直接上代码：

``` java
package yaoboss.me;

import org.apache.commons.io.IOUtils;
import org.apache.commons.net.ftp.FTPClient;
import org.apache.commons.net.ftp.FTPReply;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.Proxy;
import java.nio.file.Files;

/**
 * FTP上传工具类
 * 
 */
@Component
public class FtpUtils {

	private static Logger logger = LoggerFactory.getLogger(FtpUtils.class);


	@Value("${ftp.ip}")
	private String ftpIp;

	@Value("${ftp.loginUserName}")
	private String loginUserName;
	@Value("${ftp.loginUserPass}")
	private String loginUserPass;

	/**
	 * 通过FTP上传文件 上报给公安
	 * @param fileName
	 */
	public void upload(String fileName) {
		FTPClient ftpClient = new FTPClient();
		FileInputStream fis = null;
		int replyCode;
		try {
			ftpClient.setConnectTimeout(4000);
			ftpClient.connect(ftpIp);
			boolean loginSuccess = ftpClient.login(loginUserName, loginUserPass);
			logger.warn("FTP登录状态: FTP_IP: [{}], 登录结果:[{}]", ftpIp, loginSuccess);

			// 重点在这里   获取返回码   判断链接或者登陆是否正常   
			replyCode = ftpClient.getReplyCode();
			logger.warn("FTP登录状态码: [{}]", replyCode);
			if (!FTPReply.isPositiveCompletion(replyCode)) {
				ftpClient.disconnect();
				logger.error("FTP连接不成功，reply code：[{}]", replyCode);
				return;
			}

			File srcFile = new File(fileName);
			fis = new FileInputStream(srcFile);
			//设置上传目录
			ftpClient.changeWorkingDirectory("/KUGOU");
			ftpClient.setBufferSize(1024);
			ftpClient.setControlEncoding("UTF-8");
			//设置文件类型（二进制）
			ftpClient.setFileType(FTPClient.BINARY_FILE_TYPE);
			ftpClient.enterLocalPassiveMode();
			boolean success = ftpClient.storeFile(new String(fileName.getBytes("UTF-8"), "iso-8859-1"), fis);

			// 重点！！！  这个ReplyCode是可以重复获取的   每次获取到的返回码 是最近一次操作的返回结果
			replyCode = ftpClient.getReplyCode();
			logger.warn("FTP上传状态: 文件名: [{}], 上传结果:[{}],replyCode:[{}]", fileName, success, replyCode);
		} catch (IOException e) {
			logger.error("FTP错误：", e);
		} finally {
			IOUtils.closeQuietly(fis);
			try {
				ftpClient.disconnect();
			} catch (IOException e) {
				logger.error("FTP关闭连接发生错误：", e);
			}
		}
	}
}


```


上面我直接放了一个上传的例子

里面的关键就在于两次获取**ReplyCode**

真的，这个特别重要，这是**FTP**的唯一调试方式，你不获取返回码，你对于上传失败的原因根本无从判断

而且每做一次操作后可以跟着获取一次最新的这个**ReplyCode**，可以知道刚才做的操作是否成功，或者失败的原因是什么

或者好像还可以获取**ReplyString()**，调用**getReplyString()**，在stackoverflow 看别人说这个返回更详细，我自己没用过，大家可以试试


# 后记

这个东西看起来简单，我却花了一下午调试

关键就在于那个坑爹的返回码，一开始我不知道有这东西，然后就发现login方法返回是登录成功的，但是死活就是上传文件不成功

后来网上搜了下，获取到返回码，直接用返回码一查，立马解决问题


坑爹。