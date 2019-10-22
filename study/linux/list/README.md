# 链表


- 1、结构体定义

遵守了自定义结构不定义数据的规则
```
struct list_node  {
   struct list_node  *prev;
   struct list_node  *next;
};

```

- 初始化
```
/*结构体直接复制初始化*/
#define LIST_HEAD_INIT(name) { &(name), &(name) }
#define LIST_HEAD(name) \
    struct list_head name = LIST_HEAD_INIT(name)



/*通俗易懂的初始化*/
static inline void INIT_LIST_HEAD(struct list_head *list)
{
    WRITE_ONCE(list->next, list);//等同于list->net = list;
    list->prev = list;
}

```


