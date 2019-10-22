# 最小堆详解

- ***最小堆***

libevent中的时间事件是用最小堆来管理的，代码为位于<minheap-internal.h> 。
最小堆是一种经过排序的完全二叉树，其中任一非终端节点的数据值均不大于其左子节点和右子节点的值。堆就是利用完全二叉树建立的，完全二叉树，可以用数组来建立。假如说根节点是i，那么它的左儿子=2*i， 右儿子=2*i+1 。

libevent使用数组的形式来存储最小堆.
 


```

#include "event2/event-config.h"
#include "event2/event.h"
#include "event2/event_struct.h"
#include "event2/util.h"
#include "util-internal.h"
#include "mm-internal.h"

typedef struct min_heap
{
	struct event** p;
	unsigned n, a;
} min_heap_t;
-------------------------------------------------------------------------------
   p：表示节点的类型，节点的类型为struct event *
   a：数组的大小，即堆的分配的空间大小
   n：堆的元素个数,元素在堆中的位置用struct event_base结构中的min_head_idx表示即元素在数组中的索引值。
-------------------------------------------------------------------------------

static inline void	     min_heap_ctor(min_heap_t* s);
static inline void	     min_heap_dtor(min_heap_t* s);
static inline void	     min_heap_elem_init(struct event* e);
static inline int	     min_heap_elt_is_top(const struct event *e);
static inline int	     min_heap_elem_greater(struct event *a, struct event *b);
static inline int	     min_heap_empty(min_heap_t* s);
static inline unsigned	     min_heap_size(min_heap_t* s);
static inline struct event*  min_heap_top(min_heap_t* s);
static inline int	     min_heap_reserve(min_heap_t* s, unsigned n);
static inline int	     min_heap_push(min_heap_t* s, struct event* e);
static inline struct event*  min_heap_pop(min_heap_t* s);
static inline int	     min_heap_erase(min_heap_t* s, struct event* e);
static inline void	     min_heap_shift_up_(min_heap_t* s, unsigned hole_index, struct event* e);
static inline void	     min_heap_shift_down_(min_heap_t* s, unsigned hole_index, struct event* e);


-------------------------------------------------------------------------------
    inline 内联函数。 
    内联函数有些类似于宏。内联函数的代码会被直接嵌入在它被调用的地方，调用几次就嵌入几次，没有使用call指令。
    这样省去了函数调用时的一些额外开销，比如保存和恢复函数返回地址等，可以加快速度。
    不过调用次数多的话，会使可执行文件变大，这样会降低速度。
    加了static，一般可令可执行文件变小。
    Linux内核使用的inline函数大多被定义为static 类型。
-------------------------------------------------------------------------------


/* 比较两个元素的大小，这里是时间的大小。*/
int min_heap_elem_greater(struct event *a, struct event *b)
{
	return evutil_timercmp(&a->ev_timeout, &b->ev_timeout, >);
}

//evutil_timercmp的定义如下：
/** Return true iff the tvp is related to uvp according to the relational
 * operator cmp.  Recognized values for cmp are ==, <=, <, >=, and >. */
#define	evutil_timercmp(tvp, uvp, cmp)					\
	(((tvp)->tv_sec == (uvp)->tv_sec) ?				\
	 ((tvp)->tv_usec cmp (uvp)->tv_usec) :				\
	 ((tvp)->tv_sec cmp (uvp)->tv_sec))



/* 堆的初始化 */
void min_heap_ctor(min_heap_t* s) 
{
     s->p = 0; s->n = 0; s->a = 0; 
}

void min_heap_dtor(min_heap_t* s) 
{
     if (s->p) mm_free(s->p); 
}


/* 堆元素的初始化*/
void min_heap_elem_init(struct event* e) 
{ 
    e->ev_timeout_pos.min_heap_idx = -1; 
}

/* 判断是否为空 */
int min_heap_empty(min_heap_t* s) 
{
     return 0u == s->n;
}

/* 堆的中元素的大小*/
unsigned min_heap_size(min_heap_t* s) 
{ 
    return s->n; 
}

/* 获取堆的起始地址*/
struct event* min_heap_top(min_heap_t* s) 
{ 
    return s->n ? *s->p : 0; 
}


/* 向堆中添加一个元素*/
int min_heap_push(min_heap_t* s, struct event* e)
{
	if (min_heap_reserve(s, s->n + 1))
		return -1;
	min_heap_shift_up_(s, s->n++, e);
	return 0;
}
-------------------------------------------------------------------------------
min_heap_reserve 先判断堆的大小
min_heap_shift_up_ 将元素放入数组最后一个，然后在往上跟父节点比较和交换位置，直到父节点不大于该元素位置。
-------------------------------------------------------------------------------


/* 取出根节点元素一个元素*/
struct event* min_heap_pop(min_heap_t* s)
{
	if (s->n)
	{
		struct event* e = *s->p;
		min_heap_shift_down_(s, 0u, s->p[--s->n]);
		e->ev_timeout_pos.min_heap_idx = -1;
		return e;
	}
	return 0;
}
-------------------------------------------------------------------------------
取出根节点元素后，将最后一个元素放入根节点，然后依次跟子节点比较和交换位置，知道子节点大于该元素为止。
-------------------------------------------------------------------------------



/* 判断元素是否是根节点 */
int min_heap_elt_is_top(const struct event *e)
{
	return e->ev_timeout_pos.min_heap_idx == 0;
}



/*删除某个元素*/
int min_heap_erase(min_heap_t* s, struct event* e)
{
	if (-1 != e->ev_timeout_pos.min_heap_idx)
	{
		struct event *last = s->p[--s->n];
		unsigned parent = (e->ev_timeout_pos.min_heap_idx - 1) / 2;
		/* we replace e with the last element in the heap.  We might need to
		   shift it upward if it is less than its parent, or downward if it is
		   greater than one or both its children. Since the children are known
		   to be less than the parent, it can't need to shift both up and
		   down. */
		if (e->ev_timeout_pos.min_heap_idx > 0 && min_heap_elem_greater(s->p[parent], last))
			min_heap_shift_up_(s, e->ev_timeout_pos.min_heap_idx, last);
		else
			min_heap_shift_down_(s, e->ev_timeout_pos.min_heap_idx, last);
		e->ev_timeout_pos.min_heap_idx = -1;
		return 0;
	}
	return -1;
}

-------------------------------------------------------------------------------
先判断该元素是否有效，堆中元素为空的，数组索引值都是-1。
取出最后一个元素，插入到删除元素位置，然后对比删除位置的父节点跟子节点，从而确定是上浮元素还是下沉元素。
-------------------------------------------------------------------------------




/* 检查堆的大小，如果堆未分配空间，则分配8个元素空间，如果分配过，则扩大两倍*/
int min_heap_reserve(min_heap_t* s, unsigned n)
{
	if (s->a < n)
	{
		struct event** p;
		unsigned a = s->a ? s->a * 2 : 8;
		if (a < n)
			a = n;
		if (!(p = (struct event**)mm_realloc(s->p, a * sizeof *p)))
			return -1;
		s->p = p;
		s->a = a;
	}
	return 0;
}


/* 元素上浮*/
void min_heap_shift_up_(min_heap_t* s, unsigned hole_index, struct event* e)
{
    unsigned parent = (hole_index - 1) / 2;
    while (hole_index && min_heap_elem_greater(s->p[parent], e))
    {
	(s->p[hole_index] = s->p[parent])->ev_timeout_pos.min_heap_idx = hole_index;
	hole_index = parent;
	parent = (hole_index - 1) / 2;
    }
    (s->p[hole_index] = e)->ev_timeout_pos.min_heap_idx = hole_index;
}




/* 元素下沉*/
void min_heap_shift_down_(min_heap_t* s, unsigned hole_index, struct event* e)
{
    unsigned min_child = 2 * (hole_index + 1);
    while (min_child <= s->n)
	{
	min_child -= min_child == s->n || min_heap_elem_greater(s->p[min_child], s->p[min_child - 1]);
	if (!(min_heap_elem_greater(e, s->p[min_child])))
	    break;
	(s->p[hole_index] = s->p[min_child])->ev_timeout_pos.min_heap_idx = hole_index;
	hole_index = min_child;
	min_child = 2 * (hole_index + 1);
	}
    (s->p[hole_index] = e)->ev_timeout_pos.min_heap_idx = hole_index;
}

#endif /* _MIN_HEAP_H_ */
```


