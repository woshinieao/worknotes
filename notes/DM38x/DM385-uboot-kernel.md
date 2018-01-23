# UBOOT KERNEL 笔记

## UBOOT
```
    1、uboot 
        启动中 rom代码为第一阶段，uboot代码为第二阶段 。 TI814x内部ram 大小为128KB ， 后面的18KB作为rom的代码存放空间。

    2、U-Boot Support for DDR2/DDR3 Boards
        配置时钟频率
        arch/arm/include/asm/arch-ti81xx/clocks_ti814x.h 	
			#define DDR_PLL_400     /* Values supported 400,533 */
			
	修改 U-Boot DDR3 频率
		include/configs/dm385_ipnc.h   						/*使能DDR3模块*/
			#define CONFIG_DM385_DDR3_400                  /* Configure DDR3 in U-Boot */
			
	修改串口
		include/configs/dm385_ipnc.h    配置console的输出串口为第三个 ttyO2
		/*
		* select serial console configuration
		*/
		#define CONFIG_SERIAL1			3
		#define CONFIG_CONS_INDEX		3
		#define CONFIG_SYS_CONSOLE_INFO_QUIET

    3、U-Boot 编译	
		make uboot
```