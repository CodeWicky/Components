//
//  DWWaterFallLayout.m
//  testCol
//
//  Created by Wicky on 2018/11/29.
//  Copyright © 2018 Wicky. All rights reserved.
//

#import "DWWaterFallLayout.h"

typedef struct DWWaterFallLayoutIndexNode {
    NSUInteger index;
    CGFloat value;
    struct DWWaterFallLayoutIndexNode * preNode;
    struct DWWaterFallLayoutIndexNode * nextNode;
} DWWaterFallLayoutIndexNode;

typedef struct DWWaterFallLayoutIndexList {
    DWWaterFallLayoutIndexNode * head;
    DWWaterFallLayoutIndexNode * tail;
} DWWaterFallLayoutIndexList;

@interface DWWaterFallLayout ()

@property (nonatomic ,strong) NSMutableArray * attrs;

///始终保持value升序排列的list。(基于本类使用场景，固定list长度后，每次修改首项值之前确保list为升序排列，修改首项值然后做升序排列。如此反复修改首项值后做升序排列。此情景下本list比用arr维护高度后每次排序效率要高)
@property (nonatomic ,assign) DWWaterFallLayoutIndexList indexList;

@end

@implementation DWWaterFallLayout

#pragma mark --- tool method ---
-(void)resortNodeList {
    ///本方法每次在修改完最低cell后调用，故刚修改的定是list的head
    DWWaterFallLayoutIndexList list = self.indexList;
    DWWaterFallLayoutIndexNode * head = list.head;
    DWWaterFallLayoutIndexNode * current = head->nextNode;
    if (!current) {
        return;
    }
    if (head->value <= current->value) {
        return;
    }
    while (current) {
        if (head->value > current->value) {
            if (head->preNode) {
                head->preNode->nextNode = current;
            }
            if (current->nextNode) {
                current->nextNode->preNode = head;
            }
            head->nextNode = current->nextNode;
            current->preNode = head->preNode;
            head->preNode = current;
            current->nextNode = head;
            if (!current->preNode) {
                list.head = current;
            }
            if (!head->nextNode) {
                list.tail = head;
            }
            current = head->nextNode;
        } else {
            break;
        }
    }
    self.indexList = list;
}

-(void)configListWithDirection:(DWWaterFallLayoutDirection)direction {
    if (self.columnCount == 0) {
        DWWaterFallLayoutIndexList * tmp = NULL;
        self.indexList = *tmp;
        return;
    }
    
    DWWaterFallLayoutIndexList * list = malloc(sizeof(DWWaterFallLayoutIndexList));
    memset(list, 0, sizeof(DWWaterFallLayoutIndexList));
    DWWaterFallLayoutIndexNode * pre = NULL;
    int count = ((int)self.columnCount);
    for (int i = 0; i < count; ++i) {
        DWWaterFallLayoutIndexNode * node = malloc(sizeof(DWWaterFallLayoutIndexNode));
        memset(node, 0, sizeof(DWWaterFallLayoutIndexNode));
        node->index = i;
        node->value = (direction == DWWaterFallLayoutDirectionVertical) ? self.edgeInsets.top : self.edgeInsets.left;
        node->preNode = pre;
        if (pre) {
            pre->nextNode = node;
        }
        
        if (!list->head) {
            list->head = node;
        }
        if (i == count - 1) {
            list->tail = node;
        } else {
            pre = node;
        }
    }
    self.indexList = *list;
}

-(void)prepareVerticalLayoutWithColumnCount:(NSUInteger)columnCount itemCount:(NSUInteger)itemCount {
    CGFloat itemW = self.collectionView.bounds.size.width;
    itemW -= (self.edgeInsets.left + self.edgeInsets.right + (columnCount - 1) * self.interitemSpacing);
    if (itemW <= 0) {
        return;
    }
    itemW /= columnCount;
    [self configListWithDirection:DWWaterFallLayoutDirectionVertical];
    [self.attrs removeAllObjects];
    CGFloat tempX = self.edgeInsets.left;
    for (int i = 0; i  < itemCount; ++i) {
        UICollectionViewLayoutAttributes * attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        id<DWWaterFallLayoutItemProtocol> item = self.items[i];
        CGFloat itemH = itemW * item.originSize.height / item.originSize.width;
        attr.frame = CGRectMake(tempX, self.indexList.head->value, itemW, itemH);
        [self.attrs addObject:attr];
        self.indexList.head->value += (itemH + self.lineSpacing);
        [self resortNodeList];
        tempX = self.edgeInsets.left + (itemW + self.interitemSpacing) * self.indexList.head->index;
    }
}

-(void)prepareHorizontalLayoutWithColumnCount:(NSUInteger)columnCount itemCount:(NSUInteger)itemCount {
    CGFloat itemH = self.collectionView.bounds.size.height;
    itemH -= (self.edgeInsets.top + self.edgeInsets.bottom + (columnCount - 1) * self.interitemSpacing);
    if (itemH <= 0) {
        return;
    }
    itemH /= columnCount;
    [self configListWithDirection:DWWaterFallLayoutDirectionHorizontal];
    [self.attrs removeAllObjects];
    CGFloat tempY = self.edgeInsets.top;
    for (int i = 0; i  < itemCount; ++i) {
        UICollectionViewLayoutAttributes * attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        id<DWWaterFallLayoutItemProtocol> item = self.items[i];
        CGFloat itemW = itemH * item.originSize.width / item.originSize.height;
        attr.frame = CGRectMake(self.indexList.head->value, tempY, itemW, itemH);
        [self.attrs addObject:attr];
        self.indexList.head->value += (itemW + self.lineSpacing);
        [self resortNodeList];
        tempY = self.edgeInsets.top + (itemH + self.interitemSpacing) * self.indexList.head->index;
    }
}
#pragma mark --- override ---
-(void)prepareLayout {
    [super prepareLayout];
    if (self.columnCount == 0) {
        return;
    }
    NSUInteger columnCount = self.columnCount;
    NSUInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    if ((columnCount * itemCount) == 0) {
        return;
    }
    switch (self.direction) {
        case DWWaterFallLayoutDirectionHorizontal:
        {
            [self prepareHorizontalLayoutWithColumnCount:columnCount itemCount:itemCount];
        }
            break;
        default:
        {
            [self prepareVerticalLayoutWithColumnCount:columnCount itemCount:itemCount];
        }
            break;
    }
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrs;
}

-(CGSize)collectionViewContentSize {
    switch (self.direction) {
        case DWWaterFallLayoutDirectionHorizontal:
            {
                return CGSizeMake(self.indexList.tail->value - self.lineSpacing + self.edgeInsets.right, self.collectionView.bounds.size.height);
            }
            break;
            
        default:
        {
            return CGSizeMake(self.collectionView.bounds.size.width, self.indexList.tail->value - self.lineSpacing + self.edgeInsets.bottom);
        }
            break;
    }
}

-(instancetype)init {
    if (self = [super init]) {
        _columnCount = 3;
        _lineSpacing = 10;
        _interitemSpacing = 10;
    }
    return self;
}

#pragma mark --- setter/getter ---
-(NSMutableArray *)attrs {
    if (!_attrs) {
        _attrs = [NSMutableArray arrayWithCapacity:0];
    }
    return _attrs;
}

@end
