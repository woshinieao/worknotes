 
#Zephyr 简介

##1.1 zephyr 是什么？
 Zephyr 是由 Linux 基金会托管的开源协作项目，目标是构建一个针对资源受限设备的小型、可裁剪的实时操作系统(RTOS)。Zephyr 项目非常适合构建简单的传感器网络、可穿戴设备以及小型物联网无线网关。系统采用模块化设计，支持多种 CPU 架构，开发人员可以很容易的根据需求定制一个最优的解决方案。

##1.2 zephyr 的优缺点
* **优点**:
1、	**开源**：使用 Apache 2.0 开源许可；
2、	**模块化**：针对受限制的物联网设备而设计，可以通过 Kconfig 裁剪功能选项，从而实现用户自定义的最佳配置；
3、	**联网能力**：系统中提供了多种针对低功耗、内存受限设备的连接协议，支持低功耗蓝牙(BLE)、wifi、802.15.4以及其他标准，包括6lowpan、coap、ipv4和ipv6 ；
4、	**安全性**：项目在开发过程中将安全因素考虑在内，该项目中提供了安全验证、模糊和渗透测试、代码审查、静态代码分析、威胁建模和审查等多种检测方法，用来防止代码中存在后门和漏洞。以上工作由专门的安全小组及维护人员进行监督和维护。
5、	**开发环境**：支持多种开发环境（Windows、Linux、MacOS）；

* **缺点**：
1、	开发习惯和传统的嵌入式MCU开发差别太大（但和嵌入式Linux的开发哲学很接近）。
2、	Zephyr生态的学习成本比较高，有python, sh, git, west, CMake，make, qemu, posix，这些在采用KEIL/IAR这些集成开发环境来管理和迭代整个MCU项目。
3、	就是官网上列出支持的Boards虽然非常多，但是，这些板中，相当部份的板级支持离拿来应用于生产环境
还需要开发者根据模板完善板级驱动才行，由于Zephyr的体系结构移植和板级驱动目前还不如在KEIL和
IAR下来得方便，这也是很多人不看好Zephyr生态的原因。
4、	Zephyr生态目前还没有支持广泛使用的Keil, IAR等商用IDE.。




#Zyphyr 内核


##2.1 架构

 Zephyr 内核的中心元素是微内核和超微内核。Zephyr 内核也包含一些列辅助的子系统，比如设备驱动库和网络库。
　　应用程序由两种开发模式：同时使用微内核和超微内核；只使用超微内核。
　　超微内核具有内核的一系列基础特征，是一个高性能、多线程的执行环境。超微内核适用于内存很少（最少为 2KB）的系统或者简单的多线程系统（比如只有一些列中断处理和单后台 task）。这样的系统主要包括：嵌入式传感器 hub、传感器、简单 LED 可穿戴设备以及商店库存的标签。
　　微内核比超微内核的功能更加丰富。超微内核适用于这样的系统：内存更多（50 ~ 900 KB）、多通信设备（比如WIFI、低功耗蓝牙）、多 task。这样的系统主要包括：可穿戴设备、智能手表、物联网无线网关。


##2.2 多线程
###2.2.1概念
应用程序可以定义任意数量的线程，且可以使用线程创建时分配给该线程的 线程标识符（thread id） 来引用该线程。
线程的注关键属性包括：
•	栈区域：一段用于线程控制块（struct k_thread）和线程栈的内存区域。 栈空间的 大小 可以被裁剪，以适应线程处理的实际需求。
•	入口点函数：线程启动时调用的函数。该函数最多能接收 3 个参数。
•	调度优先级：指示内核的调度器如何给该线程分配 CPU 时间。
•	线程选项：允许内核在特定场景中对该线程做某种特殊处理。
•	启动时延： 指定线程在启动前需要等待的时间。
###2.2.2线程的创建
线程必须先创建、再使用。创建线程时，内核将初始化线程栈区域的控制块区域以及栈的尾部。栈区域的其它部分通常都是未初始化的。
如果指定的启动时延是 K_NO_WAIT，内核将立即启动线程。您也可以指定一个超时时间，让内核延迟启动该线程。例如，让线程需要使用的设备就绪后再启动线程。
如果延迟启动的线程还未启动，内核可以取消该线程。如果线程已经启动了，则内核在尝试取消它时不会有如何效果。如果延迟启动的线程被成功地取消了，它必须被再次创建后才能再次使用。

###2.2.3线程的正常结束
线程一旦启动，它通常会一直运行下去。不过，线程也可以从它的入口点函数中返回，从而同步结束执行。这种结束方式叫做 正常结束（terminaltion）。
正常结束的线程需要在返回前释放它所拥有的共享资源（例如互斥量、动态分配的内存）。内核 不会 自动回收这些资源。
注解
当前内核不会做任何补偿。应用程序可以重新创建正常结束的线程。
###2.2.4线程的异常终止
线程可以通过 异常终止 （aborting） 异步结束其执行。如果线程触发了一个致命错误（例如引用了空指针），内核将自动终止该线程。
其它线程（或线程自己）可以调用 k_thread_abort() 终止一个线程。不过，更优雅的做法是向线程发送一个信号，让该线程自己结束执行。
线程终止时，内核不会自动回收该线程拥有的共享资源。
注解
当前内核不会做任何补偿。应用程序可以重新创建异常终止的线程。
###2.2.5线程的挂起
如果一个线程被挂起，它将在一段不确定的时间内暂停执行。函数 k_thread_suspend() 可以用于挂起包括调用线程在内的所有线程。对已经挂起的线程再次挂起时不会产生任何效果。
线程一旦被挂起，它将一直不能被调度，除非另一个线程调用 k_thread_resume() 取消挂起。
注解
线程可以使用 k_sleep() 睡眠一段指定的时间。不过，这与挂起不同，睡眠线程在睡眠时间完成后会自动运行。
###2.2.6线程的选项
内核支持一系列 线程选项（thread options），以允许线程在特殊情况下被特殊对待。这些与线程关联的选项在线程创建时就被指定了。
不需要任何线程选项的线程的选项值是零。如果线程需要选项，您可以通过选项名指定。如果需要多个选项，使用符号 | 作为分隔符。（即按位或操作符）。
支持如下选项：
K_ESSENTIAL
该选项将线程标记为 必须线程（essential thread），表示当该线程正常结束或异常终止时，内核将认为产生了一个致命的系统错误。
默认情况下，一般线程都不是必须线程。
K_FP_REGS and K_SSE_REGS
这两个选项是 x86 相关的选项，分别表示线程使用 CPU 的浮点寄存器和 SSE 寄存器，指示内核在调度线程进行时需要采取额外的步骤来保存/恢复这些寄存器的上下文。（更多信息请参考 浮点服务）。
默认情况下，内核在调度线程时不会保存/恢复这些寄存器的上下文。
##2.3实现
###2.3.1创建一个线程
您可以通过定义线程的栈区域并调用 k_thread_spawn() 创建一个线程。栈区域是一个由字节构成的数组，且其大小必须等于 K_THREAD_SIZEOF 加上线程栈大小之和。栈区域必须使用属性 __stack 进行定义，以确保被正确对齐。
创建线程的函数会返回该线程的标识符（ID），您可以使用该标识符来引用该线程。
下面的代码创建了一个立即启动的线程。

```C
#define MY_STACK_SIZE 500
#define MY_PRIORITY 5
extern void my_entry_point(void *, void *, void *);
char __noinit __stack my_stack_area[MY_STACK_SIZE];
k_tid_t my_tid = k_thread_spawn(my_stack_area, MY_STACK_SIZE,
                                my_entry_point, NULL, NULL, NULL,
                                MY_PRIORITY, 0, K_NO_WAIT);
```
您也可以调用 K_THREAD_DEFINE 在编译时创建线程。需要注意的是，这个宏自动定义了一个栈区域以及一个线程标识符变量。
下面的代码与上面的代码具有系统的效果。
```C
#define MY_STACK_SIZE 500
#define MY_PRIORITY 5

extern void my_entry_point(void *, void *, void *);

K_THREAD_DEFINE(my_tid, MY_STACK_SIZE,
                my_entry_point, NULL, NULL, NULL,
                MY_PRIORITY, 0, K_NO_WAIT);
```
###2.3.2结束一个线程
线程可以从它的入口点函数中返回，以正常结束其运行。
下面的代码描述了线程正常结束的方法。

```C
void my_entry_point(int unused1, int unused2, int unused3)
{
    while (1) {
        ...
        if (<some condition>) {
            return; /* thread terminates from mid-entry point function */
        }
        ...
    }

    /* thread terminates at end of entry point function */
}
```


##2.4建议的用法
建议使用线程来处理不便于在终端服务例程中处理的任务。
建议为每个在逻辑上有差异的任务创建一个独立的线程，让它们并行执行。
###2.5配置选项
相关的配置选项：
•	无。

###2.6 API
头文件 kernel.h 提供了如下的线程生命周期 API：

```C
•	K_THREAD_DEFINE
•	k_thread_spawn()
•	k_thread_cancel()
•	k_thread_abort()
•	k_thread_suspend()
•	k_thread_resume()
```


##中断
中断服务例程 (ISR) 是一个异步响应硬件或者软件中断的函数。ISR 通常会抢占当前正在执行的线程，以达到快速响应的目的。只有当所有的 ISR 工作都完成后，线程才能得以恢复执行。

* 概念
* 阻止中断
* 移交 ISR 工作
* 实现
* 定义一个常规的 ISR
* 定义一个直接的 ISR
* Suggested Uses
* 配置选项
* API

###概念
理论上，您可以定义任意数量的 ISR，但是它的实际个数受到硬件的限制。

ISR 的关键属性如下：

**中断请求（IRQ）信号**：触发 ISR 的信号。
**优先级**：与 IRQ 绑定在一起的优先级。
**中断处理函数**：用于处理中断的函数。
**参数值**：传递给函数的参数。

IDT（中断描述符表） 或者向量表用于将一个给定的 ISR 与一个给定的中断源关联在一起。在任意时刻，一个 IRQ 只能与一个 ISR 关联。

多个 ISR 可以利用同一个函数来处理中断，这样的好处是允许一个函数可以同时服务于某个设备产生的多种不同类型中断，或者甚至服务于多个设备（通常是同种类型的）产生的中断。传递给 ISR 的参数值可以用于判断是具体哪一个中断源产生了信号。

内核为所有未使用的 IDT 入口提供了一个默认的 ISR。如果发生了意外的中断，改 ISR 将产生一个致命系统错误。

内核支持 **中断嵌套**，即高优先级的中断可以抢占正在执行的低优先级中断。当高优先级的 ISR 处理完成后，低优先级的 ISR 将恢复执行。

ISR 的中断处理函数在内核的 **中断上下文** 中执行。这个上下文有自己专用的栈区。如果中断嵌套被使能了，必须保证中断上下文栈的大小能够容纳多个 ISR 并发执行。
<font size=2 color=#DC143C>
重要
很多 API 只能被线程使用，不能被 ISR 使用。如果某个函数既可以被线程调用，也可以被 ISR 调用，内核会使用 API cpp:func:k_is_in_isr() 来让该函数判断当前的上下文是线程还是 ISR，然后再做对应的处理。
</font>

**阻止中断**
在某些特殊情况下，例如当前线程正在执行时间敏感的任务或者进行临界区的操作，则可能需要阻止 ISR 运行。

线程可以使用 IRQ 锁 临时阻止系统处理所有 IRQ。IRQ 锁可以嵌套使用。内核如果要再次正常处理 IRQ，则必须保证 IRQ 解锁的次数等于 IRQ 锁的次数。


<font size=2 color=#DC143C>
重要:

IRQ 锁是与线程相关的。如果线程 A 锁定了中断，然后执行了某个操作（例如释放了一个信号量，或者睡眠 N 毫秒）导致线程 B 开始运行，则当线程 A 被交换出去后，这个线程锁将（暂时）失效。也就是说，当线程 B 运行后，除非它使用了自己的 IRQ 锁锁定了中断，否则它将能正常处理中断。（当内核正在在使用了 IRQ 锁的两个线程间切换时，其是否可以处理中断依赖于具体的架构。

当线程 A 再次变为当前线程后，内核会重新建立线程 A 的 IRQ 锁。这意味着，线程 A 在明确解除 IRQ 锁前都不会被中断。
或者，线程也可以临时 禁止 某一个 IRQ。当接收到该 IRQ 的信号时，其关联的 ISR 不会被执行。在随后，该 IRQ 必须被 使能，以允许其 ISR 能够执行。

 禁止一个 IRQ 后，不仅仅是禁止该 IRQ 的线程不会被对应的 ISR 抢占，而是系统中的 所有 线程都不会被这个 IRQ 对应的 ISR 抢占。
</font>

**移交 ISR 工作**
ISR 应当快速执行，以确保可预见的系统行为。如果需要执行耗时的处理，ISR 应当将部分或者全部处理都移交给线程，以此恢复内核响应其它中断的功能。

内核支持多种将中断相关处理移交给线程的机制。

ISR 可以利用内核对象，例如 fifo、lifo 或者信号量，给帮助线程发送信号，让它们做中断相关的处理。
ISR 可以发送一个告警，让系统的工作队列线程执行一个相关的告警处理函数。（参考 告警。）
ISR 可以指示系统工作队列线程执行一个工作项。（参考 TBD。）
当 ISR 将工作移交给线程后，内核通常会在 ISR 完成后切换到该线程，以使中断相关的处理能够立即执行。不过，这依赖于处理移交工作的线程的优先级，即当前正在执行的协作式线程或者其它高优先级线程可能比该线程先执行。

###实现
定义一个常规的 ISR
在运行时，可以先调用 IRQ_CONNECT 来定义一个 ISR，然后调用 irq_enable() 来使能该 ISR。



<font size=2 color=#DC143C>
重要

IRQ_CONNECT() 不是 C 函数，其它内部其实是一个内敛汇编。它的所有参数都必须在编译时确定。如果一个驱动程序有多个实例，它可以为该驱动的每个实例定义一个配置函数。
</font>

下面的代码定义并使能了一个 ISR。
```c


#define MY_DEV_IRQ  24       /* device uses IRQ 24 */
#define MY_DEV_PRIO  2       /* device uses interrupt priority 2 */
/* argument passed to my_isr(), in this case a pointer to the device */
#define MY_ISR_ARG  DEVICE_GET(my_device)
#define MY_IRQ_FLAGS 0       /* IRQ flags. Unused on non-x86 */

void my_isr(void *arg)
{
   ... /* ISR code */
}

void my_isr_installer(void)
{
   ...
   IRQ_CONNECT(MY_DEV_IRQ, MY_DEV_PRIO, my_isr, MY_ISR_ARG, MY_IRQ_FLAGS);
   irq_enable(MY_DEV_IRQ);
   ...
}
```
**定义一个直接的 ISR**
常规的 Zephyr 中断会引进一些开销，这对于某些需要低延迟的用例是不可接受的，尤其是：

参数需要先被取回然后传递给 ISR。
如果电源管理被使能，且系统处于空转装填，则所有的硬件将会在 ISR 执行前从低功耗状态中恢复，这是非常耗时的。
对于中断栈的切换，尽管某些架构会由硬件自动完成，但是另外一些架构需要人工在代码中完成。
中断服务完成后，操作系统会执行一些逻辑，有可能会执行调度决策。
Zephyr 支持一种被叫做“直接中断”的中断。直接中断使用宏 `IRQ_DIRECT_CONNECT` 进行安装。直接中断有一些特殊需求以及一些被简化的特性集，详细内容请参考 `IRQ_DIRECT_CONNECT` 。

下面的代码演示了如何使用直接 ISR：
```c
#define MY_DEV_IRQ  24       /* device uses IRQ 24 */
#define MY_DEV_PRIO  2       /* device uses interrupt priority 2 */
/* argument passed to my_isr(), in this case a pointer to the device */
#define MY_IRQ_FLAGS 0       /* IRQ flags. Unused on non-x86 */

ISR_DIRECT_DECLARE(my_isr)
{
   do_stuff();
   ISR_DIRECT_PM(); /* PM done after servicing interrupt for best latency */
   return 1; /* We should check if scheduling decision should be made */
}

void my_isr_installer(void)
{
   ...
   IRQ_DIRECT_CONNECT(MY_DEV_IRQ, MY_DEV_PRIO, my_isr, MY_IRQ_FLAGS);
   irq_enable(MY_DEV_IRQ);
   ...
}
```
##建议
在常规 ISR 或者直接 ISR 中执行需要快速响应、能够快速完成、不会阻塞的中断处理。
<font size=2 color=#9932CC>
注解
对于那些比较耗时的，或者会阻塞的中断处理，应当将它们的工作移交给一个线程。您可以阅读 移交 ISR 工作 查看可以在应用程序中使用的各种技术。
</font>
##配置选项
相关的配置选项：

`CONFIG_ISR_STACK_SIZE`
此外，还有一些与架构相关的或者与设备相关的配置选项。

##API
头文件 irq.h 中提供了如下的与中断相关的 API：
```c
IRQ_CONNECT
IRQ_DIRECT_CONNECT
ISR_DIRECT_HEADER
ISR_DIRECT_FOOTER
ISR_DIRECT_PM
ISR_DIRECT_DECLARE
irq_lock()
irq_unlock()
irq_enable()
irq_disable()
irq_is_enabled()
```
头文件 kernel.h 中提供了如下的与中断相关的 API：
```c
k_is_in_isr()
k_is_preempt_thread()
```


