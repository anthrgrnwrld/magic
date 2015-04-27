//
//  ViewController.swift
//  Magic
//
//  Created by Masaki Horimoto on 2015/04/25.
//  Copyright (c) 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageCurrectCardView: UIImageView!    //Magic開始範囲 & 生成中のカードView
    var touchPoint: CGPoint?                            //タッチ座標格納変数
    var imageOldCardViewArray: Array<UIImageView> = []  //過去に生成したカードViewを格納する配列
    var isControlImageCurrectCardView = false           //viewDidLayoutSubviews内の処理管理用
    var startImagePoint: CGPoint?                       //タッチ開始時のImageの座標を保存するProperty
    var currentImagePoint: CGPoint?                     //タッチ中のImageの座標を保存するProperty
    var startTouchPoint: CGPoint?                       //タッチ開始時のタッチ座標を保存するProperty


    override func viewDidLoad() {
        super.viewDidLoad()

        imageCurrectCardView.userInteractionEnabled = true  //カードviewのタッチ感知を有効に
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //AutoLayoutがEnableではview.frameの決定はviewDidLayoutSubviewsのタイミングで行われる（らしい）
    //view更新時、touchesBeganの後に呼ばれている
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isControlImageCurrectCardView != false {     //imageCurrectCardViewの操作中でなければ
            var size = CGSizeMake(100, 100)             //サイズ格納用変数size作成
            imageCurrectCardView.frame.size = size      //sizeをカードviewに適応
            imageCurrectCardView.center = touchPoint!   //タッチ座標をカードviewに適応
        } else {
            //Do nothing
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        touchPoint = touch.locationInView(self.view)            //タッチ座標を取得
        let tag = touch.view.tag
        startTouchPoint = touchPoint
        
        if tag == 999 {     //imageCurrectCardViewをタッチした場合のみ以下の処理を行う
            let size = CGSizeMake(100, 100)                                         //サイズ格納用変数size作成
            imageCurrectCardView.contentMode = UIViewContentMode.ScaleAspectFit     //画像の表示方法を設定
            displayImageCardViewWithPoint(  touchPoint!,
                                            size: size,
                                            imgName: "card.png",
                                            imageView: imageCurrectCardView,
                                            isControlImageCardView: true)           //cardViewを見える化関数を実行
        } else if tag > 0 {
            startImagePoint = imageOldCardViewArray[tag - 1].center                 //タッチしたカードのスタート位置を保存
            self.view.bringSubviewToFront(imageOldCardViewArray[tag - 1])           //imageOldCardViewArrayを最前面に
        } else {
            //Do nothing
        }
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        let tag = touch.view.tag                                            //タッチしている箇所のtagを取得する
        let deltaX = touch.locationInView(self.view).x - startTouchPoint!.x //タッチの移動量を計算
        let deltaY = touch.locationInView(self.view).y - startTouchPoint!.y //タッチの移動量を計算

        //tagに対応したcardViewを動かす
        if tag == 999 {
            imageCurrectCardView.center.x = startTouchPoint!.x + deltaX
            imageCurrectCardView.center.y = startTouchPoint!.y + deltaY

        } else if tag > 0 {
            imageOldCardViewArray[tag - 1].center.x = startImagePoint!.x + deltaX
            imageOldCardViewArray[tag - 1].center.y = startImagePoint!.y + deltaY
            
        } else {
            //Do nothing
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch
        touchPoint = touch.locationInView(self.view)    //タッチ座標を取得
        let tag = touch.view.tag
        
        if tag == 999 {     //imageCurrectCardViewをタッチした場合のみ以下の処理を行う
            //1. imageCurrectCardViewを初期状態に戻す
            let initialPoint = CGPointMake(187.5, 334.0)       //center座標格納変数point作成 (初期値に戻す)
            let initialSize = CGSizeMake(157, 210)             //サイズ格納用変数size作成 (初期値に戻す)
            imageCurrectCardView.contentMode = UIViewContentMode.ScaleToFill        //contentModeを変更
            displayImageCardViewWithPoint(  initialPoint,
                                            size: initialSize,
                                            imgName: "",
                                            imageView: imageCurrectCardView,
                                            isControlImageCardView: false)          //cardViewを見える化(コレは厳密に言うと見えない化...)関数を実行
            self.view.sendSubviewToBack(imageCurrectCardView)                       //imageCurrectCardViewは最背面へ


            //2. imageCurrectCardViewをimageOldCardViewArrayに格納する（ようなイメージの処理）
            var img = UIImage(named: "")
            imageOldCardViewArray.append(UIImageView(image:img))                    //imageOldCardViewArrayに要素を追加
            let count = imageOldCardViewArray.count                                 //imageOldCardViewArrayの数を保存
            let size = CGSizeMake(100, 100)                                                 //サイズ格納用変数size作成
            
            imageOldCardViewArray[count - 1].contentMode = UIViewContentMode.ScaleAspectFit //contentModeを変更
            imageOldCardViewArray[count - 1].tag = count                                    //配列番号でタグ付け
            displayImageCardViewWithPoint(  touchPoint!,
                                            size: size,
                                            imgName: "card.png",
                                            imageView: imageOldCardViewArray[count - 1],
                                            isControlImageCardView: false)                  //cardViewを見える化関数を実行
            self.view.addSubview(imageOldCardViewArray[count - 1])                          //画像生成
            
            imageOldCardViewArray[count - 1].userInteractionEnabled = true                  //タッチ操作を有効に
        } else {
            //Do nothing
            
        }
        
    }

    //cardViewを見える化する関数
    func displayImageCardViewWithPoint(point: CGPoint, size: CGSize, imgName: String, imageView: UIImageView, isControlImageCardView :Bool) {
        //, imgName: String, contentMode: String, isControlImageCurrectCardView :Bool
        imageView.frame.size = size                             //sizeをカードviewに適応
        imageView.center = point                                //pointをviewに適応
        imageView.image = UIImage(named: imgName)               //imgName画像を表示
        isControlImageCurrectCardView = isControlImageCardView  //imageCurrectCardViewが操作中 or not
        self.view.bringSubviewToFront(imageView)                //imageView最前面に
    }

    //表示中のカード全てを消去するアクション
    @IBAction func pressClean(sender: AnyObject) {
        for (index, val) in enumerate(imageOldCardViewArray) {
            UIView.animateWithDuration(2, animations: { () -> Void in
                self.imageOldCardViewArray[index].layer.opacity = 0.0
            })
            //self.imageOldCardViewArray[index].removeFromSuperview()
        }
        
        imageOldCardViewArray.removeAll()
        
    }


}

