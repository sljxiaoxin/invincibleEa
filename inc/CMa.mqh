//+------------------------------------------------------------------+
//|                                                   |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                              http://www.yjx.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018."
#property link      "http://www.yjx.com"

#include "structs.mqh";
#include "CMaOne.mqh";

class CMa
{  
   private:
      
      /*
      int passM5;
      string crossTypeM5; //up down
      */
      CTrade* oCTrade;
      CMaOne* oMaOneM5;
      
      
      int passH1;
      string crossTypeH1; //up down
      
      datetime m_EntrySignalM5Time;
      datetime m_EntrySignalH1Time;
      datetime m_ExitSignalM5Time;
      datetime m_ExitSignalH1Time;
      
      datetime m_FillDataM5Time;
      datetime m_FillDataH1Time;
      
      double m_Ma10M5[30];
      double m_Ma30M5[30];
      double m_Stoch100M5[30];
      
      double m_Ma10H1[20];
      double m_Ma30H1[20];
      double m_Stoch100H1[20];
     
      void FillData(int tf, datetime currDt);
      
      
   public:
   
      CMa(CTrade* _oCTrade){
         /*
         passM5 = 0;
         crossTypeM5 = "none"; //up down
         */
         oCTrade = _oCTrade;
         oMaOneM5 = new CMaOne();
         passH1 = 0;
         crossTypeH1 = "none"; //up down
      };
      Signal* EntrySignalM5(void);
      Signal* EntrySignalH1(void);
      
      Signal* ExitSignalM5(void);
      Signal* ExitSignalH1(void);
      
};

void CMa::FillData(int tf, datetime currDt)
{
   int i;
   
   if(tf == PERIOD_M5){
      if(m_FillDataM5Time == currDt){
      
      }else{
         m_FillDataM5Time = currDt;
         for(i=0;i<30;i++){ 
            m_Ma10M5[i] = iMA(NULL,PERIOD_M5,10,0,MODE_SMA,PRICE_CLOSE,i);
            m_Ma30M5[i] = iMA(NULL,PERIOD_M5,30,0,MODE_SMA,PRICE_CLOSE,i);
            m_Stoch100M5[i] = iStochastic(NULL, PERIOD_M5, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   if(tf == PERIOD_H1){
      if(m_FillDataH1Time == currDt){
      
      }else{
         m_FillDataH1Time = currDt;
         for(i=0;i<20;i++){
            m_Ma10H1[i] = iMA(NULL,PERIOD_H1,10,0,MODE_SMA,PRICE_CLOSE,i);
            m_Ma30H1[i] = iMA(NULL,PERIOD_H1,30,0,MODE_SMA,PRICE_CLOSE,i);
            //m_Stoch14H1[i]  = iStochastic(NULL, PERIOD_H1, 14, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
            m_Stoch100H1[i] = iStochastic(NULL, PERIOD_H1, 100, 3, 3, MODE_SMA, 0, MODE_MAIN, i);
         }
      }
   }
   
}

Signal* CMa::EntrySignalM5(void)
{
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_EntrySignalM5Time == iTime(NULL,PERIOD_M5,0)){
      
   }else{
      m_EntrySignalM5Time = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5, m_EntrySignalM5Time);
      //passM5 += 1;
      oMaOneM5.AddCol();
      if(m_Ma10M5[1] > m_Ma30M5[1] && m_Ma10M5[2] < m_Ma30M5[2]){
         //crossTypeM5 = "up";
         //passM5 = 0;
         oMaOneM5.SetCross("up", m_Ma30M5[1]);
      }
      if(m_Ma10M5[1] < m_Ma30M5[1] && m_Ma10M5[2] > m_Ma30M5[2]){
         //crossTypeM5 = "down";
         //passM5 = 0;
         oMaOneM5.SetCross("down", m_Ma30M5[1]);
      }
      
      if(!oMaOneM5.isStochCrossOk && oMaOneM5.crossPass <30){
         double hPrice=0,lPrice=100;
         for(int i=1;i<=20;i++){
            if(m_Stoch100M5[i]>hPrice){
               hPrice = m_Stoch100M5[i];
            }
            if(m_Stoch100M5[i]<lPrice){
               lPrice = m_Stoch100M5[i];
            }
         }
         if(oMaOneM5.crossType == "up"){
            if(hPrice > 49 && lPrice<26){
               oMaOneM5.isStochCrossOk = true;
            }
         }
         if(oMaOneM5.crossType == "down"){
            if(hPrice > 74 && lPrice<51){
               oMaOneM5.isStochCrossOk = true;
            }
         }
      }
      bool isOk;
      if(oMaOneM5.IsCanOpenBuy()){
         isOk = false;
         if(oMaOneM5.crossPass <8 && Ask - oMaOneM5.crossPrice<7*oCTrade.GetPip()){
            isOk = true;
         }
         if(oMaOneM5.crossPass >=8 && Ask - oMaOneM5.crossPrice<25*oCTrade.GetPip() && Ask-m_Ma30M5[1]<4*oCTrade.GetPip()){
            isOk = true;
         }
         if(oMaOneM5.crossPass <=15 && Ask - oMaOneM5.crossPrice<25*oCTrade.GetPip() && Ask-m_Ma10M5[1]<3*oCTrade.GetPip()){
            isOk = true;
         }
         if(isOk){
            sr.sign     = OP_BUY;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "CMaM5";
            sr.comment  = "CMaM5";
            oMaOneM5.Reset(); //reset
         }
      }
      
      if(oMaOneM5.IsCanOpenSell()){
         isOk = false;
         if(oMaOneM5.crossPass <8 && oMaOneM5.crossPrice -Bid<7*oCTrade.GetPip()){
            isOk = true;
         }
         if(oMaOneM5.crossPass >=8 && oMaOneM5.crossPrice - Bid<25*oCTrade.GetPip() && m_Ma30M5[1] - Bid<4*oCTrade.GetPip()){
            isOk = true;
         }
         if(oMaOneM5.crossPass <=15 && oMaOneM5.crossPrice - Bid<25*oCTrade.GetPip() && m_Ma10M5[1] - Bid<3*oCTrade.GetPip()){
            isOk = true;
         }
         if(isOk){
            sr.sign     = OP_SELL;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "CMaM5";
            sr.comment  = "CMaM5";
            oMaOneM5.Reset(); //reset
         }
      }
      
      /*
      if(crossTypeM5 == "up" && passM5<20 && m_Stoch100M5[1]>48){
         sr.sign     = OP_BUY;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaM5";
         sr.comment  = "CMaM5";
         
         crossTypeM5 = "none";
         passM5  = 0;
      }
      if(crossTypeM5 == "down" && passM5<20 && m_Stoch100M5[1]<52){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaM5";
         sr.comment  = "CMaM5";
         
         crossTypeM5 = "none";
         passM5  = 0;
      }
      */
   }
   
   return sr;
}

Signal* CMa::EntrySignalH1(void)
{  
   Signal* sr = new Signal();
   //sr = {-1,-1,false,"",""};
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_EntrySignalH1Time == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_EntrySignalH1Time = iTime(NULL,PERIOD_H1,0);
      FillData(PERIOD_H1, m_EntrySignalH1Time);
      passH1 += 1;
      if(m_Ma10H1[1] > m_Ma30H1[1] && m_Ma10H1[2] < m_Ma30H1[2]){
         crossTypeH1 = "up";
         passH1 = 0;
      }
      if(m_Ma10H1[1] < m_Ma30H1[1] && m_Ma10H1[2] > m_Ma30H1[2]){
         crossTypeH1 = "down";
         passH1 = 0;
      }
      if(crossTypeH1 == "up" && passH1<12 && m_Stoch100H1[1]>50){
         sr.sign     = OP_BUY;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaH1";
         sr.comment  = "CMaH1";
         
         crossTypeH1 = "none";
         passH1  = 0;
      }
      if(crossTypeH1 == "down" && passH1<12 && m_Stoch100H1[1]<50){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "CMaH1";
         sr.comment  = "CMaH1";
         
         crossTypeH1 = "none";
         passH1  = 0;
      }
   }
   return sr;
}

Signal* CMa::ExitSignalM5(void){
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_ExitSignalM5Time == iTime(NULL,PERIOD_M5,0)){
      
   }else{
      m_ExitSignalM5Time = iTime(NULL,PERIOD_M5,0);
      FillData(PERIOD_M5, m_ExitSignalM5Time);
      
      if(m_Stoch100M5[1]<46 || (m_Stoch100M5[1]>95 && Ask - m_Ma30M5[1]>30*oCTrade.GetPip())){
         sr.sign     = OP_BUY;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalM5";
         sr.comment  = "ExitSignalM5";
      }
      
      if(m_Stoch100M5[1]>54 || (m_Stoch100M5[1]<5 && m_Ma30M5[1] -Bid>30*oCTrade.GetPip())){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalM5";
         sr.comment  = "ExitSignalM5";
      }
      
      /*
      if(m_Ma10M5[1] > m_Ma30M5[1] && m_Stoch100M5[1]>48){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalM5";
         sr.comment  = "ExitSignalM5";
      }
      if(m_Ma10M5[1] < m_Ma30M5[1] && m_Stoch100M5[1]<52){
            sr.sign     = OP_BUY;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "ExitSignalM5";
            sr.comment  = "ExitSignalM5";
      }
      */
   }
   return sr;
}

Signal* CMa::ExitSignalH1(void){
   
   Signal* sr = new Signal();
   sr.sign = -1;
   sr.Level = -1;
   sr.unHedg = false;
   sr.strategy = "";
   sr.comment = "";
   
   if(m_ExitSignalH1Time == iTime(NULL,PERIOD_H1,0)){
      
   }else{
      m_ExitSignalH1Time = iTime(NULL,PERIOD_H1,0);
      FillData(PERIOD_H1, m_ExitSignalH1Time);
      
      if(m_Ma10H1[1] > m_Ma30H1[1] && m_Ma10H1[2] < m_Ma30H1[2]){
         sr.sign     = OP_SELL;
         sr.Level    = 1;
         sr.unHedg   = false;
         sr.strategy = "ExitSignalH1";
         sr.comment  = "ExitSignalH1";
      }
      if(m_Ma10H1[1] < m_Ma30H1[1] && m_Ma10H1[2] > m_Ma30H1[2]){
            sr.sign     = OP_BUY;
            sr.Level    = 1;
            sr.unHedg   = false;
            sr.strategy = "ExitSignalH1";
            sr.comment  = "ExitSignalH1";
      }
   }
   return sr;
}
