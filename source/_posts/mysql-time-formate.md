---
title: mysql的时间格式化
date: 2016-08-15 11:56:26
tags:
- mysql
category:
- mysql
---


# mysql时间格式化

*转载请注明：姚老板的黑店*
> www.yaoboss.me

> 在我们的日常开发中，经常会涉及到一些时间相关的操作，比如说，要根据一个时间维度去查询某些数据，或者指定一个时间点去查询数据。这些都会涉及到时间的比较操作，等于，大于，小于，这时候，我们到底在表中源数据选取什么格式来保存时间，就变的尤为重要了，这关系到我们后面查询数据的便利性，以及mysql查询的性能开销。

1.
我们平时开发中，最简单的方式莫过于直接保存一个时间戳了，也就是一个`UNIX_TIME`格式的时间戳，也就是一个10位的以`秒`为单位的数字，这是最简单的方式，在各种语言中都提供了简单的API支持。

**java**

```java
System.getCurrentMillis(); //要注意，java这里获取的是毫秒级时间，最后要“/1000”
```

**go**

```go
time.Now().Unix()
```

直接将这个时间保存到mysql，这是最简单的一种记录时间戳的方式。统计查询时也非常简单，直接是数字的比较，速度也非常快。

==特别注意：==这里有很多老的教程，或者是文章，或者是视频课程，大学课本，都会教mysql里面保存时间，时间`timestamp`类型，但是，这真的过时了，`timestamp`在实际工作中，基本没用到过，上面这种直接记录秒级的时间戳，要方便太多。

2.
上面的处理方式，已瞒足大多数业务场景，但是，当我们碰到一些特殊的需求，针对某一天的维度，或者是某个月份，或者是某个年份，那我们存储的时候就要存某年，某月，某日。

在mysql中，我们使用`varchar`字符串类型存储这种时间格式，比如：`2015-06-01`,像这种类型的时间字符串，mysql是支持直接比较大小的，也就是说我们可以写下面这种sql语句：

```sql
select * from table where time >= '2015-06-01' and time <= '2016-06-01'
```
上面的sql语句可以查出，这一年间，15年6月1号到16年6月1号的数据。

所以，如果使用这种格式，我们在程序中就使用程序中的代码，对时间进行格式化后，再保存到数据库。

比如go代码可以这么写：
```go
time.Now().Format("2006-01-02") //注意：这里go的格式化字符串比较特别，必须使用2006年1月2号这个日期，据说是go诞生的日期

time.Date(timeTime.Year(), timeTime.Month(), timeTime.Day(), 24, 0, 0, 0, timeTime.Location()).Unix()
//根据指定日期构造time对象
```

3.
如果你的项目代码中已经保存了`unix_time`类型的时间戳，你又想对其进行日期的比较，这里也可以使用mysql中的自带函数，进行字段格式化。

- 将`unix_time`转为日期格式：
```sql
FROM_UNIXTIME(unix_timestamp)
```

- 将时间戳转为日期格式，并按照指定格式格式化：
```sql
DATE_FORMAT(date,format)

DATE_FORMAT(FROM_UNIXTIME(unix_timestamp),'%m-%d-%Y')
```
对于支持的格式，直接搜索date_formate函数就可以搜到了。

- 还可以直接获取，年月日
```
year( FROM_UNIXTIME( unix_timestamp ) )
month( FROM_UNIXTIME( unix_timestamp ) )
week( FROM_UNIXTIME( unix_timestamp ) )

```