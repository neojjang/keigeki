/*
 * Copyright (c) 2012-2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
/*!
 @file AKCharacter.m
 @brief キャラクタークラス定義
 
 当たり判定を持つオブジェクトの基本クラスを定義する。
 */

#import <math.h>
#import "AKCharacter.h"
#import "AKScreenSize.h"
#import "AKCommon.h"

/*!
 @brief キャラクタークラス
 
 当たり判定を持つオブジェクトの基本クラス。
 */
@implementation AKCharacter

@synthesize image = image_;
@synthesize width = width_;
@synthesize height = height_;
@synthesize speed = speed_;
@synthesize absx = absx_;
@synthesize absy = absy_;
@synthesize angle = angle_;
@synthesize rotSpeed = rotSpeed_;
@synthesize hitPoint = hitPoint_;
@synthesize isStaged = isStaged_;

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 各メンバを0で初期化する
    self.image = nil;
    self.width = 0;
    self.height = 0;
    self.absx = 0;
    self.absy = 0;
    self.speed = 0.0f;
    self.angle = 0.0f;
    self.rotSpeed = 0.0f;
    self.hitPoint = 0;
    self.isStaged = NO;
    
    return self;
}

/*!
 @brief インスタンス解放時処理

 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // スプライトを解放する
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @brief 絶対座標xのgetter

 絶対座標xを返す
 @return 絶対座標x
 */
- (float)absx
{
    return absx_;
}

/*!
 @brief 絶対座標xのsetter

 絶対座標xに値を設定する。ステージサイズの範囲内に収まるように調整する。
 @param 絶対座標x
 */
- (void)setAbsx:(float)absx
{
    // ステージの範囲内に収まるように値を設定する
    absx_ = AKRangeCheckLF(absx, 0.0f, [AKScreenSize stageSize].width);
}

/*!
 @brief 絶対座標yのgetter

 絶対座標yを返す
 @return 絶対座標y
 */
- (float)absy
{
    return absy_;
}

/*!
 @brief 絶対座標yのsetter

 絶対座標yに値を設定する。ステージサイズの範囲内に収まるように調整する。
 @param 絶対座標y
 */
- (void)setAbsy:(float)absy
{
    // ステージの範囲内に収まるように値を設定する
    absy_ = AKRangeCheckLF(absy, 0.0f, [AKScreenSize stageSize].height);
}
/*!
 @brief 移動処理

 速度によって位置を移動する。
 @param dt フレーム更新間隔
 @param scrx スクリーン座標x
 @param scry スクリーン座標y
 */
- (void)move:(ccTime)dt ScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry
{
    float posx = 0.0f;      // スクリーン座標x
    float posy = 0.0f;      // スクリーン座標y
    float velx = 0.0f;      // x方向の速度
    float vely = 0.0f;      // y方向の速度

    // 画面に配置されていない場合は無処理
    if (!self.isStaged) {
        return;
    }
    
    // HPが0になった場合は破壊処理を行う
    if (self.hitPoint <= 0) {
        [self destroy];
        return;
    }
        
    // 向きを更新する
    self.angle += (self.rotSpeed * dt);
    
    // 速度をx方向、y方向に分解する
    velx = self.speed * cosf(self.angle);
    vely = self.speed * sinf(self.angle);
    
    // iPadの場合は速度を倍にする
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        velx *= 2.0f;
        vely *= 2.0f;
    }
    
    AKLog(0, @"angle=%f vx=%f vy=%f", self.angle / M_PI * 180, velx / self.speed, vely / self.speed);
    
    // 座標の移動
    self.absx += (velx * dt);
    self.absy += (vely * dt);
        
    // 表示位置の計算
    // スクリーン位置中心からの距離 + スクリーンサイズの半分
    // スクリーン位置中心からの距離はステージサイズの半分を超えているときは反対側にいるものとして判定する。
    // これはマーカーの表示のため。
    posx = AKRangeCheckLF(self.absx - scrx + [AKScreenSize screenSize].width / 2,
                          -([AKScreenSize stageSize].width / 2),
                          [AKScreenSize stageSize].width / 2);
    posy = AKRangeCheckLF(self.absy - scry + [AKScreenSize screenSize].height / 2,
                          -([AKScreenSize stageSize].height / 2),
                          [AKScreenSize stageSize].height / 2);
    
    AKLog(0, @"vx=%f vy=%f ax=%f ay=%f px=%f py=%f sx=%d sy=%d", velx, vely, self.absx, self.absy, posx, posy, scrx, scry);
        
    // 表示座標の設定
    self.image.position = ccp(posx, posy);
    
    // 回転処理
    [self.image setRotation:AKCnvAngleRad2Scr(self.angle)];
        
    // キャラクター固有の動作を行う
    [self action:dt];
}

/*!
 @brief キャラクター固有の動作

 キャラクター種別ごとの動作を行う。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 派生クラスで動作を定義する
}

/*!
 @brief 破壊処理

 HPが0になったときの処理
 */
- (void)destroy
{
    // ステージ配置フラグを落とす
    self.isStaged = NO;
    
    // 画面から取り除く
    AKLog(0, @"removeFromParentAndCleanup実行");
    [self.image removeFromParentAndCleanup:YES];
}

/*!
 @brief 衝突判定

 キャラクターが衝突しているか調べ、衝突しているときはHPを減らす。
 @param characters 判定対象のキャラクター群
 */
- (void)hit:(const NSEnumerator *)characters
{
    AKCharacter *target = nil;      // 判定対象のキャラクター
    float myleft = 0.0f;            // 自キャラの左端
    float myright = 0.0f;           // 自キャラの右端
    float mytop = 0.0f;             // 自キャラの上端
    float mybottom = 0.0f;          // 自キャラの下端
    float targetleft = 0.0f;        // 相手の左端
    float targetright = 0.0f;       // 相手の右端
    float targettop = 0.0f;         // 相手の上端
    float targetbottom = 0.0f;      // 相手の下端
    
    // 画面に配置されていない場合は処理しない
    if (!self.isStaged) {
        return;
    }
    
    // 自キャラの上下左右の端を計算する
    myleft = self.image.position.x - self.width / 2.0f;
    myright = self.image.position.x + self.width / 2.0f;
    mytop = self.image.position.y + self.height / 2.0f;
    mybottom = self.image.position.y - self.height / 2.0f;
    
    AKLog(0, @"    my=(%f, %f, %f, %f)", myleft, myright, mytop, mybottom);
    
    // 判定対象のキャラクターごとに判定を行う
    for (target in characters) {
        
        // 相手が画面に配置されていない場合は処理しない
        if (!target.isStaged) {
            continue;
        }
        
        // 相手の上下左右の端を計算する
        targetleft = target.image.position.x - target.width / 2.0f;
        targetright = target.image.position.x + target.width / 2.0f;
        targettop = target.image.position.y + target.height / 2.0f;
        targetbottom = target.image.position.y - target.height / 2.0f;
        
        AKLog(0, @"target=(%f, %f, %f, %f)", targetleft, targetright, targettop, targetbottom);
        
        // 以下のすべての条件を満たしている時、衝突していると判断する。
        //   ・相手の右端が自キャラの左端よりも右側にある
        //   ・相手の左端が自キャラの右端よりも左側にある
        //   ・相手の上端が自キャラの下端よりも上側にある
        //   ・相手の下端が自キャラの上端よりも下側にある
        if ((targetright > myleft) &&
            (targetleft < myright) &&
            (targettop > mybottom) &&
            (targetbottom < mytop)) {
            
            // 自分と相手のHPを減らす
            self.hitPoint--;
            target.hitPoint--;
            
            AKLog(0, @"self.hitPoint=%d, target.hitPoint=%d", self.hitPoint, target.hitPoint);
        }
    }
}
@end
