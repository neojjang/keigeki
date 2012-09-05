/*!
 @file AKMenuItem.m
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目クラスを定義する。
 */

#import "AKMenuItem.h"
#import "common.h"

/*!
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目。
 メニューの位置、大きさ、処理を管理する。
 */
@implementation AKMenuItem

@synthesize action = m_action;
@synthesize tag = m_tag;

/*!
 @brief メニュー項目生成
 
 メニュー項目の生成を行う。
 @param pos 位置と大きさ
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithPos:(CGRect)pos action:(SEL)action tag:(NSInteger)tag
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 引数をメンバに設定する
    m_pos = pos;
    m_action = action;
    m_tag = tag;
    
    return self;
}

/*!
 @brief メニュー項目生成のコンビニエンスコンストラクタ
 
 メニュー項目の生成を行う。
 @param pos 位置と大きさ
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)itemWithPos:(CGRect)pos action:(SEL)action tag:(NSInteger)tag
{
    return [[[[self class] alloc] initWithPos:pos action:action tag:tag] autorelease];
}

/*!
 @brief 項目選択判定
 
 座標がメニュー項目の範囲内かどうかを判定する。
 @param pos 選択位置
 @return メニュー項目の範囲内かどうかを
 */
- (BOOL)isSelectPos:(CGPoint)pos
{
    // 座標がメニュー項目の範囲内の場合は処理を行う
    return AKIsInside(pos, m_pos);
}

@end
