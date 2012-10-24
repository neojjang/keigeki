/*!
 @file AKBackground.h
 @brief 背景クラス定義
 
 背景の描画を行うクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCommon.h"

// 背景クラス
@interface AKBackground : NSObject {
    /// 背景画像のバッチノード
    CCSpriteBatchNode *batch_;
}

/// 背景画像のバッチノード
@property (nonatomic, retain)CCSpriteBatchNode *batch;

// 移動処理
- (void)moveWithScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry;

@end
