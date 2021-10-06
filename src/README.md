10/4 mao7
    1. 多設兩個input,還不知道合不合法,key2是pause/resume,key3是加速
    2. 還沒寫state之間的切換 //更: 寫了一點
    3. 各tempo的pause/resume是該tempo+7
    4. 還沒寫亂數產生
    5. 不太確定i_start,i_key2,i_key3要擺在sequential or combinational
    6. 承5.我的state切換很亂，還沒想好到底要寫在哪個裡面比較好，你們可以爆改
    7. counter_clk和counter_num還沒想好不需要用_w和_r，還是都只用一個寫在sequential裡面就好，目前是後者。
    8. 我怎麼覺得其實pause state只需要一個就好

10/4 Jimmy
    1.建立LFSR(行55 56) LFSR_r是16bit主體，LFSR_w是1bit下個輸入。(我亂取名的XD)
    2.把 counter_clk 設成在S_IDLE也有在跑。從一開始到i_start按下的時間，取counter_clk後15bit當作初始值。 (行86)
    3.將 LFSR_w 設置完成。 (行80)
    4.LFSR更新 (行208)
    5.加上output數字更新 (combinational circuit裡面)
    6.將pause states註解掉，用default取代。(好像default什麼都不用做？) 在判斷state那邊加上clk不變的式子。
    7.加入i_speedup，可跳state。設置 logic jump 來歸零counter_clk 跟 counter_num。

10/5 謝
    1. modify the declaration of "counter_num" from [3:0] -> [4:0]
    2. modify counter_clk, counter_num, LFSR
    3. rewrite always_ff part
    4. only i_clk and i_rst should affect sequential part, otherwise, only affect combinational part 
    5. rename enable[7:1] -> state_en[7:1] // because they indicate whether the system can transfer to next state or not
    6. 大爆改 -> Top.sv 應該寫完了 設計架構參考我傳的圖片
    7. 下一個人: 研究助教寫好的KEY0, KEY1 -> rst, start 的邏輯, 想辦法套在KEY2, KEY3 上, 跑simulation

10/6 Jimmy
    1. 把reset以外的三個按鍵都導入Debounce, 再輸出pos跟neg三組。理論上pause要用neg, resume要用pos, 但這還要改其他東西，我想說可以先跑看看。
    2. simulate 成功開啟GUI, 但是數字卡在0，按下key0無反應。

10/6 mao7
    1. modified the if condition from if(state_en && clk_en) to if(state_en)
    2. 
