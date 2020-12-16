# zephyr dma 驱动分析
* 驱动文件：
```c
dmamux_stm32.c
dmamux_stm32.h
```

* 设备结构体
```c

struct device {
	const char *name; /*驱动名称*/
	const void *config; /*设备实例配置信息的地址*/
	const void *api; /*设备实例的具体api函数结构体ops地址*/
	void * const data;/*设备实例的数据地址*/

#ifdef CONFIG_DEVICE_POWER_MANAGEMENT
	/*电源管理功能*/
	int (*device_pm_control)(const struct device *dev, uint32_t command,
				 void *context, device_pm_cb cb, void *arg);
	/*电源管理功能的数据结构体指针 */
	struct device_pm * const pm;
#endif
};
```


* 驱动api fops
```c
static const struct dma_driver_api dma_funcs = {
	.reload		 = dmamux_stm32_reload,
	.config		 = dmamux_stm32_configure,
	.start		 = dmamux_stm32_start,
	.stop		 = dmamux_stm32_stop,
};
/*此结构体的指针最终会赋值给struct device 中的 const void *api */
```

* 驱动注册
```c
DEVICE_AND_API_INIT(dmamux_##index, DT_INST_LABEL(index),	\
		    &dmamux_stm32_init,				\
		    &dmamux_stm32_data_##index, &dmamux_stm32_config_##index,\
		    POST_KERNEL, CONFIG_KERNEL_INIT_PRIORITY_DEFAULT,\
		    &dma_funcs);
```

* DEVICE_AND_API_INIT 分析

```c
#define DEVICE_AND_API_INIT(dev_name, drv_name, init_fn,		\
			    data_ptr, cfg_ptr, level, prio, api_ptr)	\
	DEVICE_DEFINE(dev_name, drv_name, init_fn,			\
		      device_pm_control_nop,				\
		      data_ptr, cfg_ptr, level, prio, api_ptr)


/*可以看出 DEVICE_AND_API_INIT 调用的是 DEVICE_DEFINE*/

#define DEVICE_DEFINE(dev_name, drv_name, init_fn, pm_control_fn, data_ptr, cfg_ptr, level, prio, api_ptr) \
	Z_DEVICE_DEFINE_PM(dev_name)					\
	static const Z_DECL_ALIGN(struct device)			\
		DEVICE_NAME_GET(dev_name) __used			\
	__attribute__((__section__(".device_" #level STRINGIFY(prio)))) = { \
		.name = drv_name,					\
		.config = (cfg_ptr),					\
		.api = (api_ptr),					\
		.data = (data_ptr),					\
		Z_DEVICE_DEFINE_PM_INIT(dev_name, pm_control_fn)	\
	};								\
	Z_INIT_ENTRY_DEFINE(_CONCAT(__device_, dev_name), init_fn,	\
			    (&_CONCAT(__device_, dev_name)), level, prio)

```
宏 DEVICE_AND_API_INIT将驱动drv name, init函数, cfg info, data, level prio和api组合成两个结构体struct device_config和struct device.

DEVICE_DEFINE和DEVICE_INIT都使用DEVICE_AND_API_INIT来完成device drv的注册，区别在于DEVICE_INIT不预先设置drv api，而是在运行时(例如init函数中)设置driver_api.

***驱动初始化顺序*** 

ephyr在使用DEVICE_AND_API_INIT注册宏时,需要开发者为驱动指定Level，不同的驱动level初始化的时机不一样，参见Zephyr如何运行到main, Zephyr一共分为4个level：

PRE_KERNEL_1

    该阶段只初始化完成中断控制器,内核尚未初始化, 因此该Level的驱动可以使用中断但不能用内核服务，也不依赖其它设备驱动。该Level的驱动初始化函数执行在中断堆栈上。

PRE_KERNEL_2

    该阶段已经完成了PRE_KERNEL_1初始化，但内核尚未初始化，因此该Level的驱动可以使用中断和PRE_KERNEL_1的驱动，但不能使用内核服务。该Level的驱动初始化函数执行在中断堆栈上。

POST_KERNEL

    该阶段已完成PRE_KERNEL_2初始化和内核初始化，因此该Level的驱动可以使用其它驱动和内核服务。该Level驱动初始化函数执行在main thread的堆栈上。
APPLICATION

    为了应用组件使用(例如shell),可以使用其它驱动和所有的内核服务。该Level驱动初始化函数执行在main thread的堆栈上。


