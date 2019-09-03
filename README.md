# CTF中RSA的一些攻击思路

> 本项目收集了一些RSA的攻击脚本,并将其中一部分用python3重构
>
> 参考文章:
>
> https://www.tr0y.wang/2017/11/06/CTFRSA/index.html
>
> http://inaz2.hatenablog.com/entry/2016/01/20/022936

## 关于RSA算法

> **RSA加密算法**是一种非对称加密算法，1977年由Ron Rivest、Adi Shamir和Leonard Adleman一起提出的，算法安全性依赖于极大整数做因数分解的难度

## RSA算法加解密实现

1.随意选择两个大素数*p*和*q*，且*p不等于q*，计算*N=p***q*

2.计算*n*的欧拉函数*φ(n) = (p-1)(q-1)*（常用*phi(n)*表示*φ(n)*）

3.选择一个整数*e*，满足*1< e < φ(n)*，且*e与φ(n)* 互质（e通常取65537）

4.计算模反元素*d*，*ed ≡ 1 (mod φ(n))* 即求解*ex + φ(n)y = 1*方程组（利用扩展欧几里得算法可以求出*d*）

```d = gmpy2.invert(e, (p-1)*(q-1))```

5.得到公钥*（N，e）*私钥*（N，d）*

6.加密 *c = pow(m,e,N)*

7.解密 *m = pow(c,d,N)*

## RSA在CTF中的攻击方法

>gmpy2 安装
>
>sudo apt install libmpc-dev
>
>pip/pip3 install gmpy2
>
>sage安装
>
>https://mirrors.tuna.tsinghua.edu.cn/sagemath/linux/64bit/index.html

### 明文解密

#### **模互素**

d = gmpy2.invert(e,(p-1) * (q-1))

m = gmpy2.powmod(c,d,n)

#### **模不互素**

第一种情况

给出 p,q,c,e且gcd(e, (p-1)*(q-1))非常小(可能为3)

example:

p,q = 3881, 885445853681787330351086884500131209939

c = 1926041757553905692219721422025224638913707

e = 33

第二种情况

给出n1,n2,e1,e2,c1,c2求满足以下式子

assert p = gcd(n1,n2)

assert pow(flag,e1,n1)==c1

assert pow(flag,e2,n2)==c2

assert gcd(e1,(p1-1) * (q1-1))==gcd(e2,(p2-1) * (q2-1))



### 低加密指数攻击

m ^ e = kn + c 其中一般 e = 3，k比较小(k小于10亿爆破时间一般小于半小时)

### 低加密指数广播攻击

c1 ≡ m^e mod n1

c2 ≡ m^e mod n2

……

ce ≡ m^e mod ne

如以上所示，e比较小，题目给出n[e]和c[e],且m相同，利用中国剩余定理可以求m

### 低解密指数攻击

与低加密指数攻击相反，需要满足e非常大，接近于N

### 共模攻击

c1 ≡ m^e1 mod n

c2 ≡ m^e2 mod n

如以上使用了相同的模数N对相同的明文进行加密

### Boneh and Durfee attack

e 非常大接近于N，跟低解密指数攻击类似，比低解密指数攻击更强，可以解决d<N的0.292次方的问题

### Coppersmith攻击:已知p的高位攻击

知道p的高位为p的位数的约1/2时即可

### Coppersmith攻击:已知明文高位攻击

### Coppersmith攻击:已知d的低位攻击

如果知道d的低位，低位约为n的位数的1/4就可以恢复d

### Coppersmith攻击:明文高位相同

### 已知dp或dq（dp = d mod p-1，dq = d mod q-1）

### Least Significant Bit Oracle Attack

### 其他思路

给出两组数据

n1,c1,e1,n2,c2,e2且无以上特征可尝试gcd(n1,n2)得到公因子（存在的话）

给出一组数据

n1,c1,e1

尝试yafu或http://www.factordb.com分解n(p,q相差过大或过小yafu可分解成功)

给出如下数据

p,q,nextprime(p),nextprime(q)

n1 = p * q

n2 = nextprime(p) * nextprime(q)

n = n1 * n2

用yafu分解n可得到

n3 = p * nextprime(q)

n4 = q * nextprime(p)