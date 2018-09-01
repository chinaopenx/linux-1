GNU awk：

awk：报告生成器，格式化文本输出；

AWK: Aho, Weinberger, Kernighan --> New AWK, NAWK

GNU awk, gawk

gawk - pattern scanning and processing language

基本用法：gawk [options] 'program' FILE ...
	program: PATTERN{ACTION STATEMENTS}
		语句之间用分号分隔

		print, printf

	选项：
		-F：指明输入时用到的字段分隔符；
		-v var=value: 自定义变量；

1、print

	print item1, item2, ...

	要点：
		(1) 逗号分隔符；
		(2) 输出的各item可以字符串，也可以是数值；当前记录的字段、变量或awk的表达式；
		(3) 如省略item，相当于print $0;

2、变量
2.1 内建变量
	FS：input field seperator，默认为空白字符；
	OFS：output field seperator，默认为空白字符；
	RS：input record seperator，输入时的换行符；
	ORS：output record seperator，输出时的换行符；

	NF：number of field，字段数量
		{print NF}, {print $NF}
	NR：number of record, 行数；
	FNR：各文件分别计数；行数；

	FILENAME：当前文件名；

	ARGC：命令行参数的个数；
	ARGV：数组，保存的是命令行所给定的各参数；

2.2 自定义变量
	(1) -v var=value

		变量名区分字符大小写；

	(2) 在program中直接定义

	3、printf命令

		格式化输出：printf FORMAT, item1, item2, ...

			(1) FORMAT必须给出;
			(2) 不会自动换行，需要显式给出换行控制符，\n
			(3) FORMAT中需要分别为后面的每个item指定一个格式化符号；

			格式符：
				%c: 显示字符的ASCII码；
				%d, %i: 显示十进制整数；
				%e, %E: 科学计数法数值显示；
				%f：显示为浮点数；
				%g, %G：以科学计数法或浮点形式显示数值；
				%s：显示字符串；
				%u：无符号整数；
				%%: 显示%自身；

			修饰符：
				#[.#]：第一个数字控制显示的宽度；第二个#表示小数点后的精度；
					%3.1f
				-: 左对齐
				+：显示数值的符号

4、操作符

	算术操作符：
		x+y, x-y, x*y, x/y, x^y, x%y
		-x （正数转换为负数）
		+x: 转换为数值；

	字符串操作符：没有符号的操作符，字符串连接

	赋值操作符：
		=, +=, -=, *=, /=, %=, ^=
		++, --

	比较操作符：
		>, >=, <, <=, !=, ==

	模式匹配符：
		~：是否匹配
		!~：是否不匹配

	逻辑操作符：
		&&
		||
		!

	函数调用：
		function_name(argu1, argu2, ...)

	条件表达式：
		selector?if-true-expression:if-false-expression

		# awk -F: '{$3>=1000?usertype="Common User":usertype="Sysadmin or SysUser";printf "%15s:%-s\n",$1,usertype}' /etc/passwd

5、PATTERN

	(1) empty：空模式，匹配每一行；
	(2) /regular expression/：仅处理能够被此处的模式匹配到的行；
	(3) relational expression: 关系表达式；结果有“真”有“假”；结果为“真”才会被处理；
		真：结果为非0值，非空字符串；  #例：  awk -F: '$3>=1000{print $1,$3}' /etc/passwd
	(4) line ranges：行范围，
		startline,endline：/pat1/,/pat2/

		注意： 不支持直接给出数字的格式
		~]# awk -F: '(NR>=2&&NR<=10){print $1}' /etc/passwd
	(5) BEGIN/END模式
		BEGIN{}: 仅在开始处理文件中的文本之前执行一次；
		END{}：仅在文本处理完成之后执行一次；

6、常用的action

	(1) Expressions
	(2) Control statements：if, while等；
	(3) Compound statements：组合语句；
	(4) input statements
	(5) output statements

		7、控制语句

			if(condition) {statments}
			if(condition) {statments} else {statements}
			while(conditon) {statments}
			do {statements} while(condition)
			for(expr1;expr2;expr3) {statements}
			break
			continue
			delete array[index]
			delete array
			exit
			{ statements }

			7.1 if-else

				语法：if(condition) statement [else statement]

				~]# awk -F: '{if($3>=1000) {printf "Common user: %s\n",$1} else {printf "root or Sysuser: %s\n",$1}}' /etc/passwd

				~]# awk -F: '{if($NF=="/bin/bash") print $1}' /etc/passwd

				~]# awk '{if(NF>5) print $0}' /etc/fstab

				~]# df -h | awk -F[%] '/^\/dev/{print $1}' | awk '{if($NF>=20) print $1}'

				使用场景：对awk取得的整行或某个字段做条件判断；

			7.2 while循环
				语法：while(condition) statement
					条件“真”，进入循环；条件“假”，退出循环；

				使用场景：对一行内的多个字段逐一类似处理时使用；对数组中的各元素逐一处理时使用；

				~]# awk '/^[[:space:]]*linux16/{i=1;while(i<=NF) {print $i,length($i); i++}}' /etc/grub2.cfg

				~]# awk '/^[[:space:]]*linux16/{i=1;while(i<=NF) {if(length($i)>=7) {print $i,length($i)}; i++}}' /etc/grub2.cfg

			7.3 do-while循环
				语法：do statement while(condition)
					意义：至少执行一次循环体

			7.4 for循环
				语法：for(expr1;expr2;expr3) statement

					for(variable assignment;condition;iteration process) {for-body}

				~]# awk '/^[[:space:]]*linux16/{for(i=1;i<=NF;i++) {print $i,length($i)}}' /etc/grub2.cfg

				特殊用法：
					能够遍历数组中的元素；
						语法：for(var in array) {for-body}

			7.5 switch语句
				语法：switch(expression) {case VALUE1 or /REGEXP/: statement; case VALUE2 or /REGEXP2/: statement; ...; default: statement}

			7.6 break和continue
				break [n]
				continue

			7.7 next

				提前结束对本行的处理而直接进入下一行；

				~]# awk -F: '{if($3%2!=0) next; print $1,$3}' /etc/passwd

8、array

	关联数组：array[index-expression]

		index-expression:
			(1) 可使用任意字符串；字符串要使用双引号；
			(2) 如果某数组元素事先不存在，在引用时，awk会自动创建此元素，并将其值初始化为“空串”；

			若要判断数组中是否存在某元素，要使用"index in array"格式进行；

			weekdays[mon]="Monday"

		若要遍历数组中的每个元素，要使用for循环；
			for(var in array) {for-body}

			~]# awk 'BEGIN{weekdays["mon"]="Monday";weekdays["tue"]="Tuesday";for(i in weekdays) {print weekdays[i]}}'

			注意：var会遍历array的每个索引；
			state["LISTEN"]++
			state["ESTABLISHED"]++

			~]# netstat -tan | awk '/^tcp\>/{state[$NF]++}END{for(i in state) { print i,state[i]}}'

			~]# awk '{ip[$1]++}END{for(i in ip) {print i,ip[i]}}' /var/log/httpd/access_log

			练习1：统计/etc/fstab文件中每个文件系统类型出现的次数；
			~]# awk '/^UUID/{fs[$3]++}END{for(i in fs) {print i,fs[i]}}' /etc/fstab

			练习2：统计指定文件中每个单词出现的次数；
			~]# awk '{for(i=1;i<=NF;i++){count[$i]++}}END{for(i in count) {print i,count[i]}}' /etc/fstab

9、函数

	9.1 内置函数
		数值处理：
			rand()：返回0和1之间一个随机数；

		字符串处理：
			length([s])：返回指定字符串的长度；
			sub(r,s,[t])：以r表示的模式来查找t所表示的字符中的匹配的内容，并将其第一次出现替换为s所表示的内容；
			gsub(r,s,[t])：以r表示的模式来查找t所表示的字符中的匹配的内容，并将其所有出现均替换为s所表示的内容；

			split(s,a[,r])：以r为分隔符切割字符s，并将切割后的结果保存至a所表示的数组中；

			~]# netstat -tan | awk '/^tcp\>/{split($5,ip,":");count[ip[1]]++}END{for (i in count) {print i,count[i]}}'

	9.2 自定义函数
