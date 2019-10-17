# libevent 学习笔记


##一、libevent 数据结构




### 1、最小堆

libevent中的时间事件是用最小堆来管理的，代码为位于<minheap-internal.h>
最小堆：是一种经过排序的完全二叉树，其中任一非终端节点的数据值均不大于其左子节点和右子节点的值。
完全二叉树，可以用数组来建立。假如说根节点是i，那么它的左儿子=2*i， 右儿子=2*i+1 ，堆就是利用完全二叉树建立的。
最小堆结构体：
```
typedef struct min_heap
{
    struct event** p;
    unsigned n, a;
} min_heap_t;

```
libevent使用数组的形式来存储最小堆，数据结构中的p就是用来存储堆节点的数组，节点的类型为struct event *。数组的大小，即堆的大小用a来表示。堆的元素个数用n表示。元素在堆中的位置用struct event_base结构中的min_head_idx来表示。

最小堆相关的操作函数
```
static inline void	         min_heap_ctor(min_heap_t* s);
static inline void	         min_heap_dtor(min_heap_t* s);
static inline void	         min_heap_elem_init(struct event* e);
static inline int	         min_heap_elt_is_top(const struct event *e);
static inline int	         min_heap_elem_greater(struct event *a, struct event *b);
static inline int	         min_heap_empty(min_heap_t* s);
static inline unsigned	     min_heap_size(min_heap_t* s);
static inline struct event*  min_heap_top(min_heap_t* s);
static inline int	         min_heap_reserve(min_heap_t* s, unsigned n);
static inline int	         min_heap_push(min_heap_t* s, struct event* e);
static inline struct event*  min_heap_pop(min_heap_t* s);
static inline int	         min_heap_erase(min_heap_t* s, struct event* e);
static inline void	         min_heap_shift_up_(min_heap_t* s, unsigned hole_index, struct event* e);
static inline void	         min_heap_shift_down_(min_heap_t* s, unsigned hole_index, struct event* e);
```
